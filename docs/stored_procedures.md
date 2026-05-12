# Stored Procedures Analiticas Parametrizadas - v1.2.0

## 1. Objetivo da fase v1.2.0

A fase `v1.2.0` tem como objetivo planejar, implementar e validar stored procedures analiticas parametrizadas para o projeto `QualidadeAmbiental_SQLServer`.

O planejamento orientou a criacao de um conjunto pequeno, funcional e justificavel de rotinas no script:

```text
sql/migrations/2026-05-12_v1.2.0_stored_procedures.sql
```

As procedures criadas apoiam consultas recorrentes, filtros analiticos, validacoes de entrada e geracao de evidencias no SQL Server Management Studio.

## 2. Situacao atual do projeto

O projeto ja possui a versao `v1.0.0` publicada com estrutura relacional, dados didaticos, views oficiais, consultas analiticas, documentacao e evidencias.

A versao `v1.1.0` adicionou indices incrementais e documentacao de performance, sem alterar a logica analitica dos dados. Os indicadores finais permaneceram consistentes:

| Indicador | Valor confirmado |
| --- | ---: |
| Total de resultados analiticos | 72 |
| Resultados com limite | 57 |
| Resultados sem limite | 15 |
| Conformes com limite | 50 |
| Nao conformes com limite | 7 |

A camada analitica oficial esta baseada principalmente na view `dbo.VW_ConformidadeResultados`, usada como base para resultados fora do padrao, resultados sem limite, conformidade mensal, ranking de parametros criticos e eficiencia de remocao da ETE.

## 3. Por que usar stored procedures

Stored procedures fazem sentido nesta fase quando ajudam a transformar consultas analiticas recorrentes em rotinas controladas, com parametros, validacoes e padrao de saida.

No contexto deste projeto, elas podem agregar valor ao:

- centralizar consultas analiticas frequentemente executadas;
- permitir filtros por periodo, ponto de coleta, tipo de amostra ou parametro;
- validar entradas antes da execucao;
- padronizar resultados para evidencias no SSMS;
- reduzir repeticao de consultas longas em demonstracoes tecnicas.

Stored procedures nao devem ser apresentadas como melhoria automatica de performance. O ganho esperado nesta fase e de organizacao, reutilizacao, controle de parametros e clareza operacional.

## 4. Diferenca entre views, consultas e stored procedures

Views sao a camada semantica oficial do projeto. Elas consolidam regras de negocio, classificacoes e indicadores reutilizaveis.

Consultas analiticas sao comandos `SELECT` usados para validacao, auditoria e demonstracao dos resultados produzidos pelas views.

Stored procedures devem ficar acima dessas camadas, quando houver necessidade de execucao parametrizada, validacao de entrada ou padronizacao de um relatorio recorrente. Elas nao substituem as views oficiais e devem preferencialmente reutiliza-las.

## 5. Criterios para definir uma candidata forte

Uma procedure so deve ser candidata forte para a v1.2.0 se tiver valor funcional claro no projeto atual.

Os criterios adotados sao:

- possuir parametro util ou validacao real;
- responder a uma analise recorrente ja documentada;
- reutilizar views oficiais ou consultas analiticas existentes;
- gerar uma saida adequada para evidencia no SSMS;
- evitar duplicacao desnecessaria de logica;
- deixar claro por que uma view simples nao seria suficiente;
- priorizar clareza, valor funcional e aderencia ao projeto atual.

Se uma procedure nao tiver parametro util, validacao real ou ganho claro sobre uma view simples, ela deve ser adiada ou descartada.

## 6. Procedures implementadas

Para a fase `v1.2.0`, foram implementadas as seguintes procedures:

1. `dbo.usp_ConformidadePorPeriodo`
2. `dbo.usp_ResultadosForaPadrao`
3. `dbo.usp_RankingParametrosCriticos`

Essas tres procedures estao alinhadas as views oficiais, aproveitam regras ja implementadas e possuem parametros com utilidade real.

## 7. Justificativa tecnica das candidatas escolhidas

| Procedure candidata | Fonte tecnica | Motivo da escolha | Parametros previstos | Valor real agregado | Evidencia esperada no SSMS | Risco tecnico residual |
| --- | --- | --- | --- | --- | --- | --- |
| `dbo.usp_ConformidadePorPeriodo` | `dbo.VW_ConformidadeResultados`, consulta de validacao consolidada e `dbo.VW_ConformidadeMensal` | Permite consolidar conformidade em intervalo definido pelo usuario, com validacao de datas. Uma view simples nao e suficiente porque nao valida periodo nem encapsula o filtro temporal de execucao recorrente. | `@DataInicio`, `@DataFim`, `@IdTipoAmostra`, `@IdPontoColeta` | Padroniza a analise de conformidade por recorte temporal e filtros opcionais. | Execucao com periodo valido, execucao sem filtros opcionais e teste de periodo invalido. | Baixo. Deve evitar duplicar a view mensal quando o objetivo for apenas leitura mensal fixa. |
| `dbo.usp_ResultadosForaPadrao` | `dbo.VW_ResultadosForaDoPadrao` e consulta 5 de `sql/06_consultas_analiticas.sql` | A lista de nao conformidades e uma consulta recorrente e operacionalmente relevante. Uma view simples lista todos os casos, mas a procedure pode aplicar filtros padronizados por periodo, ponto, tipo de amostra e parametro. | `@DataInicio`, `@DataFim`, `@IdPontoColeta`, `@IdTipoAmostra`, `@IdParametro` | Facilita investigacao direcionada de resultados acima ou abaixo dos limites didaticos. | Execucao listando nao conformidades filtradas e ordenadas para analise. | Baixo. Deve manter a classificacao oficial da view, sem recalcular regras em paralelo. |
| `dbo.usp_RankingParametrosCriticos` | `dbo.VW_RankingParametrosCriticos` e consulta 8 de `sql/06_consultas_analiticas.sql` | O ranking ganha valor com `TOP N` e filtros por periodo, tipo de amostra ou ponto. Uma view simples nao recebe limite de ranking nem recorte dinamico. | `@TopN`, `@DataInicio`, `@DataFim`, `@IdTipoAmostra`, `@IdPontoColeta` | Apoia priorizacao analitica dos parametros com maior nao conformidade. | Execucao com `@TopN` valido e comparacao visual da ordenacao por criticidade. | Medio. Pode exigir consulta agregada sobre `VW_ConformidadeResultados`, pois a view atual de ranking nao possui periodo nem ponto de coleta. |

## 8. Ideias descartadas ou adiadas nesta fase

| Ideia avaliada | Motivo para nao entrar como candidata | Risco de artificialidade ou duplicacao | Condicao futura para reconsiderar |
| --- | --- | --- | --- |
| `dbo.usp_ResumoConformidadeGeral` | O resumo geral ja esta bem representado nas consultas de validacao e pode virar apenas um `SELECT` agregado sem parametro relevante. | Alto, caso apenas replique a validacao consolidada ja existente. | Reconsiderar se houver necessidade de uma saida executiva padronizada com multiplos blocos ou comparacoes entre periodos. |
| `dbo.usp_ResultadosSemLimiteReferencia` | O relatorio e importante para governanca dos dados, mas nesta fase e melhor manter como view e consulta analitica. | Medio, pois `dbo.VW_ResultadosSemLimiteReferencia` ja expoe diretamente os registros. | Reconsiderar se a fase passar a incluir rotina formal de auditoria de limites por periodo, tipo de amostra ou parametro. |
| `dbo.usp_EficienciaRemocaoETE` | A regra ja esta encapsulada em `dbo.VW_EficienciaRemocaoETE`. A procedure poderia ser util, mas nao e prioridade frente as tres rotinas de conformidade e criticidade. | Medio, se apenas fizer `SELECT` da view sem parametros ou validacoes. | Reconsiderar quando houver necessidade de filtro por periodo, parametro ou padronizacao especifica da analise de entrada e saida da ETE. |

## 9. Parametros previstos

Os parametros devem ser opcionais quando fizer sentido, permitindo consulta geral quando informados como `NULL`.

| Parametro | Uso previsto |
| --- | --- |
| `@DataInicio` | Filtrar resultados a partir de uma data de coleta inicial. |
| `@DataFim` | Filtrar resultados ate uma data de coleta final. |
| `@IdPontoColeta` | Restringir analise a um ponto de coleta especifico. |
| `@IdTipoAmostra` | Restringir analise a um tipo de amostra especifico. |
| `@IdParametro` | Restringir listagens a um parametro ambiental especifico. |
| `@TopN` | Limitar quantidade de linhas retornadas no ranking de parametros criticos. |

O parametro `@SomenteNaoConformes` nao deve ser usado nas candidatas iniciais porque a procedure `dbo.usp_ResultadosForaPadrao` ja representa esse recorte de forma explicita.

## 10. Validacoes de parametros

A implementacao realizada considera:

- `@DataInicio` nao pode ser maior que `@DataFim`;
- `@TopN` deve ser positivo quando informado;
- parametros opcionais devem permitir consulta geral quando vierem `NULL`;
- filtros por IDs devem respeitar as colunas existentes nas views oficiais;
- nenhuma procedure deve alterar dados;
- nenhuma procedure deve criar regra de conformidade fora das views oficiais.

Validacoes de existencia de IDs foram mantidas fora desta fase para nao transformar procedures analiticas simples em rotinas excessivamente verbosas.

## 11. Padrao tecnico aplicado

O script `sql/migrations/2026-05-12_v1.2.0_stored_procedures.sql` segue um padrao consistente:

- usar `CREATE OR ALTER PROCEDURE`;
- usar schema explicito `dbo`;
- usar prefixo `usp_`;
- usar `SET NOCOUNT ON`;
- declarar parametros com tipos compativeis com as tabelas atuais;
- documentar comportamento de parametros opcionais;
- preferir as views oficiais como fonte de dados;
- manter comentarios tecnicos curtos e uteis;
- ordenar resultados de forma previsivel para evidencias.

Nao deve ser usado prefixo `SP_` ou `sp_`.

## 12. Validacao no SSMS

A migration `sql/migrations/2026-05-12_v1.2.0_stored_procedures.sql` foi executada e validada manualmente no SQL Server Management Studio.

Validacoes realizadas:

- criacao das tres procedures confirmada em `sys.procedures`;
- execucao de `dbo.usp_ConformidadePorPeriodo` com periodo valido;
- execucao de `dbo.usp_ResultadosForaPadrao` com periodo valido;
- execucao de `dbo.usp_RankingParametrosCriticos` com `@TopN` valido e periodo valido;
- validacao de erro para `@DataInicio` maior que `@DataFim`;
- validacao de erro para `@TopN` menor ou igual a zero;
- confirmacao de que as saidas permanecem coerentes com as views oficiais e indicadores documentados.

## 13. Estrategia de evidencias visuais

As evidencias visuais da v1.2.0 registram:

- criacao bem-sucedida das procedures no SSMS;
- execucao de `dbo.usp_ConformidadePorPeriodo`;
- execucao de `dbo.usp_ResultadosForaPadrao`;
- execucao de `dbo.usp_RankingParametrosCriticos`;
- validacao de erro para periodo invalido;
- validacao de erro para `@TopN` invalido;
- comparacao dos resultados com as views ou consultas analiticas oficiais.

Os prints foram salvos em `docs/evidencias/`, seguindo a numeracao ja usada nas fases anteriores.

| Arquivo | Evidencia |
| --- | --- |
| `docs/evidencias/14_procedures_v1_2_criadas.png` | Procedures criadas e confirmadas em `sys.procedures`. |
| `docs/evidencias/15_exec_usp_conformidade_por_periodo.png` | Execucao de `dbo.usp_ConformidadePorPeriodo` com periodo valido. |
| `docs/evidencias/16_exec_usp_resultados_fora_padrao.png` | Execucao de `dbo.usp_ResultadosForaPadrao` com periodo valido. |
| `docs/evidencias/17_exec_usp_ranking_parametros_criticos.png` | Execucao de `dbo.usp_RankingParametrosCriticos` com `@TopN` valido. |
| `docs/evidencias/18_validacao_erro_periodo_invalido.png` | Validacao de erro para periodo invalido. |
| `docs/evidencias/19_validacao_erro_topn_invalido.png` | Validacao de erro para `@TopN` invalido. |

## 14. Riscos de criar procedures artificiais

O principal risco da v1.2.0 e criar objetos que apenas embrulham views sem ganho tecnico.

Esse risco deve ser evitado porque:

- aumenta o volume de objetos sem necessidade;
- dificulta manutencao futura;
- pode duplicar regras ja centralizadas nas views;
- enfraquece a narrativa tecnica do portfolio;
- passa a impressao de criacao artificial de escopo.

Por isso, a fase deve permanecer enxuta e priorizar procedures com parametros, validacoes e uso recorrente demonstravel.

## 15. Entregas realizadas na v1.2.0

As entregas realizadas sao:

- documento de planejamento `docs/stored_procedures.md`;
- script `sql/migrations/2026-05-12_v1.2.0_stored_procedures.sql`;
- criacao das procedures analiticas recomendadas;
- validacoes no SSMS;
- evidencias visuais da criacao, execucao e validacoes de erro;
- atualizacao de `README.md` e `CHANGELOG.md` apos implementacao e validacao.

## 16. Limitacoes atuais

As limitacoes que devem orientar a v1.2.0 sao:

- o volume de dados e didatico;
- os limites de referencia nao representam norma real;
- nao ha fluxo transacional completo para procedures operacionais de escrita;
- nao ha auditoria nem historico de alteracoes;
- nao ha vigencia temporal de limites;
- algumas analises, como eficiencia da ETE, ja estao bem encapsuladas em view e nao devem ser duplicadas sem necessidade.

## 17. Resumo final

A v1.2.0 criou poucas stored procedures, todas analiticas, parametrizadas e alinhadas as views oficiais.

As procedures implementadas sao:

- `dbo.usp_ConformidadePorPeriodo`;
- `dbo.usp_ResultadosForaPadrao`;
- `dbo.usp_RankingParametrosCriticos`.

Elas foram escolhidas porque possuem uso recorrente, parametros uteis, possibilidade de validacao e valor claro para evidencias no SSMS.

As ideias `dbo.usp_ResumoConformidadeGeral`, `dbo.usp_ResultadosSemLimiteReferencia` e `dbo.usp_EficienciaRemocaoETE` devem ser adiadas nesta fase para evitar duplicacao de views ou criacao de objetos sem necessidade imediata.

Com esse recorte, a fase `v1.2.0` reforca criterio tecnico: cria procedures quando elas resolvem um problema real de consulta parametrizada e evita objetos artificiais sem ganho para o projeto.
