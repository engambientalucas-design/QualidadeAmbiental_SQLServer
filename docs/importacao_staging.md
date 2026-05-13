# Importacao com Staging e Validacao - v2.0.0

## 1. Objetivo da fase v2.0.0

A fase `v2.0.0` tem como objetivo planejar tecnicamente um fluxo controlado de importacao de resultados analiticos externos usando staging, validacao, classificacao de registros e carga final controlada.

Esta etapa e apenas de planejamento. Nao cria scripts SQL, nao executa comandos no banco e nao altera dados oficiais.

O documento deve orientar a criacao futura do script:

```text
sql/migrations/2026-05-13_v2.0.0_importacao_staging.sql
```

## 2. Situacao atual do projeto

O projeto `QualidadeAmbiental_SQLServer` esta na versao `v1.4.0`, com banco relacional, dados didaticos, views, consultas, indices, stored procedures, auditoria, backup, restore em banco separado e evidencias visuais publicadas.

A base oficial possui indicadores consolidados:

| Indicador | Valor oficial |
| --- | ---: |
| Total de resultados analiticos | 72 |
| Resultados com limite | 57 |
| Resultados sem limite | 15 |
| Conformes com limite | 50 |
| Nao conformes com limite | 7 |

A fase v2.0.0 deve preservar esses resultados no banco principal, salvo decisao explicita posterior de executar uma carga final controlada.

## 3. Problema real de importacao que sera resolvido

O problema realista da fase e receber resultados laboratoriais externos para amostras que ja existem na base.

Esse recorte representa um fluxo comum: o banco ja possui amostras cadastradas e um laboratorio envia uma planilha com parametros analisados, valores, unidade, data de analise, metodo e observacoes.

A importacao nao deve confiar diretamente no arquivo externo. Antes de qualquer carga em `dbo.Tbl_ResultadosAnalise`, os dados devem passar por staging e validacao.

## 4. Por que usar staging

Staging permite receber dados brutos sem comprometer as tabelas oficiais.

Ela e necessaria porque arquivos externos podem conter:

- campos obrigatorios vazios;
- datas em formato invalido;
- valores numericos com texto ou separador incorreto;
- amostras inexistentes;
- parametros inexistentes;
- duplicidades dentro do proprio lote;
- duplicidades contra resultados ja carregados.

Sem staging, erros de arquivo podem virar erro transacional, violacao de constraint ou dado incorreto na camada oficial.

## 5. Diferenca entre dado bruto, dado validado e dado oficial

| Tipo de dado | Onde fica | Caracteristica |
| --- | --- | --- |
| Dado bruto | Tabela staging | Preserva o conteudo recebido, geralmente como texto. |
| Dado validado | Tabela staging com status | Ja passou por regras de consistencia e pode ser considerado apto ou inapto. |
| Dado oficial | Tabelas finais | Dado carregado em `dbo.Tbl_ResultadosAnalise`, sujeito a constraints, auditoria e views oficiais. |

O dado bruto nao deve ser tratado como verdade. O dado oficial e apenas aquele que passou pelas regras de validacao e foi carregado de forma controlada.

## 6. Escopo inicial da importacao

O escopo inicial recomendado e importar apenas resultados analiticos para amostras ja existentes.

Entrada esperada:

- `CodigoAmostra`;
- `NomeParametro`;
- `ValorResultado`;
- `UnidadeMedida`;
- `DataAnalise`;
- `MetodoAnalise`;
- `Observacao`.

Fora do escopo inicial:

- novas amostras;
- novos pontos de coleta;
- novos responsaveis;
- novos parametros;
- novos limites de referencia;
- integracao real com laboratorio externo;
- automacao corporativa complexa.

Esse recorte evita criar objetos artificiais e se conecta diretamente a `dbo.Tbl_ResultadosAnalise`, `dbo.Tbl_Amostras`, `dbo.Tbl_Parametros`, views oficiais e auditoria.

## 7. Campos esperados na entrada

| Campo | Obrigatorio? | Observacao |
| --- | --- | --- |
| `CodigoAmostra` | Sim | Deve existir em `dbo.Tbl_Amostras`. |
| `NomeParametro` | Sim | Deve existir em `dbo.Tbl_Parametros`. |
| `ValorResultado` | Sim | Recebido como texto na staging e convertido com `TRY_CONVERT`. |
| `UnidadeMedida` | Nao | Registrada para conferencia e carga final. |
| `DataAnalise` | Sim | Recebida como texto na staging e convertida com `TRY_CONVERT`. |
| `MetodoAnalise` | Nao | Informacao descritiva do metodo laboratorial. |
| `Observacao` | Nao | Observacao vinda do arquivo externo. |

A entrada deve usar codigos e nomes reconheciveis no arquivo. A resolucao para IDs internos deve ocorrer na validacao ou na carga, nao no dado bruto.

## 8. Tabelas recomendadas

| Tabela candidata | Finalidade | Tipo | Criar agora? | Justificativa | Risco de artificialidade |
| --- | --- | --- | --- | --- | --- |
| `dbo.Tbl_LotesImportacao` | Controlar cada lote importado, origem, status, totais e periodo de processamento. | Controle | Sim | Um pipeline precisa rastrear quando e como cada importacao ocorreu. | Baixo. E uma tabela operacional comum em fluxos de importacao. |
| `dbo.Stg_ResultadosAnaliseImportacao` | Armazenar linhas brutas do arquivo, status de validacao e mensagem de erro. | Staging | Sim | Permite validar antes de carregar em `Tbl_ResultadosAnalise`. | Baixo. E a camada central da fase. |
| `dbo.Tbl_ErrosImportacao` | Registrar multiplos erros por linha em tabela separada. | Erro | Nao | Para v2.0.0, `StatusValidacao` e `MensagemValidacao` na staging sao suficientes. | Medio. Pode aumentar escopo sem necessidade imediata. |

## 9. Procedures candidatas

| Procedure candidata | Finalidade | Criar na implementacao? | Justificativa |
| --- | --- | --- | --- |
| `dbo.usp_ValidarStgResultadosAnalise` | Validar registros da staging por lote e classificar como `VALIDO` ou `INVALIDO`. | Sim | Encapsula regras de validacao e evita validacao manual dispersa. |
| `dbo.usp_CarregarResultadosAnaliseValidados` | Carregar apenas registros validos para `dbo.Tbl_ResultadosAnalise`. | Sim, com confirmacao explicita | A carga final precisa ser controlada, transacional e limitada ao lote informado. |

A procedure de carga deve exigir parametros como `@IdLoteImportacao` e `@ConfirmarCarga = 1` para reduzir risco de execucao acidental.

## 10. Regras de validacao

| Validacao | Campo afetado | Regra | Acao quando invalido | Impacto se nao validar |
| --- | --- | --- | --- | --- |
| Codigo da amostra obrigatorio | `CodigoAmostra` | Nao pode ser nulo ou vazio. | Marcar `INVALIDO` e registrar mensagem. | Linha sem vinculo com amostra. |
| Parametro obrigatorio | `NomeParametro` | Nao pode ser nulo ou vazio. | Marcar `INVALIDO`. | Linha sem parametro ambiental. |
| Valor obrigatorio | `ValorResultado` | Nao pode ser nulo ou vazio. | Marcar `INVALIDO`. | Resultado sem medicao. |
| Valor numerico | `ValorResultado` | Deve converter com `TRY_CONVERT(DECIMAL(18,4), ValorResultadoTexto)`. | Marcar `INVALIDO`. | Erro de conversao ou valor incorreto. |
| Valor nao negativo | `ValorResultado` | Deve ser maior ou igual a zero no escopo didatico. | Marcar `INVALIDO`. | Indicadores podem ser distorcidos. |
| Data obrigatoria | `DataAnalise` | Nao pode ser nula ou vazia. | Marcar `INVALIDO`. | Resultado sem data analitica. |
| Data valida | `DataAnalise` | Deve converter com `TRY_CONVERT(DATE, DataAnaliseTexto)`. | Marcar `INVALIDO`. | Erro de conversao e perda de rastreabilidade temporal. |
| Amostra existente | `CodigoAmostra` | Deve existir em `dbo.Tbl_Amostras`. | Marcar `INVALIDO`. | Violacao de relacionamento com amostra. |
| Parametro existente | `NomeParametro` | Deve existir em `dbo.Tbl_Parametros`. | Marcar `INVALIDO`. | Violacao de relacionamento com parametro. |
| Duplicidade no lote | `CodigoAmostra`, `NomeParametro` | A combinacao nao deve repetir dentro do mesmo lote. | Marcar duplicatas como `INVALIDO`. | Pode gerar duas tentativas para o mesmo resultado. |
| Duplicidade contra final | `CodigoAmostra`, `NomeParametro` | A combinacao nao deve existir em `dbo.Tbl_ResultadosAnalise`. | Marcar `INVALIDO`. | Violacao de `UQ_Tbl_ResultadosAnalise_AmostraParametro`. |

Nao se deve usar `ISNUMERIC` como regra principal. A validacao futura deve usar `TRY_CONVERT` ou `TRY_CAST`.

## 11. Tratamento de registros invalidos

Registros invalidos devem permanecer na staging e nao devem ser carregados em `dbo.Tbl_ResultadosAnalise`.

Campos recomendados para controle na staging:

- `StatusValidacao`;
- `MensagemValidacao`;
- `DataValidacao`;
- `DataCargaFinal`.

Dominio recomendado para `StatusValidacao`:

| Status | Significado |
| --- | --- |
| `PENDENTE` | Linha recebida, ainda nao validada. |
| `VALIDO` | Linha aprovada nas regras de validacao. |
| `INVALIDO` | Linha rejeitada com uma ou mais mensagens. |
| `CARREGADO` | Linha valida ja carregada na tabela final. |

Como a v2.0.0 nao deve criar tabela separada de erros, `MensagemValidacao` deve permitir mensagens acumuladas, por exemplo:

```text
CodigoAmostra inexistente; ValorResultado invalido.
```

## 12. Estrategia para evitar duplicidade

A duplicidade deve ser tratada em dois niveis:

1. Duplicidade dentro do lote.
2. Duplicidade contra a tabela final.

Dentro do lote, a combinacao `CodigoAmostra + NomeParametro` deve ser unica para registros validos. Se a mesma combinacao aparecer mais de uma vez, o lote deve marcar as linhas duplicadas como invalidas ou exigir regra futura para escolher a linha vencedora.

Contra a tabela final, a validacao deve resolver `CodigoAmostra` para `IdAmostra` e `NomeParametro` para `IdParametro`, verificando se a combinacao ja existe em `dbo.Tbl_ResultadosAnalise`.

Essa etapa protege a constraint `UQ_Tbl_ResultadosAnalise_AmostraParametro`.

## 13. Geracao de IdResultado

`dbo.Tbl_ResultadosAnalise` nao usa `IDENTITY`. O projeto utiliza IDs explicitos para manter dados didaticos previsiveis.

Para o escopo da v2.0.0, a carga final pode planejar:

```text
MAX(IdResultado) + ROW_NUMBER()
```

dentro de uma transacao controlada.

Essa abordagem e aceitavel para o escopo didatico, desde que:

- a carga use `SET XACT_ABORT ON`;
- a carga ocorra em transacao;
- a carga seja limitada a um lote;
- nao haja execucoes concorrentes;
- a procedure exija confirmacao explicita.

Em ambiente produtivo, seria melhor avaliar `IDENTITY`, `SEQUENCE` ou outro mecanismo formal de geracao de chaves.

## 14. Estrategia de carga para Tbl_ResultadosAnalise

A carga final deve ser controlada e nunca deve carregar registros `INVALIDO`.

Recomendacao para a procedure futura `dbo.usp_CarregarResultadosAnaliseValidados`:

- receber `@IdLoteImportacao`;
- receber `@ConfirmarCarga`;
- abortar se `@ConfirmarCarga <> 1`;
- executar somente se nao houver registros `INVALIDO` pendentes que bloqueiem a politica do lote;
- carregar apenas registros `VALIDO`;
- resolver `CodigoAmostra` para `IdAmostra`;
- resolver `NomeParametro` para `IdParametro`;
- converter `ValorResultadoTexto` para `DECIMAL(18,4)`;
- converter `DataAnaliseTexto` para `DATE`;
- gerar `IdResultado` de forma transacional;
- marcar linhas carregadas como `CARREGADO`;
- atualizar totais do lote.

## 15. Relacao com auditoria da v1.3.0

A auditoria da v1.3.0 possui triggers em `dbo.Tbl_ResultadosAnalise`, `dbo.Tbl_LimitesReferencia` e `dbo.Tbl_Amostras`.

Se a carga final inserir registros em `dbo.Tbl_ResultadosAnalise`, a trigger `dbo.TRG_Tbl_ResultadosAnalise_Auditoria` deve registrar os `INSERTs`.

Isso e desejavel como rastreabilidade, mas deve ser documentado nas evidencias. A carga de staging, por outro lado, nao deve acionar auditoria de resultados finais, pois ainda nao altera a tabela oficial.

## 16. Relacao com backup/restore da v1.4.0

A v1.4.0 criou um caminho seguro para validar alteracoes em banco restaurado.

A primeira validacao da v2.0.0 deve ocorrer preferencialmente em:

```text
QualidadeAmbiental_RestoreTeste
```

Isso evita alterar os indicadores oficiais do banco principal `QualidadeAmbiental` e aproveita o banco restaurado como ambiente tecnico de teste.

Qualquer execucao no banco principal deve ser decisao explicita posterior.

## 17. Ambiente recomendado para validacao

Ambiente recomendado para a primeira implementacao:

| Banco | Uso |
| --- | --- |
| `QualidadeAmbiental` | Base oficial preservada. |
| `QualidadeAmbiental_RestoreTeste` | Ambiente seguro para validar staging e carga final controlada. |

A documentacao futura deve registrar claramente em qual banco a v2.0.0 foi validada.

## 18. Validações pos-carga

Depois de uma carga final, devem ser conferidos:

- total de registros recebidos no lote;
- total de registros `VALIDO`;
- total de registros `INVALIDO`;
- total de registros `CARREGADO`;
- ausencia de invalidos na tabela final;
- indicadores de conformidade apos a carga;
- registros de auditoria gerados por `INSERT`, se a carga final for executada.

Se a carga for feita em `QualidadeAmbiental_RestoreTeste`, os indicadores podem mudar nesse banco sem afetar a base oficial.

## 19. Evidencias visuais esperadas

| Evidencia | O que deve demonstrar | Consulta ou objeto relacionado |
| --- | --- | --- |
| Tabela de lotes criada | Controle de importacoes disponivel. | `dbo.Tbl_LotesImportacao` |
| Tabela staging criada | Area de recebimento bruto disponivel. | `dbo.Stg_ResultadosAnaliseImportacao` |
| Lote registrado | Inicio de importacao rastreavel. | `dbo.Tbl_LotesImportacao` |
| Dados de exemplo na staging | Linhas recebidas antes da validacao. | `dbo.Stg_ResultadosAnaliseImportacao` |
| Registros validos | Linhas classificadas como `VALIDO`. | `StatusValidacao` |
| Registros invalidos | Linhas classificadas como `INVALIDO`. | `StatusValidacao` |
| Mensagens de erro | Motivos de rejeicao claros. | `MensagemValidacao` |
| Carga de validos | Linhas `VALIDO` carregadas ou preparadas para carga. | `dbo.usp_CarregarResultadosAnaliseValidados` |
| Invalidos nao carregados | Garantia de que registros rejeitados nao foram para a tabela final. | `dbo.Tbl_ResultadosAnalise` |
| Indicadores pos-carga | Efeito da carga no banco de teste. | `dbo.VW_ConformidadeResultados` |
| Auditoria pos-carga | `INSERTs` registrados se a carga final ocorrer. | `dbo.Tbl_AuditoriaAlteracoes` |

## 20. Indice minimo recomendado

Nao se deve criar indices por volume artificial.

O unico indice candidato para a primeira implementacao e:

```text
IX_Stg_ResultadosAnaliseImportacao_Lote_Status
```

Colunas sugeridas:

```text
IdLoteImportacao, StatusValidacao
```

Justificativa: validacao, resumo e carga final devem filtrar registros por lote e status.

Indices adicionais, como `CodigoAmostra + NomeParametro`, devem ser adiados ate haver volume ou consulta recorrente que justifique a criacao.

## 21. Limitacoes da fase v2.0.0

Limitacoes assumidas:

- dados externos sao simulados e didaticos;
- nao ha integracao real com laboratorio;
- nao ha importacao automatica por arquivo nesta etapa;
- nao ha SSIS, Python, Power BI ou API externa;
- nao ha tratamento de multiplos arquivos concorrentes;
- nao ha tabela separada de erros;
- nao ha alteracao das tabelas principais para `IDENTITY` ou `SEQUENCE`;
- a primeira validacao deve ocorrer em banco restaurado/teste.

## 22. O que nao sera feito nesta fase

Fora do escopo:

- importar novas amostras;
- importar cadastros mestres;
- importar novos limites de referencia;
- substituir cargas oficiais da v1.0.0;
- apagar ou corrigir dados oficiais;
- desabilitar constraints;
- desabilitar triggers;
- usar `MERGE` sem justificativa forte;
- criar automacao corporativa;
- versionar arquivos grandes ou dados sensiveis;
- criar pipeline amplo apenas para aumentar quantidade de objetos.

## 23. Entregas previstas

Entregas previstas para a v2.0.0:

- documento de planejamento `docs/importacao_staging.md`;
- script futuro `sql/migrations/2026-05-13_v2.0.0_importacao_staging.sql`;
- tabela de controle de lotes;
- tabela staging de resultados analiticos;
- procedure de validacao da staging;
- procedure de carga controlada de registros validos;
- indice minimo por lote e status, se confirmado na implementacao;
- exemplos pequenos e didaticos de linhas validas e invalidas;
- evidencias visuais no SSMS;
- atualizacao futura de README, CHANGELOG e evidencias apos validacao.

## 24. Resumo final

A v2.0.0 deve marcar a transicao do projeto para uma logica mais proxima de engenharia de dados.

O foco recomendado e importar resultados analiticos externos para amostras ja existentes, usando uma camada de staging e validacao antes de qualquer carga final.

O desenho proposto evita inflar o banco com tabelas artificiais. A primeira implementacao deve criar apenas controle de lote, staging, validacao e carga controlada.

Registros invalidos devem permanecer na staging com mensagem clara. Registros validos so devem ser carregados por procedure, com lote informado, confirmacao explicita, transacao e `SET XACT_ABORT ON`.

Com esse recorte, a fase `v2.0.0` demonstra maturidade tecnica sem comprometer a base oficial validada ate a v1.4.0.
