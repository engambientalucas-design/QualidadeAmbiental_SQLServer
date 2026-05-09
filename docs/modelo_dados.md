# Modelo de Dados - QualidadeAmbiental_SQLServer

## Visao geral do modelo

O projeto `QualidadeAmbiental_SQLServer` modela um banco de dados relacional em SQL Server para monitoramento didatico de qualidade de agua e esgoto. O modelo organiza dados de cadastro, coleta de amostras, resultados laboratoriais, limites de referencia e views analiticas.

O banco de dados oficial definido nos scripts e `QualidadeAmbiental`. Os objetos principais estao no schema `dbo` e os scripts oficiais ficam na pasta `sql/`.

O modelo possui 8 tabelas principais:

| Grupo | Tabelas |
| --- | --- |
| Cadastros | `Tbl_Responsaveis`, `Tbl_StatusAmostra`, `Tbl_TiposAmostra`, `Tbl_PontosColeta`, `Tbl_Parametros` |
| Operacionais | `Tbl_Amostras`, `Tbl_ResultadosAnalise` |
| Referencia didatica | `Tbl_LimitesReferencia` |

## Objetivo do modelo de dados

O objetivo do modelo e registrar amostras ambientais coletadas em pontos definidos, associar essas amostras a responsaveis tecnicos e tipos de amostra, armazenar resultados analiticos por parametro e comparar os valores obtidos com limites de referencia didaticos.

O modelo tambem sustenta uma camada analitica baseada em views, permitindo avaliar conformidade, resultados fora do padrao, resultados sem limite cadastrado, indicadores mensais, ranking de parametros criticos e eficiencia de remocao em cenario de ETE.

## Processo de negocio representado

O fluxo representado pelo banco pode ser resumido em:

1. Cadastro dos responsaveis, status, tipos de amostra, pontos de coleta e parametros ambientais.
2. Cadastro de limites de referencia didaticos por combinacao de parametro e tipo de amostra.
3. Registro das amostras coletadas, com data, hora, ponto, tipo, responsavel e status.
4. Registro dos resultados analiticos para cada parametro medido em cada amostra.
5. Classificacao dos resultados em relacao aos limites didaticos.
6. Consolidacao dos dados em views e consultas analiticas.

Esse processo permite demonstrar uma cadeia completa de monitoramento ambiental: cadastro, coleta, analise laboratorial, avaliacao de conformidade e geracao de indicadores.

## Tabelas de cadastro

### `Tbl_Responsaveis`

Armazena profissionais associados as amostras, como coletores, analistas, engenheiros ou coordenadores.

| Coluna | Tipo | Obrigatoria | Papel |
| --- | --- | --- | --- |
| `IdResponsavel` | `INT` | Sim | Chave primaria |
| `NomeResponsavel` | `VARCHAR(150)` | Sim | Nome do responsavel |
| `Cargo` | `VARCHAR(100)` | Nao | Cargo ou funcao |
| `Email` | `VARCHAR(150)` | Nao | Contato por e-mail |
| `Telefone` | `VARCHAR(30)` | Nao | Contato telefonico |

Constraint principal: `PK_Tbl_Responsaveis`.

### `Tbl_StatusAmostra`

Define os status possiveis para uma amostra, como coletada, em analise, concluida, reprovada ou pendente.

| Coluna | Tipo | Obrigatoria | Papel |
| --- | --- | --- | --- |
| `IdStatus` | `INT` | Sim | Chave primaria |
| `NomeStatus` | `VARCHAR(50)` | Sim | Nome unico do status |
| `Descricao` | `VARCHAR(200)` | Nao | Descricao operacional |

Constraints principais: `PK_Tbl_StatusAmostra` e `UQ_Tbl_StatusAmostra_NomeStatus`.

### `Tbl_TiposAmostra`

Representa os tipos de amostra usados no projeto: agua bruta, agua tratada, esgoto bruto, esgoto tratado e corpo hidrico.

| Coluna | Tipo | Obrigatoria | Papel |
| --- | --- | --- | --- |
| `IdTipoAmostra` | `INT` | Sim | Chave primaria |
| `NomeTipoAmostra` | `VARCHAR(80)` | Sim | Nome unico do tipo de amostra |
| `Descricao` | `VARCHAR(200)` | Nao | Descricao do tipo |

Constraints principais: `PK_Tbl_TiposAmostra` e `UQ_Tbl_TiposAmostra_NomeTipoAmostra`.

### `Tbl_PontosColeta`

Armazena os locais de coleta, incluindo municipio, UF e coordenadas geograficas opcionais.

| Coluna | Tipo | Obrigatoria | Papel |
| --- | --- | --- | --- |
| `IdPontoColeta` | `INT` | Sim | Chave primaria |
| `NomePonto` | `VARCHAR(100)` | Sim | Nome do ponto |
| `TipoPonto` | `VARCHAR(80)` | Sim | Tipo do local |
| `Municipio` | `VARCHAR(100)` | Sim | Municipio |
| `Estado` | `CHAR(2)` | Sim | UF |
| `Latitude` | `DECIMAL(9,6)` | Nao | Latitude do ponto |
| `Longitude` | `DECIMAL(9,6)` | Nao | Longitude do ponto |
| `Observacao` | `VARCHAR(255)` | Nao | Observacoes adicionais |

Constraints principais:

- `PK_Tbl_PontosColeta`
- `UQ_Tbl_PontosColeta_NomeMunicipioEstado`
- `CK_Tbl_PontosColeta_Latitude`
- `CK_Tbl_PontosColeta_Longitude`

As checks de latitude e longitude impedem valores fora das faixas geograficas esperadas.

### `Tbl_Parametros`

Armazena os parametros ambientais analisados, como pH, turbidez, oxigenio dissolvido, DBO, DQO, coliformes, temperatura, condutividade, solidos totais, nitrogenio amoniacal, fosforo total e cloro residual livre.

| Coluna | Tipo | Obrigatoria | Papel |
| --- | --- | --- | --- |
| `IdParametro` | `INT` | Sim | Chave primaria |
| `NomeParametro` | `VARCHAR(120)` | Sim | Nome unico do parametro |
| `UnidadeMedida` | `VARCHAR(30)` | Nao | Unidade padrao do parametro |
| `Categoria` | `VARCHAR(80)` | Nao | Grupo tecnico do parametro |
| `Descricao` | `VARCHAR(255)` | Nao | Descricao do parametro |
| `Ativo` | `BIT` | Sim | Indicador de parametro ativo, com default `1` |

Constraints principais: `PK_Tbl_Parametros`, `UQ_Tbl_Parametros_NomeParametro` e `DF_Tbl_Parametros_Ativo`.

## Tabelas operacionais

### `Tbl_Amostras`

Registra cada amostra coletada. Ela conecta o ponto de coleta, o tipo de amostra, o responsavel e o status operacional.

| Coluna | Tipo | Obrigatoria | Papel |
| --- | --- | --- | --- |
| `IdAmostra` | `INT` | Sim | Chave primaria |
| `CodigoAmostra` | `VARCHAR(50)` | Sim | Codigo unico da amostra |
| `IdPontoColeta` | `INT` | Sim | FK para `Tbl_PontosColeta` |
| `IdTipoAmostra` | `INT` | Sim | FK para `Tbl_TiposAmostra` |
| `IdResponsavel` | `INT` | Sim | FK para `Tbl_Responsaveis` |
| `IdStatus` | `INT` | Sim | FK para `Tbl_StatusAmostra` |
| `DataColeta` | `DATE` | Sim | Data da coleta |
| `HoraColeta` | `TIME(0)` | Nao | Hora da coleta |
| `Observacao` | `VARCHAR(255)` | Nao | Observacoes da amostra |

Constraints principais:

- `PK_Tbl_Amostras`
- `UQ_Tbl_Amostras_CodigoAmostra`
- `FK_Tbl_Amostras_Tbl_PontosColeta`
- `FK_Tbl_Amostras_Tbl_TiposAmostra`
- `FK_Tbl_Amostras_Tbl_Responsaveis`
- `FK_Tbl_Amostras_Tbl_StatusAmostra`

### `Tbl_ResultadosAnalise`

Armazena os resultados laboratoriais de cada parametro analisado em cada amostra.

| Coluna | Tipo | Obrigatoria | Papel |
| --- | --- | --- | --- |
| `IdResultado` | `INT` | Sim | Chave primaria |
| `IdAmostra` | `INT` | Sim | FK para `Tbl_Amostras` |
| `IdParametro` | `INT` | Sim | FK para `Tbl_Parametros` |
| `ValorResultado` | `DECIMAL(18,4)` | Sim | Valor medido |
| `UnidadeMedida` | `VARCHAR(30)` | Nao | Unidade informada no resultado |
| `DataAnalise` | `DATE` | Sim | Data da analise |
| `MetodoAnalise` | `VARCHAR(100)` | Nao | Metodo usado |
| `Observacao` | `VARCHAR(255)` | Nao | Observacoes do resultado |

Constraints principais:

- `PK_Tbl_ResultadosAnalise`
- `UQ_Tbl_ResultadosAnalise_AmostraParametro`
- `FK_Tbl_ResultadosAnalise_Tbl_Amostras`
- `FK_Tbl_ResultadosAnalise_Tbl_Parametros`

A constraint `UQ_Tbl_ResultadosAnalise_AmostraParametro` impede mais de um resultado para o mesmo parametro dentro da mesma amostra. Essa regra faz sentido para o escopo atual, mas pode precisar evoluir caso o projeto passe a registrar replicatas, reanalises ou historico de retificacao.

## Tabela de limites de referencia

### `Tbl_LimitesReferencia`

Armazena limites minimos e/ou maximos por combinacao de parametro e tipo de amostra.

Importante: os limites cadastrados sao didaticos e usados para demonstracao tecnica do projeto. Eles nao devem ser tratados como limites legais, regulatorios ou normativos reais.

| Coluna | Tipo | Obrigatoria | Papel |
| --- | --- | --- | --- |
| `IdLimite` | `INT` | Sim | Chave primaria |
| `IdParametro` | `INT` | Sim | FK para `Tbl_Parametros` |
| `IdTipoAmostra` | `INT` | Sim | FK para `Tbl_TiposAmostra` |
| `ValorMinimo` | `DECIMAL(18,4)` | Nao | Limite minimo didatico |
| `ValorMaximo` | `DECIMAL(18,4)` | Nao | Limite maximo didatico |
| `UnidadeMedida` | `VARCHAR(30)` | Nao | Unidade do limite |
| `ReferenciaNormativa` | `VARCHAR(150)` | Nao | Referencia textual didatica |
| `Observacao` | `VARCHAR(255)` | Nao | Observacoes |

Constraints principais:

- `PK_Tbl_LimitesReferencia`
- `UQ_Tbl_LimitesReferencia_ParametroTipoAmostra`
- `FK_Tbl_LimitesReferencia_Tbl_Parametros`
- `FK_Tbl_LimitesReferencia_Tbl_TiposAmostra`
- `CK_Tbl_LimitesReferencia_LimiteInformado`
- `CK_Tbl_LimitesReferencia_MinimoMenorOuIgualMaximo`

As checks garantem que pelo menos um limite seja informado e que, quando minimo e maximo existirem juntos, o minimo seja menor ou igual ao maximo.

## Relacionamentos entre tabelas

| Origem | Coluna | Destino | Cardinalidade logica |
| --- | --- | --- | --- |
| `Tbl_Amostras` | `IdPontoColeta` | `Tbl_PontosColeta.IdPontoColeta` | Muitas amostras para um ponto |
| `Tbl_Amostras` | `IdTipoAmostra` | `Tbl_TiposAmostra.IdTipoAmostra` | Muitas amostras para um tipo |
| `Tbl_Amostras` | `IdResponsavel` | `Tbl_Responsaveis.IdResponsavel` | Muitas amostras para um responsavel |
| `Tbl_Amostras` | `IdStatus` | `Tbl_StatusAmostra.IdStatus` | Muitas amostras para um status |
| `Tbl_ResultadosAnalise` | `IdAmostra` | `Tbl_Amostras.IdAmostra` | Muitos resultados para uma amostra |
| `Tbl_ResultadosAnalise` | `IdParametro` | `Tbl_Parametros.IdParametro` | Muitos resultados para um parametro |
| `Tbl_LimitesReferencia` | `IdParametro` | `Tbl_Parametros.IdParametro` | Muitos limites para um parametro |
| `Tbl_LimitesReferencia` | `IdTipoAmostra` | `Tbl_TiposAmostra.IdTipoAmostra` | Muitos limites para um tipo de amostra |

O relacionamento entre resultado e limite nao e uma FK direta. Ele e resolvido nas views pela combinacao `IdParametro` do resultado com `IdTipoAmostra` da amostra.

## Regras de integridade

Regras implementadas no banco:

- Cada tabela possui chave primaria explicita.
- `Tbl_Amostras.CodigoAmostra` deve ser unico.
- `Tbl_StatusAmostra.NomeStatus` deve ser unico.
- `Tbl_TiposAmostra.NomeTipoAmostra` deve ser unico.
- `Tbl_PontosColeta` impede duplicidade de `NomePonto`, `Municipio` e `Estado`.
- `Tbl_Parametros.NomeParametro` deve ser unico.
- `Tbl_ResultadosAnalise` permite apenas um resultado por combinacao de amostra e parametro.
- `Tbl_LimitesReferencia` permite apenas um limite por combinacao de parametro e tipo de amostra.
- Latitude deve estar entre -90 e 90, quando informada.
- Longitude deve estar entre -180 e 180, quando informada.
- Um limite de referencia deve ter pelo menos `ValorMinimo` ou `ValorMaximo`.
- Quando os dois limites forem informados, `ValorMinimo` deve ser menor ou igual a `ValorMaximo`.
- As FKs impedem que amostras, resultados e limites referenciem cadastros inexistentes.

Regras tratadas na camada de views:

- Resultado sem limite cadastrado deve continuar aparecendo nas analises.
- A classificacao oficial considera quatro situacoes: `Conforme`, `Acima do limite maximo`, `Abaixo do limite minimo` e `Sem limite de referencia`.
- A unidade exibida na view de conformidade e resolvida por `COALESCE(r.UnidadeMedida, p.UnidadeMedida, lr.UnidadeMedida)`.

## Como o modelo apoia as views e relatorios

### `VW_ConformidadeResultados`

E a view central do modelo analitico. Ela une resultados, amostras, tipos de amostra, pontos de coleta, responsaveis, status, parametros e limites.

O ponto tecnico mais importante e o uso de `LEFT JOIN` com `Tbl_LimitesReferencia`. Essa escolha preserva resultados que ainda nao possuem limite cadastrado e permite classifica-los como `Sem limite de referencia`.

### `VW_ResultadosForaDoPadrao`

Filtra a view central para resultados classificados como `Acima do limite maximo` ou `Abaixo do limite minimo`. Apoia investigacao tecnica de nao conformidades didaticas.

### `VW_ResultadosSemLimiteReferencia`

Lista os resultados que nao encontraram combinacao correspondente em `Tbl_LimitesReferencia`. Essa view ajuda a identificar lacunas na matriz de limites didaticos.

### `VW_ConformidadeMensal`

Agrupa os resultados por ano e mes da coleta. Calcula total de resultados, resultados com limite, resultados sem limite, conformes, nao conformes e percentual de conformidade entre os resultados que possuem limite.

### `VW_RankingParametrosCriticos`

Agrupa resultados por parametro e categoria, permitindo identificar quais parametros concentram maior quantidade ou percentual de nao conformidades.

### `VW_EficienciaRemocaoETE`

Compara resultados de `Esgoto Bruto` e `Esgoto Tratado` para parametros especificos: `DBO`, `DQO`, `Solidos Totais`, `Nitrogenio Amoniacal` e `Fosforo Total`.

A comparacao e feita por mesmo parametro e mesma data de coleta, usando agregacao previa por entrada e saida. A view calcula o percentual de remocao com protecao contra divisao por zero via `NULLIF`.

## Analise tecnica com visao senior

| Pergunta | Analise |
| --- | --- |
| Que processo de negocio o modelo representa? | Representa o ciclo de monitoramento ambiental: cadastro de entidades, coleta de amostras, analise laboratorial, comparacao com limites didaticos e geracao de indicadores. |
| Quais regras nao podem ser violadas? | Amostras precisam apontar para cadastros validos; resultados precisam apontar para amostra e parametro validos; uma amostra nao pode ter dois resultados para o mesmo parametro no desenho atual; limites precisam estar associados a parametro e tipo de amostra validos. |
| Como os dados mudam com o tempo? | Cadastros tendem a mudar pouco. Amostras e resultados crescem continuamente com novas coletas. Limites podem mudar por revisao didatica ou, em uma evolucao futura, por vigencia normativa. |
| Quem consome essas informacoes? | Analistas ambientais, responsaveis tecnicos, coordenadores de qualidade, avaliadores do portfolio e consultas/dashboards que dependem das views oficiais. |
| Quais consultas podem pesar? | Consultas sobre `VW_ConformidadeResultados`, agregacoes mensais, ranking de parametros criticos e eficiencia de remocao podem pesar conforme o volume crescer, pois dependem de joins e agrupamentos. |
| O que precisa ser auditavel? | Alteracoes em resultados analiticos, limites de referencia, status de amostra, responsavel associado e eventuais correcoes de data/metodo de analise. Auditoria ainda nao esta implementada. |
| O que acontece se registros forem apagados? | Sem cascade definido, FKs impedem exclusao de registros referenciados. Isso protege integridade, mas exige processo controlado para inativacao ou exclusao logica em evolucoes futuras. |
| Como o modelo escala? | Escala bem para portfolio e volumes moderados. Para uso maior, precisaria de indices adicionais em FKs, datas, parametros e campos usados em filtros/agrupamentos das views. |
| Como o modelo pode quebrar? | Pode quebrar por carga fora da ordem correta, tentativa de duplicar combinacoes unicas, ausencia de limites esperados, mudancas nos nomes textuais usados pela view de ETE ou necessidade futura de replicatas/reanalises nao suportada pela unicidade atual. |

## Limitacoes atuais do modelo

- Os IDs sao explicitos e nao usam `IDENTITY`, o que facilita dados didaticos previsiveis, mas exige controle manual em novas cargas.
- Nao ha colunas de auditoria como data de criacao, usuario de criacao, data de alteracao ou usuario de alteracao.
- Nao ha historico de alteracao de resultados analiticos.
- Nao ha historico de vigencia para limites de referencia.
- Os limites de referencia sao didaticos e nao representam norma real.
- O modelo nao diferencia resultado original, resultado retificado e resultado reanalisado.
- `Tbl_ResultadosAnalise` limita uma combinacao de amostra e parametro a um unico registro.
- Nao ha indices adicionais explicitamente criados alem das chaves e constraints.
- A view `VW_EficienciaRemocaoETE` depende de nomes textuais de tipos de amostra e parametros.
- Nao ha tabela de unidades de medida padronizada; unidades aparecem como texto em parametros, resultados e limites.
- Nao ha classificacao temporal de status da amostra; existe apenas o status atual registrado na tabela `Tbl_Amostras`.

## Evolucoes futuras recomendadas

- Criar indices para colunas de FK e para campos usados em filtros e agrupamentos, como `DataColeta`, `IdParametro`, `IdTipoAmostra` e `IdPontoColeta`.
- Avaliar colunas de auditoria nas tabelas operacionais e em limites de referencia.
- Criar historico de status da amostra, caso seja necessario rastrear mudancas de fluxo operacional.
- Criar vigencia para limites de referencia, permitindo comparar resultados conforme a regra aplicavel na data da coleta ou analise.
- Avaliar exclusao logica ou campo `Ativo` em cadastros alem de `Tbl_Parametros`.
- Normalizar unidades de medida em tabela propria, caso o projeto evolua para maior controle de consistencia.
- Revisar a regra de unicidade de `Tbl_ResultadosAnalise` se houver necessidade de replicatas, contraprovas, reanalises ou versoes de laudo.
- Substituir dependencias textuais da view de ETE por identificadores ou tabelas de configuracao, caso a solucao cresca.
- Documentar um dicionario de dados complementar com dominio esperado, exemplos e regras de preenchimento por coluna.
- Revisar limites com fonte normativa real apenas se o objetivo do projeto deixar de ser didatico.

## Validacoes finais do projeto

As validacoes finais foram planejadas nos scripts oficiais e devem ser interpretadas como consistencia interna do projeto, nao como evidencia normativa externa.

| Indicador | Valor esperado |
| --- | ---: |
| Total de resultados analiticos | 72 |
| Resultados com limite | 57 |
| Resultados sem limite | 15 |
| Conformes com limite | 50 |
| Nao conformes com limite | 7 |

Esses numeros sao verificados pelas consultas do arquivo `sql/06_consultas_analiticas.sql`, especialmente a validacao consolidada da conformidade e o checklist final.

## Resumo final

O modelo de dados do `QualidadeAmbiental_SQLServer` esta organizado de forma coerente para um projeto de portfolio em SQL Server. Ele separa cadastros, operacao, limites didaticos e camada analitica, usando chaves primarias, chaves estrangeiras, constraints de unicidade e checks para preservar regras basicas de integridade.

A decisao de manter resultados sem limite nas views por meio de `LEFT JOIN` e tecnicamente importante, pois evita ocultar lacunas da matriz de limites. A modelagem atual atende bem ao objetivo didatico e demonstra raciocinio relacional, T-SQL e analise ambiental aplicada.

Para evolucao futura, os principais pontos sao auditoria, historico, vigencia de limites, indices adicionais e maior normalizacao de unidades e regras de comparacao. Essas melhorias nao sao obrigatorias para o escopo atual, mas indicam caminhos tecnicos maduros caso o projeto avance para um cenario mais proximo de producao.
