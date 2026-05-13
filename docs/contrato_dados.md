# Contrato de Dados - v2.1.0

## Objetivo da fase v2.1.0

A fase `v2.1.0` tem como objetivo consolidar o contrato de dados oficial para consumo externo dos resultados analiticos do projeto `QualidadeAmbiental_SQLServer`.

Esta fase funciona como encerramento tecnico controlado do projeto principal. Ela documenta como consumidores externos podem ler os dados consolidados do SQL Server, sem transformar o repositorio em uma aplicacao operacional, projeto de BI, API corporativa ou produto de frontend.

## Motivo para encerrar o projeto principal apos esta fase

O projeto ja demonstrou um ciclo completo de banco de dados SQL Server aplicado a um dominio ambiental realista:

- modelagem relacional;
- carga didatica;
- views analiticas;
- consultas de validacao;
- indices;
- analise de plano de execucao;
- stored procedures parametrizadas;
- auditoria e rastreabilidade;
- backup e restore;
- staging de importacao;
- validacao de dados externos;
- documentacao tecnica;
- evidencias visuais;
- versionamento com Git, tags e releases.

Adicionar API dedicada, Power BI, frontend completo, autenticacao, deploy, Docker ou CI/CD ao mesmo repositorio criaria expansao indefinida de escopo. A decisao profissional e encerrar o projeto principal como portfolio tecnico SQL Server e tratar novas frentes como projetos derivados.

## Situacao atual do projeto ate v2.0.0

A versao `v2.0.0` consolidou o pipeline de importacao com staging, validacao por lote e bloqueio de cargas indevidas. Os indicadores finais permaneceram consistentes:

| Indicador | Valor esperado |
| --- | ---: |
| Total de resultados analiticos | 72 |
| Resultados com limite | 57 |
| Resultados sem limite | 15 |
| Conformes com limite | 50 |
| Nao conformes com limite | 7 |

Esses totais sao a base de verificacao para qualquer exportacao didatica derivada da view central.

## Por que criar um contrato de dados

O contrato de dados define um formato estavel para consumidores externos, como dashboards locais, APIs futuras, ferramentas de BI ou analises em planilha.

Ele evita que cada consumidor interprete diretamente a estrutura interna do banco e reforca que:

- o SQL Server continua sendo a fonte oficial;
- a regra de conformidade nao deve ser recriada fora da view;
- o CSV e apenas um artefato didatico de consumo;
- novas camadas devem respeitar os nomes, tipos e indicadores documentados.

## Fonte oficial do contrato

A fonte principal do contrato e:

```sql
dbo.VW_ConformidadeResultados
```

Essa view consolida resultados analiticos, amostras, pontos de coleta, tipos de amostra, parametros, limites de referencia e classificacao de conformidade.

O contrato nao cria regra paralela de conformidade. Ele apenas documenta e prepara a exportacao da regra ja calculada pela view oficial.

## Dataset proposto

Dataset sugerido:

```text
dados_conformidade_v2_1_0
```

Finalidade:

- permitir consumo externo didatico dos resultados consolidados;
- apoiar demonstracoes locais;
- servir como base para projetos derivados;
- preservar os indicadores oficiais da base didatica atual.

O dataset nao representa integracao real com laboratorio externo e nao deve ser vendido como carga operacional de producao.

## Local sugerido para exportacao

Pasta recomendada:

```text
exports/
```

Arquivo sugerido:

```text
exports/dados_conformidade_v2_1_0.csv
```

Nesta primeira etapa, o arquivo CSV ainda nao e criado. O objetivo e documentar o contrato antes da implementacao da exportacao.

## Criterio para versionar ou nao versionar o CSV

Como o dataset atual e pequeno, didatico e nao sensivel, o CSV pode ser versionado no Git como evidencia de consumo externo.

Em um cenario real, arquivos grandes, sensiveis, operacionais, pessoais ou recebidos de terceiros nao devem ser versionados no Git. Nesses casos, o repositorio deve conter apenas scripts, contratos, exemplos anonimizados e instrucoes de geracao.

## Layout previsto do CSV

Formato recomendado:

| Item | Padrao recomendado |
| --- | --- |
| Encoding | UTF-8 |
| Separador | Ponto e virgula (`;`) para melhor compatibilidade com Excel pt-BR |
| Quebra de linha | CRLF ou LF, conforme ferramenta de exportacao |
| Cabecalho | Sim |
| Datas | `YYYY-MM-DD` |
| Decimais | Ponto decimal (`.`) no arquivo tecnico; aceitar conversao em ferramentas pt-BR quando necessario |
| Valores nulos | Campo vazio |
| Textos | Sem quebra de linha interna |

O CSV deve ser tratado como artefato de consumo externo e nao como fonte oficial superior ao banco.

## Dicionario das colunas exportaveis

| Coluna na view | Nome sugerido no CSV | Descricao |
| --- | --- | --- |
| `IdResultado` | `id_resultado` | Identificador tecnico do resultado analitico. |
| `IdAmostra` | `id_amostra` | Identificador tecnico da amostra. |
| `CodigoAmostra` | `codigo_amostra` | Codigo unico da amostra. |
| `DataColeta` | `data_coleta` | Data em que a amostra foi coletada. |
| `HoraColeta` | `hora_coleta` | Hora da coleta, quando informada. |
| `IdTipoAmostra` | `id_tipo_amostra` | Identificador do tipo de amostra. |
| `NomeTipoAmostra` | `tipo_amostra` | Tipo da amostra, como agua tratada, esgoto bruto ou corpo hidrico. |
| `IdPontoColeta` | `id_ponto_coleta` | Identificador do ponto de coleta. |
| `NomePonto` | `ponto_coleta` | Nome do ponto de coleta. |
| `TipoPonto` | `tipo_ponto` | Categoria do ponto de coleta. |
| `Municipio` | `municipio` | Municipio do ponto. |
| `Estado` | `estado` | Unidade federativa do ponto. |
| `IdResponsavel` | `id_responsavel` | Identificador do responsavel tecnico. |
| `NomeResponsavel` | `responsavel` | Nome do responsavel associado a amostra. |
| `IdStatus` | `id_status` | Identificador do status da amostra. |
| `NomeStatus` | `status_amostra` | Status operacional da amostra. |
| `IdParametro` | `id_parametro` | Identificador do parametro ambiental. |
| `NomeParametro` | `parametro` | Nome do parametro ambiental analisado. |
| `Categoria` | `categoria_parametro` | Categoria tecnica do parametro. |
| `ValorResultado` | `valor_resultado` | Valor medido no resultado analitico. |
| `UnidadeMedida` | `unidade_medida` | Unidade de medida resolvida pela view. |
| `DataAnalise` | `data_analise` | Data da analise laboratorial. |
| `MetodoAnalise` | `metodo_analise` | Metodo analitico informado, quando existir. |
| `IdLimite` | `id_limite` | Identificador do limite de referencia, quando houver. |
| `ValorMinimo` | `valor_minimo` | Limite minimo didatico aplicavel, quando houver. |
| `ValorMaximo` | `valor_maximo` | Limite maximo didatico aplicavel, quando houver. |
| `ReferenciaNormativa` | `referencia_normativa` | Referencia textual didatica associada ao limite. |
| `ClassificacaoResultado` | `classificacao_resultado` | Classificacao oficial calculada pela view. |
| `PossuiLimiteReferencia` | `possui_limite_referencia` | Indicador `1` quando existe limite de referencia e `0` quando nao existe. |
| `IndicadorNaoConforme` | `indicador_nao_conforme` | Indicador `1` para resultado nao conforme, `0` para conforme e vazio quando nao ha limite. |

## Tipos de dados esperados

| Grupo | Tipo esperado no CSV |
| --- | --- |
| Identificadores | Inteiro |
| Datas | Texto no formato `YYYY-MM-DD` |
| Horarios | Texto no formato `HH:mm:ss` ou vazio |
| Valores analiticos e limites | Decimal |
| Indicadores | `0`, `1` ou vazio |
| Textos descritivos | Texto |

## Regras de classificacao herdadas da view

A classificacao oficial vem de `dbo.VW_ConformidadeResultados`.

| Classificacao | Significado |
| --- | --- |
| `Conforme` | Resultado possui limite e esta dentro dos limites didaticos. |
| `Acima do limite maximo` | Resultado possui limite maximo e ultrapassou esse valor. |
| `Abaixo do limite minimo` | Resultado possui limite minimo e ficou abaixo desse valor. |
| `Sem limite de referencia` | Nao existe limite didatico cadastrado para a combinacao parametro + tipo de amostra. |

Consumidores externos nao devem recalcular a regra de conformidade de forma paralela quando a coluna `ClassificacaoResultado` estiver disponivel.

## Indicadores esperados no dataset exportado

Para a base didatica oficial atual, o CSV exportado deve preservar:

| Indicador | Valor esperado |
| --- | ---: |
| Total de linhas | 72 |
| Resultados com limite | 57 |
| Resultados sem limite | 15 |
| Resultados conformes com limite | 50 |
| Resultados nao conformes com limite | 7 |

Esses valores sao esperados apenas para o dataset didatico atual. Novas cargas validas podem alterar os totais.

## Validacoes necessarias antes e depois da exportacao

Antes da exportacao:

- consultar `dbo.VW_ConformidadeResultados`;
- validar total de 72 resultados analiticos na base didatica atual;
- validar 57 resultados com limite;
- validar 15 resultados sem limite;
- validar 50 resultados conformes com limite;
- validar 7 resultados nao conformes com limite;
- confirmar que resultados sem limite continuam presentes.

Depois da exportacao:

- confirmar existencia do arquivo em `exports/dados_conformidade_v2_1_0.csv`;
- confirmar cabecalho;
- confirmar contagem de linhas de dados;
- conferir encoding e separador;
- abrir uma previa do CSV em editor ou planilha;
- recalcular os indicadores a partir do CSV e comparar com a view;
- registrar evidencias visuais da exportacao e da conferencia.

## Evidencias visuais esperadas

Evidencias futuras sugeridas para a fase `v2.1.0`:

- consulta da view `dbo.VW_ConformidadeResultados`;
- validacao dos totais antes da exportacao;
- execucao da exportacao CSV;
- arquivo salvo em `exports/`;
- previa do CSV em editor ou planilha;
- validacao da contagem de linhas do CSV;
- validacao de que os indicadores do CSV batem com a view;
- documentacao final atualizada;
- README e CHANGELOG atualizados;
- tag e release `v2.1.0`, se a etapa for publicada.

## Limitacoes do contrato de dados

- Os limites de referencia sao didaticos e nao representam enquadramento legal ou normativo real.
- O CSV nao substitui o SQL Server como fonte oficial.
- O contrato nao implementa API, Power BI, dashboard completo ou deploy.
- O contrato nao implementa autenticacao, autorizacao ou seguranca corporativa.
- O contrato nao afirma integracao real com laboratorio externo.
- O contrato nao altera a view central nesta etapa.

## O que nao sera feito nesta fase

Ficam fora do escopo da `v2.1.0` no projeto principal:

- API REST dedicada;
- Power BI;
- frontend completo;
- autenticacao;
- deploy;
- Docker;
- CI/CD;
- automacao corporativa;
- integracao real com laboratorio externo;
- alteracao de regras de conformidade;
- alteracao estrutural das views oficiais sem necessidade real comprovada.

## Projetos derivados recomendados

Caso o projeto evolua, recomenda-se criar repositorios ou frentes separadas:

| Projeto derivado | Finalidade |
| --- | --- |
| `QualidadeAmbiental_API` | API dedicada em .NET, Node.js ou tecnologia equivalente. |
| `QualidadeAmbiental_PowerBI` | Camada semantica, medidas e relatorios executivos. |
| `QualidadeAmbiental_Dashboard` | Frontend web completo consumindo API dedicada. |
| `QualidadeAmbiental_DataOps` | Automacoes, testes de entrega, deploy e rotinas operacionais futuras. |

Esses projetos podem reutilizar o banco `QualidadeAmbiental`, mas nao devem ampliar indefinidamente o escopo do repositorio SQL Server principal.

## Criterio de encerramento do projeto principal

O projeto principal pode ser considerado concluido como portfolio tecnico SQL Server quando:

- o contrato de dados estiver documentado;
- a exportacao CSV didatica estiver planejada ou gerada conforme decisao da fase;
- os indicadores oficiais forem preservados;
- a documentacao deixar claro que o SQL Server e a fonte oficial;
- camadas como API dedicada, Power BI e dashboard completo forem tratadas como projetos derivados.

## Texto sugerido para status final do README

Texto recomendado para encerramento futuro:

> Status do projeto: concluido como portfolio tecnico SQL Server.
>
> O projeto cobre modelagem relacional, carga didatica, views analiticas, indices, plano de execucao, stored procedures, auditoria, backup/restore, staging de importacao, validacao de dados e contrato de dados para consumo externo.
>
> Evolucoes futuras, como API REST dedicada, Power BI, frontend completo ou deploy, devem ser tratadas como projetos derivados para evitar expansao indefinida do escopo.

## Resumo final

A fase `v2.1.0` fecha o projeto principal com uma ponte clara entre o SQL Server e consumidores externos. O banco permanece como fonte oficial, a view `dbo.VW_ConformidadeResultados` permanece como contrato analitico central e o CSV e tratado apenas como artefato didatico de consumo.

Essa abordagem preserva a clareza do portfolio, evita crescimento indefinido do repositorio e permite que novas frentes sejam desenvolvidas em projetos derivados, aproveitando o mesmo banco de dados criado.
