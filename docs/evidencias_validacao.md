# Evidencias de Validacao - QualidadeAmbiental_SQLServer

## Objetivo das evidencias

Este documento organiza as evidencias de validacao do projeto `QualidadeAmbiental_SQLServer`.

O objetivo e registrar quais scripts foram executados, quais validacoes foram confirmadas e quais prints devem ser capturados para comprovar visualmente que o banco `QualidadeAmbiental` foi executado e validado em ambiente real.

As evidencias visuais complementam os scripts SQL e a documentacao tecnica. Elas nao substituem os scripts oficiais, mas ajudam a demonstrar rastreabilidade, consistencia e maturidade do projeto em contexto de portfolio.

## Ambiente de validacao

Ambiente informado para validacao:

- Banco de dados: `QualidadeAmbiental`
- Banco restaurado/teste usado nas fases de restore e importacao: `QualidadeAmbiental_RestoreTeste`
- Plataforma: SQL Server
- Ferramenta de execucao e validacao: SQL Server Management Studio
- Projeto: `QualidadeAmbiental_SQLServer`

Os limites de referencia usados no projeto sao didaticos e nao representam comprovacao legal, regulatoria ou normativa real.

## Scripts validados

Os scripts oficiais foram executados na seguinte ordem:

| Ordem | Script | Finalidade |
| ---: | --- | --- |
| 1 | `sql/01_create_database.sql` | Criacao do banco de dados `QualidadeAmbiental`. |
| 2 | `sql/02_create_tables.sql` | Criacao das tabelas, chaves e constraints. |
| 3 | `sql/03_insert_cadastros.sql` | Insercao dos dados de cadastro e limites didaticos. |
| 4 | `sql/04_insert_amostras_resultados.sql` | Insercao de amostras e resultados analiticos. |
| 5 | `sql/05_views_oficiais.sql` | Criacao das views oficiais de analise. |
| 6 | `sql/06_consultas_analiticas.sql` | Execucao das consultas de validacao e relatorios analiticos. |
| 7 | `sql/migrations/2026-05-11_v1.1.0_indices_performance.sql` | Criacao e validacao de indices incrementais. |
| 8 | `sql/migrations/2026-05-12_v1.2.0_stored_procedures.sql` | Criacao e validacao de stored procedures analiticas parametrizadas. |
| 9 | `sql/migrations/2026-05-12_v1.3.0_auditoria_historico.sql` | Criacao e validacao de auditoria, historico e rastreabilidade. |
| 10 | `sql/migrations/2026-05-12_v1.4.0_backup_restore_validacao.sql` | Backup completo, verificacao do backup, restore em banco separado e validacao pos-recuperacao. |
| 11 | `sql/migrations/2026-05-13_v2.0.0_importacao_staging.sql` | Pipeline de importacao com lote, staging, validacao e carga controlada, validado em `QualidadeAmbiental_RestoreTeste`. |

## Checklist final confirmado

O checklist final do projeto confirmou os principais totais esperados:

| Validacao | Valor esperado | Status |
| --- | ---: | --- |
| Total de resultados analiticos | 72 | Confirmado |
| Resultados com limite | 57 | Confirmado |
| Resultados sem limite | 15 | Confirmado |
| Conformes com limite | 50 | Confirmado |
| Nao conformes com limite | 7 | Confirmado |

Esses resultados demonstram consistencia entre a carga de dados, a matriz de limites didaticos e a view central `VW_ConformidadeResultados`.

## Evidencias visuais registradas

As evidencias visuais devem ser salvas na pasta:

```text
docs/evidencias/
```

Os prints recomendados foram capturados e salvos na pasta `docs/evidencias/`.

## Relacao de prints registrados

| Arquivo | Consulta, script ou view relacionada | O que deve demonstrar | Status |
| --- | --- | --- | --- |
| `docs/evidencias/01_checklist_final_ok.png` | Checklist final de `sql/06_consultas_analiticas.sql` | Todos os itens do checklist final retornando `OK`. | Registrado |
| `docs/evidencias/02_validacao_conformidade.png` | Validacao consolidada da conformidade | Totais de 72 resultados, 57 com limite, 15 sem limite, 50 conformes e 7 nao conformes. | Registrado |
| `docs/evidencias/03_resultados_fora_padrao.png` | `VW_ResultadosForaDoPadrao` | Resultados classificados como `Acima do limite maximo` ou `Abaixo do limite minimo`. | Registrado |
| `docs/evidencias/04_resultados_sem_limite.png` | `VW_ResultadosSemLimiteReferencia` | Resultados classificados como `Sem limite de referencia`. | Registrado |
| `docs/evidencias/05_conformidade_mensal.png` | `VW_ConformidadeMensal` | Indicadores mensais de conformidade com limite e resultados sem limite. | Registrado |
| `docs/evidencias/06_ranking_parametros_criticos.png` | `VW_RankingParametrosCriticos` | Ranking de parametros por nao conformidades e percentual de nao conformidade. | Registrado |
| `docs/evidencias/07_eficiencia_remocao_ete.png` | `VW_EficienciaRemocaoETE` | Percentual de remocao entre `Esgoto Bruto` e `Esgoto Tratado` pelo mesmo parametro e mesma data de coleta. | Registrado |
| `docs/evidencias/08_views_oficiais_ssms.png` | Views criadas no SSMS | Existencia das views oficiais no banco `QualidadeAmbiental`. | Registrado |

## Evidencias da v1.1.0 - Indices e performance

A fase `v1.1.0` adicionou evidencias visuais especificas para validar a criacao dos indices, a estrutura das colunas, a preservacao dos indicadores finais e a analise de plano de execucao real no SQL Server Management Studio.

| Arquivo | Consulta, script ou recurso relacionado | O que demonstra | Status |
| --- | --- | --- | --- |
| `docs/evidencias/09_indices_v1_1_criados.png` | `sys.indexes` apos a migration `v1.1.0` | Confirma a existencia dos indices `IX_Tbl_Amostras_DataColeta_Tipo_Ponto` e `IX_Tbl_ResultadosAnalise_Parametro_Amostra`, ambos ativos. | Registrado |
| `docs/evidencias/10_indices_v1_1_colunas.png` | `sys.index_columns` e `sys.columns` | Confirma as colunas-chave e colunas incluidas dos indices criados na fase `v1.1.0`. | Registrado |
| `docs/evidencias/11_validacao_totais_pos_indices.png` | Validacao consolidada de `VW_ConformidadeResultados` | Confirma que os totais analiticos permaneceram consistentes apos a criacao dos indices: 72 resultados, 57 com limite, 15 sem limite, 50 conformes e 7 nao conformes. | Registrado |
| `docs/evidencias/12_plano_execucao_ranking_parametros.png` | Plano de execucao real de consulta sobre `VW_RankingParametrosCriticos` | Demonstra a analise do plano de execucao real para ranking de parametros criticos. | Registrado |
| `docs/evidencias/13_plano_execucao_eficiencia_ete.png` | Plano de execucao real de consulta sobre `VW_EficienciaRemocaoETE` | Demonstra a analise do plano de execucao real para eficiencia de remocao da ETE. | Registrado |

Essas evidencias nao comprovam ganho formal de tempo de execucao. Como o dataset atual e didatico e pequeno, elas devem ser interpretadas como validacao tecnica dos indices, da consistencia dos resultados e do processo de analise de plano de execucao.

## Evidencias da v1.2.0 - Stored procedures

A fase `v1.2.0` adicionou evidencias visuais especificas para validar a criacao das stored procedures analiticas parametrizadas, suas execucoes com parametros validos e o tratamento de erros esperado.

| Arquivo | Consulta, script ou recurso relacionado | O que demonstra | Status |
| --- | --- | --- | --- |
| `docs/evidencias/14_procedures_v1_2_criadas.png` | `sys.procedures` apos a migration `v1.2.0` | Confirma a existencia de `usp_ConformidadePorPeriodo`, `usp_ResultadosForaPadrao` e `usp_RankingParametrosCriticos`. | Registrado |
| `docs/evidencias/15_exec_usp_conformidade_por_periodo.png` | `dbo.usp_ConformidadePorPeriodo` | Confirma os totais consolidados para periodo valido: 72 resultados, 57 com limite, 15 sem limite, 50 conformes e 7 nao conformes. | Registrado |
| `docs/evidencias/16_exec_usp_resultados_fora_padrao.png` | `dbo.usp_ResultadosForaPadrao` | Confirma a listagem de 7 resultados fora do padrao no periodo validado. | Registrado |
| `docs/evidencias/17_exec_usp_ranking_parametros_criticos.png` | `dbo.usp_RankingParametrosCriticos` | Confirma o ranking parametrizado com `@TopN = 5`. | Registrado |
| `docs/evidencias/18_validacao_erro_periodo_invalido.png` | `THROW` em `dbo.usp_ConformidadePorPeriodo` | Confirma a validacao de erro quando `@DataInicio` e maior que `@DataFim`. | Registrado |
| `docs/evidencias/19_validacao_erro_topn_invalido.png` | `THROW` em `dbo.usp_RankingParametrosCriticos` | Confirma a validacao de erro quando `@TopN` e menor ou igual a zero. | Registrado |

Essas evidencias demonstram que as procedures foram criadas, executadas e validadas sem introduzir rotinas de escrita ou regras paralelas de conformidade.

## Evidencias da v1.3.0 - Auditoria, historico e rastreabilidade

A fase `v1.3.0` adicionou evidencias visuais especificas para validar a tabela de auditoria, as triggers, os eventos auditados e a preservacao dos indicadores finais.

| Arquivo | Consulta, script ou recurso relacionado | O que demonstra | Status |
| --- | --- | --- | --- |
| `docs/evidencias/20_tabela_auditoria_criada.png` | `sys.tables` apos a migration `v1.3.0` | Confirma a existencia de `dbo.Tbl_AuditoriaAlteracoes`. | Registrado |
| `docs/evidencias/21_triggers_auditoria_criadas.png` | `sys.triggers` apos a migration `v1.3.0` | Confirma as triggers de auditoria criadas e ativas. | Registrado |
| `docs/evidencias/22_update_auditado_resultados_analise.png` | `dbo.Tbl_ResultadosAnalise` e `dbo.Tbl_AuditoriaAlteracoes` | Confirma `UPDATE` auditado em resultado analitico. | Registrado |
| `docs/evidencias/23_update_auditado_limites_referencia.png` | `dbo.Tbl_LimitesReferencia` e `dbo.Tbl_AuditoriaAlteracoes` | Confirma `UPDATE` auditado em limite de referencia. | Registrado |
| `docs/evidencias/24_update_auditado_amostras.png` | `dbo.Tbl_Amostras` e `dbo.Tbl_AuditoriaAlteracoes` | Confirma `UPDATE` auditado em amostra. | Registrado |
| `docs/evidencias/25_consulta_geral_auditoria.png` | `dbo.Tbl_AuditoriaAlteracoes` | Exibe eventos de auditoria registrados com metadados e snapshots. | Registrado |
| `docs/evidencias/26_validacao_indicadores_pos_auditoria.png` | `dbo.VW_ConformidadeResultados` | Confirma que os indicadores finais permaneceram consistentes apos a auditoria. | Registrado |

Totais confirmados na auditoria:

| Tabela | Operacao | Total de eventos |
| --- | --- | ---: |
| `Tbl_ResultadosAnalise` | `UPDATE` | 2 |
| `Tbl_LimitesReferencia` | `UPDATE` | 4 |
| `Tbl_Amostras` | `UPDATE` | 2 |

Total de eventos registrados: 8.

## Evidencias da v1.4.0 - Backup, restore e validacao pos-recuperacao

A fase `v1.4.0` adicionou evidencias visuais para validar backup completo, verificacao do arquivo `.bak`, inspecao dos arquivos logicos, restore em banco separado e validacao pos-recuperacao.

O backup foi gerado fora do repositorio Git, em caminho local:

```text
C:\SQLBackups\QualidadeAmbiental\
```

O banco restaurado usado para validacao foi:

```text
QualidadeAmbiental_RestoreTeste
```

| Arquivo | Consulta, script ou recurso relacionado | O que demonstra | Status |
| --- | --- | --- | --- |
| `docs/evidencias/27_backup_executado_sucesso.png` | `BACKUP DATABASE` | Confirma execucao do backup completo do banco `QualidadeAmbiental`. | Registrado |
| `docs/evidencias/28_restore_verifyonly_sucesso.png` | `RESTORE VERIFYONLY` | Confirma verificacao do arquivo de backup. | Registrado |
| `docs/evidencias/29_restore_filelistonly_logical_names.png` | `RESTORE FILELISTONLY` | Exibe os nomes logicos dos arquivos do backup. | Registrado |
| `docs/evidencias/30_restore_executado_sucesso.png` | `RESTORE DATABASE` manual com `WITH MOVE` | Confirma restore em `QualidadeAmbiental_RestoreTeste`. | Registrado |
| `docs/evidencias/31_banco_restore_teste_visivel.png` | Object Explorer do SSMS | Confirma o banco restaurado visivel no SSMS. | Registrado |
| `docs/evidencias/32_validacao_tabelas_restore.png` | Catalogo do SQL Server | Confirma as tabelas principais restauradas. | Registrado |
| `docs/evidencias/33_validacao_views_restore.png` | Catalogo do SQL Server | Confirma as views oficiais restauradas. | Registrado |
| `docs/evidencias/34_validacao_procedures_restore.png` | `sys.procedures` | Confirma as procedures da v1.2.0 restauradas. | Registrado |
| `docs/evidencias/35_validacao_auditoria_restore.png` | `sys.tables` e `sys.triggers` | Confirma tabela e triggers de auditoria restauradas. | Registrado |
| `docs/evidencias/36_validacao_indices_restore.png` | `sys.indexes` | Confirma indices da v1.1.0 restaurados. | Registrado |
| `docs/evidencias/37_validacao_indicadores_restore.png` | `VW_ConformidadeResultados` no banco restaurado | Confirma indicadores finais preservados apos restore. | Registrado |

Validacoes confirmadas no banco restaurado:

| Validacao | Valor confirmado |
| --- | ---: |
| Tabelas principais | 8 |
| Views oficiais | 6 |
| Procedures | 3 |
| Triggers de auditoria ativas | 3 |
| Indices incrementais ativos | 2 |
| Tabela de auditoria | 1 |

Indicadores confirmados no banco restaurado:

| Indicador | Valor confirmado |
| --- | ---: |
| Total de resultados analiticos | 72 |
| Resultados com limite | 57 |
| Resultados sem limite | 15 |
| Conformes com limite | 50 |
| Nao conformes com limite | 7 |

## Evidencias da v2.0.0 - Pipeline de importacao com staging e validacao

A fase `v2.0.0` adicionou evidencias visuais para validar a criacao dos objetos de importacao, o recebimento de dados brutos em staging, a classificacao de registros invalidos, os bloqueios de carga indevida e a preservacao dos indicadores finais.

A validacao foi executada no banco restaurado/teste:

```text
QualidadeAmbiental_RestoreTeste
```

O banco principal `QualidadeAmbiental` nao foi alterado durante a validacao da fase.

| Arquivo | Consulta, script ou recurso relacionado | O que demonstra | Status |
| --- | --- | --- | --- |
| `docs/evidencias/38_tabelas_importacao_criadas.png` | `sys.tables` apos a migration `v2.0.0` | Confirma a existencia de `dbo.Tbl_LotesImportacao` e `dbo.Stg_ResultadosAnaliseImportacao`. | Registrado |
| `docs/evidencias/39_procedures_importacao_criadas.png` | `sys.procedures` apos a migration `v2.0.0` | Confirma a existencia de `dbo.usp_ValidarStgResultadosAnalise` e `dbo.usp_CarregarResultadosAnaliseValidados`. | Registrado |
| `docs/evidencias/40_indice_staging_criado.png` | `sys.indexes` | Confirma o indice `IX_Stg_ResultadosAnaliseImportacao_Lote_Status`, ativo e nao unico. | Registrado |
| `docs/evidencias/41_constraints_importacao_criadas.png` | `sys.check_constraints` e `sys.foreign_keys` | Confirma checks de status, integridade basica e FK da staging para lotes, todas habilitadas. | Registrado |
| `docs/evidencias/42_lote_importacao_criado.png` | `dbo.Tbl_LotesImportacao` | Confirma lote didatico criado com `IdLoteImportacao = 1` e status inicial `ABERTO`. | Registrado |
| `docs/evidencias/43_dados_brutos_staging_carregados.png` | `dbo.Stg_ResultadosAnaliseImportacao` | Confirma 7 linhas recebidas na staging com status inicial `PENDENTE`. | Registrado |
| `docs/evidencias/44_validacao_lote_staging.png` | `dbo.usp_ValidarStgResultadosAnalise` | Confirma validacao do lote, 7 linhas `INVALIDO`, lote `VALIDADO` e totais `7 / 0 / 7 / 0`. | Registrado |
| `docs/evidencias/45_registros_invalidos_staging.png` | Consulta da staging por status | Confirma os registros invalidos e suas mensagens de validacao. | Registrado |
| `docs/evidencias/46_bloqueio_carga_sem_confirmacao.png` | `dbo.usp_CarregarResultadosAnaliseValidados` com `@ConfirmarCarga = 0` | Confirma bloqueio operacional da carga sem confirmacao explicita. | Registrado |
| `docs/evidencias/47_bloqueio_carga_com_invalidos.png` | `dbo.usp_CarregarResultadosAnaliseValidados` com `@ConfirmarCarga = 1` | Confirma bloqueio da carga quando o lote possui registros `INVALIDO`. | Registrado |
| `docs/evidencias/48_invalidos_nao_carregados_tabela_final.png` | `dbo.Tbl_ResultadosAnalise` e staging | Confirma que invalidos permaneceram na staging e que `dbo.Tbl_ResultadosAnalise` permaneceu com 72 registros. | Registrado |
| `docs/evidencias/49_indicadores_pos_validacao_staging.png` | `dbo.VW_ConformidadeResultados` | Confirma preservacao dos indicadores finais: 72 resultados, 57 com limite, 15 sem limite, 50 conformes e 7 nao conformes. | Registrado |

Validacoes confirmadas na v2.0.0:

| Validacao | Valor confirmado |
| --- | ---: |
| Linhas recebidas na staging | 7 |
| Linhas validas | 0 |
| Linhas invalidas | 7 |
| Linhas carregadas | 0 |
| Total em `dbo.Tbl_ResultadosAnalise` apos validacao | 72 |

Nao houve carga final de registros validos nesta rodada. Esse comportamento e esperado, porque a base didatica atual ja possui as combinacoes reais de 6 amostras x 12 parametros em `dbo.Tbl_ResultadosAnalise`. A evidencia da fase demonstra seguranca operacional: dados brutos retidos na staging, inconsistencias identificadas, cargas indevidas bloqueadas e indicadores oficiais preservados.

## Como capturar os prints no SSMS

Procedimento recomendado:

1. Abrir o SQL Server Management Studio.
2. Conectar ao servidor onde o banco `QualidadeAmbiental` foi criado.
3. Selecionar o banco `QualidadeAmbiental`.
4. Abrir o script `sql/06_consultas_analiticas.sql`.
5. Executar a consulta ou bloco correspondente a evidencia desejada.
6. Ajustar a grade de resultados para mostrar os campos principais.
7. Capturar o print da tela.
8. Salvar o arquivo na pasta `docs/evidencias/` usando o nome padronizado neste documento.
9. Atualizar o status do print de `Pendente` para `Registrado`, quando uma nova evidencia for adicionada.

Para a evidencia das views oficiais, recomenda-se capturar a arvore de objetos do SSMS mostrando as views criadas no banco.

## Como interpretar as evidencias

As evidencias devem ser interpretadas como comprovacao tecnica de execucao e consistencia interna do projeto.

Leituras esperadas:

- O checklist final com `OK` indica que os totais planejados foram atingidos.
- A validacao consolidada demonstra que a view central esta classificando os resultados conforme esperado.
- Os prints de resultados fora do padrao mostram os registros didaticamente nao conformes.
- Os prints de resultados sem limite demonstram que o `LEFT JOIN` preserva resultados sem referencia cadastrada.
- O ranking de parametros criticos mostra capacidade de analise agregada.
- A eficiencia de remocao da ETE demonstra comparacao entre entrada e saida por parametro e data.

As evidencias nao devem ser interpretadas como laudo ambiental, parecer tecnico oficial ou comprovacao normativa real.

## Limitacoes das evidencias

- Prints sao evidencias visuais e dependem do ambiente onde foram capturados.
- As evidencias confirmam consistencia tecnica do projeto, nao validade normativa dos limites.
- Os dados e limites sao didaticos.
- Prints podem ficar desatualizados caso os scripts ou dados sejam alterados.
- A ausencia de um print nao invalida os scripts, mas reduz a rastreabilidade visual do portfolio.

## Proximos passos

- Manter os prints na pasta `docs/evidencias/` com os nomes padronizados.
- Conferir periodicamente se as evidencias continuam coerentes com os scripts oficiais.
- Atualizar este documento caso novas evidencias sejam adicionadas.
- Atualizar o README futuramente, se for necessario apontar para este documento.
- Versionar as evidencias visuais junto com este documento.

## Resumo final

Este documento prepara a estrutura de evidencias de validacao do `QualidadeAmbiental_SQLServer`.

Ele registra os scripts executados, os resultados finais confirmados e os prints recomendados para demonstrar que o banco foi criado, carregado, analisado e validado no SQL Server Management Studio.

Com as evidencias visuais capturadas, o projeto ganha uma camada adicional de rastreabilidade e fica mais forte para apresentacao em portfolio e entrevistas tecnicas.
