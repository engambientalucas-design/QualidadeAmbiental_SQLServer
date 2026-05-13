# CHANGELOG - QualidadeAmbiental_SQLServer

Todas as mudanças relevantes deste projeto devem ser registradas neste arquivo.

O formato segue uma organização simples por versão, com foco em clareza para portfólio, revisão técnica e continuidade do desenvolvimento.

## [v1.0.0] - 2026-05-11 - Publicação inicial

Versão inicial publicável do projeto `QualidadeAmbiental_SQLServer`.

### Adicionado

- Estrutura principal do banco de dados SQL Server.
- Scripts oficiais em `sql/` para criação do banco, criação das tabelas, carga de cadastros, carga de amostras/resultados, views oficiais e consultas analíticas.
- Modelo relacional com 8 tabelas principais:
  - `Tbl_Responsaveis`
  - `Tbl_StatusAmostra`
  - `Tbl_TiposAmostra`
  - `Tbl_PontosColeta`
  - `Tbl_Parametros`
  - `Tbl_Amostras`
  - `Tbl_ResultadosAnalise`
  - `Tbl_LimitesReferencia`
- Dados didáticos para monitoramento de qualidade de água e esgoto.
- Views oficiais para conformidade, resultados fora do padrão, resultados sem limite, conformidade mensal, ranking de parâmetros críticos e eficiência de remoção da ETE.
- Consultas analíticas e checklist final de validação.
- Documentação técnica em `docs/`.
- Evidências visuais de execução e validação em `docs/evidencias/`.

### Validado

- Total de amostras: 6.
- Total de resultados analíticos: 72.
- Resultados com limite: 57.
- Resultados sem limite: 15.
- Conformes com limite: 50.
- Não conformes com limite: 7.

### Observações

- Os limites de referência cadastrados são didáticos e não devem ser tratados como base legal ou normativa real.
- A constraint de unicidade por amostra e parâmetro atende ao escopo atual, mas pode exigir revisão em uma fase futura caso o projeto passe a registrar replicatas, contraprovas ou reanálises.

## [v1.1.0] - 2026-05-11 - Índices e performance

Fase dedicada a índices, performance e análise de plano de execução.

### Adicionado

- Script incremental `sql/migrations/2026-05-11_v1.1.0_indices_performance.sql`.
- Índice `IX_Tbl_Amostras_DataColeta_Tipo_Ponto` para apoiar análises por data de coleta, tipo de amostra e ponto de coleta.
- Índice `IX_Tbl_ResultadosAnalise_Parametro_Amostra` para complementar a unicidade existente e favorecer análises que partem de parâmetro ambiental.
- Consultas de verificação dos índices criados via catálogo do SQL Server.
- Documento `docs/performance_indices.md` com justificativas, trade-offs e orientações de análise de plano de execução.
- Evidências visuais da fase `v1.1.0` em `docs/evidencias/`, cobrindo criação dos índices, colunas, validação dos totais e planos de execução.

### Validado

- Migration `sql/migrations/2026-05-11_v1.1.0_indices_performance.sql` executada com sucesso no SQL Server Management Studio.
- Índices confirmados em `sys.indexes`, com `is_disabled = 0`.
- Colunas-chave e colunas incluídas confirmadas em `sys.index_columns`.
- Indicadores finais permaneceram consistentes após a criação dos índices: 72 resultados analíticos, 57 com limite, 15 sem limite, 50 conformes e 7 não conformes.
- Plano de execução real analisado no SSMS para consultas analíticas como ranking de parâmetros críticos e eficiência de remoção da ETE.
- Prints `09` a `13` registrados para comprovar visualmente a validação da fase.

### Observações

- Os índices foram definidos de forma conservadora, priorizando tabelas operacionais e consultas analíticas reais.
- Não foram criados índices indiscriminados em colunas textuais ou calculadas.
- Não foi feita medição formal de ganho de tempo. Como o volume atual é didático e pequeno, não é adequado afirmar ganho real de performance.
- O objetivo principal é demonstrar critério técnico de DBA, validação por catálogo do SQL Server e análise de plano de execução.

## [v1.2.0] - 2026-05-12 - Stored procedures analíticas parametrizadas

Fase dedicada a stored procedures analíticas parametrizadas, com foco em rotinas úteis, validações de entrada e evidências no SQL Server Management Studio.

### Adicionado

- Documento `docs/stored_procedures.md` com planejamento, critérios técnicos, procedures escolhidas, ideias adiadas e estratégia de evidências.
- Script incremental `sql/migrations/2026-05-12_v1.2.0_stored_procedures.sql`.
- Procedure `dbo.usp_ConformidadePorPeriodo` para consolidar indicadores de conformidade por período e filtros opcionais.
- Procedure `dbo.usp_ResultadosForaPadrao` para listar resultados acima ou abaixo dos limites didáticos com filtros opcionais.
- Procedure `dbo.usp_RankingParametrosCriticos` para gerar ranking parametrizado de parâmetros críticos com `@TopN`.
- Validações com `THROW` para período inválido e `@TopN` menor ou igual a zero.
- Evidências visuais da fase `v1.2.0` em `docs/evidencias/`, cobrindo criação das procedures, execuções válidas e validações de erro.

### Validado

- Migration `sql/migrations/2026-05-12_v1.2.0_stored_procedures.sql` executada com sucesso no SQL Server Management Studio.
- Procedures confirmadas em `sys.procedures`.
- `dbo.usp_ConformidadePorPeriodo` retornou os totais consolidados esperados: 72 resultados analíticos, 57 com limite, 15 sem limite, 50 conformes com limite e 7 não conformes.
- `dbo.usp_ResultadosForaPadrao` retornou 7 resultados fora do padrão no período validado.
- `dbo.usp_RankingParametrosCriticos` retornou ranking com `@TopN = 5`.
- Erro de período inválido validado com a mensagem `DataInicio nao pode ser maior que DataFim.`.
- Erro de `@TopN = 0` validado com a mensagem `TopN deve ser maior que zero quando informado.`.
- Prints `14` a `19` registrados para comprovar visualmente a validação da fase.

### Observações

- As procedures são analíticas e somente leitura.
- A fase não adiciona procedures de `INSERT`, `UPDATE` ou `DELETE`.
- As regras de conformidade continuam centralizadas nas views oficiais.
- Os exemplos de `EXEC` permanecem comentados na migration para separar criação de objetos e execução manual de evidências.
- Não se afirma ganho automático de performance com stored procedures; o valor técnico da fase está em parametrização, padronização, validação e reutilização controlada das views oficiais.

## [v1.3.0] - 2026-05-12 - Auditoria, histórico e rastreabilidade

Fase dedicada a auditoria, histórico e rastreabilidade de alterações em tabelas que afetam conformidade, indicadores e interpretação técnica dos resultados.

### Adicionado

- Documento `docs/auditoria_historico.md` com planejamento, critérios técnicos, tabelas auditadas, tabelas adiadas, riscos e estratégia de evidências.
- Script incremental `sql/migrations/2026-05-12_v1.3.0_auditoria_historico.sql`.
- Tabela `dbo.Tbl_AuditoriaAlteracoes` para registrar eventos de auditoria com metadados da operação e snapshots de valores anteriores e novos.
- Índice `IX_Tbl_AuditoriaAlteracoes_Tabela_Registro_Data` para apoiar consultas por tabela, registro afetado e data/hora da operação.
- Trigger `dbo.TRG_Tbl_ResultadosAnalise_Auditoria` para auditar alterações em resultados analíticos.
- Trigger `dbo.TRG_Tbl_LimitesReferencia_Auditoria` para auditar alterações em limites de referência.
- Trigger `dbo.TRG_Tbl_Amostras_Auditoria` para auditar alterações em amostras.
- Evidências visuais da fase `v1.3.0` em `docs/evidencias/`, cobrindo criação da tabela, criação das triggers, testes controlados de `UPDATE`, consulta geral da auditoria e validação dos indicadores finais.

### Validado

- Migration `sql/migrations/2026-05-12_v1.3.0_auditoria_historico.sql` executada com sucesso no SQL Server Management Studio.
- Tabela `dbo.Tbl_AuditoriaAlteracoes` confirmada em `sys.tables`.
- Triggers de auditoria confirmadas em `sys.triggers` e ativas.
- Foram registrados 8 eventos de auditoria do tipo `UPDATE`: 2 em `Tbl_ResultadosAnalise`, 4 em `Tbl_LimitesReferencia` e 2 em `Tbl_Amostras`.
- Indicadores finais permaneceram consistentes após a auditoria: 72 resultados analíticos, 57 com limite, 15 sem limite, 50 conformes com limite e 7 não conformes.
- Prints `20` a `26` registrados para comprovar visualmente a validação da fase.

### Observações

- A auditoria foi aplicada somente em tabelas com impacto direto em conformidade, indicadores ou interpretação técnica.
- A fase não audita todas as tabelas do banco de forma indiscriminada.
- A auditoria não substitui backup, restore, controle de acesso ou histórico temporal completo.
- A validação inicial utilizou apenas `UPDATEs` controlados; testes de `DELETE` foram evitados para não comprometer os dados didáticos e os indicadores finais.
- As triggers registram rastreabilidade das alterações, mas não recalculam regras de negócio nem substituem as views oficiais.

## [v1.4.0] - 2026-05-12 - Backup, restore e validação pós-recuperação

Fase dedicada a backup completo, restore em banco separado e validação pós-recuperação, com foco em prática operacional segura de DBA.

### Adicionado

- Documento `docs/backup_restore.md` com planejamento, critérios técnicos, riscos, limitações e estratégia de evidências.
- Script operacional `sql/migrations/2026-05-12_v1.4.0_backup_restore_validacao.sql`.
- Rotina de backup completo do banco `QualidadeAmbiental`.
- Validação do arquivo `.bak` com `RESTORE VERIFYONLY`.
- Inspeção dos nomes lógicos com `RESTORE FILELISTONLY`.
- Orientação de restore em banco separado `QualidadeAmbiental_RestoreTeste`.
- Validações pós-restore para tabelas, views, procedures, índices, auditoria, triggers e indicadores.
- Evidências visuais da fase `v1.4.0` em `docs/evidencias/`, cobrindo prints `27` a `37`.

### Validado

- Backup completo executado com sucesso.
- Arquivo `.bak` criado em pasta local fora do repositório Git.
- `RESTORE VERIFYONLY` executado com sucesso.
- `RESTORE FILELISTONLY` usado para identificar nomes lógicos.
- Restore realizado em banco separado `QualidadeAmbiental_RestoreTeste`.
- Banco restaurado confirmado como `ONLINE`.
- Foram confirmados no banco restaurado: 8 tabelas principais, 6 views oficiais, 3 procedures, 3 triggers de auditoria ativas, 2 índices incrementais ativos e a tabela de auditoria.
- Indicadores finais permaneceram consistentes após o restore: 72 resultados analíticos, 57 com limite, 15 sem limite, 50 conformes com limite e 7 não conformes.

### Observações

- O restore não foi feito sobre o banco principal `QualidadeAmbiental`.
- O arquivo `.bak` não foi versionado no GitHub.
- O script não possui `DROP DATABASE`, `ALTER DATABASE ... SET SINGLE_USER`, `WITH REPLACE` ou `RESTORE DATABASE` ativos por padrão.
- O bloco de restore permanece orientado para ajuste manual de `LogicalName`, MDF e LDF conforme ambiente local.
- A fase não implementa alta disponibilidade, SQL Server Agent, log shipping, Always On ou estratégia corporativa formal de RPO/RTO.

## [v2.0.0] - 2026-05-13 - Pipeline de importação com staging e validação

Fase dedicada a importação controlada de resultados analíticos externos, com controle de lote, staging, validação, classificação de registros e carga final protegida por confirmação explícita.

### Adicionado

- Documento `docs/importacao_staging.md` atualizado com implementação, validação e evidências da fase `v2.0.0`.
- Script incremental `sql/migrations/2026-05-13_v2.0.0_importacao_staging.sql`.
- Tabela `dbo.Tbl_LotesImportacao` para controle de lotes de importação.
- Tabela `dbo.Stg_ResultadosAnaliseImportacao` para receber dados brutos de resultados analíticos externos.
- FK da staging para `dbo.Tbl_LotesImportacao`.
- Checks de status e integridade básica para lotes e staging.
- Índice `IX_Stg_ResultadosAnaliseImportacao_Lote_Status` para apoiar filtros por lote e status.
- Procedure `dbo.usp_ValidarStgResultadosAnalise` para validar registros da staging por lote.
- Procedure `dbo.usp_CarregarResultadosAnaliseValidados` para carga final controlada de registros válidos.
- Bloco opcional comentado no script para testes manuais no SSMS.
- Evidências visuais da fase `v2.0.0` em `docs/evidencias/`, cobrindo prints `38` a `49`.

### Validado

- Migration `sql/migrations/2026-05-13_v2.0.0_importacao_staging.sql` executada e validada no banco `QualidadeAmbiental_RestoreTeste`.
- Banco principal `QualidadeAmbiental` preservado.
- Tabelas `dbo.Tbl_LotesImportacao` e `dbo.Stg_ResultadosAnaliseImportacao` confirmadas no catálogo do SQL Server.
- Procedures `dbo.usp_ValidarStgResultadosAnalise` e `dbo.usp_CarregarResultadosAnaliseValidados` confirmadas em `sys.procedures`.
- Índice `IX_Stg_ResultadosAnaliseImportacao_Lote_Status` confirmado em `sys.indexes`, ativo e não único.
- Constraints, checks e FK confirmadas e habilitadas.
- Lote didático criado com `IdLoteImportacao = 1`.
- 7 linhas recebidas na staging com status inicial `PENDENTE`.
- Procedure de validação classificou as 7 linhas como `INVALIDO`.
- Lote atualizado para `VALIDADO`, com `TotalLinhas = 7`, `TotalValidas = 0`, `TotalInvalidas = 7` e `TotalCarregadas = 0`.
- Carga sem confirmação bloqueada pela procedure de carga.
- Carga com `@ConfirmarCarga = 1` bloqueada por haver registros `INVALIDO` no lote.
- Nenhum registro inválido foi carregado em `dbo.Tbl_ResultadosAnalise`.
- `dbo.Tbl_ResultadosAnalise` permaneceu com 72 registros.
- Indicadores finais preservados após a validação da staging: 72 resultados analíticos, 57 com limite, 15 sem limite, 50 conformes com limite e 7 não conformes.
- Prints `38` a `49` registrados para comprovar visualmente a validação da fase.

### Observações

- A validação da v2.0.0 ocorreu em `QualidadeAmbiental_RestoreTeste`.
- O banco principal `QualidadeAmbiental` não foi alterado.
- Não houve carga final de registros válidos nesta rodada.
- A ausência de registros válidos carregados é esperada, pois a base didática atual já possui as combinações reais de 6 amostras x 12 parâmetros em `dbo.Tbl_ResultadosAnalise`.
- A fase demonstrou a segurança do pipeline: retenção de dados brutos na staging, identificação de inválidos, mensagens claras de validação, bloqueio de carga sem confirmação, bloqueio de carga com inválidos e preservação da tabela oficial.
- A fase não implementa integração real com laboratório externo, automação corporativa, SSIS, API ou rotina externa de importação.
- A tag `v2.0.0` ainda não foi criada neste registro.

## Próximas versões planejadas

| Versão | Foco |
| --- | --- |
| `v2.1.0` | Power BI e camada visual executiva. |
