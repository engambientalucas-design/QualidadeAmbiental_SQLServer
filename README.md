# QualidadeAmbiental SQL Server

## Resumo executivo

O projeto **QualidadeAmbiental_SQLServer** é um banco de dados relacional em SQL Server aplicado à Engenharia Ambiental, com foco no monitoramento de qualidade de água e esgoto.

A proposta é organizar dados de pontos de coleta, amostras, parâmetros ambientais, resultados laboratoriais, limites de referência e relatórios analíticos. O projeto também tem finalidade de portfólio técnico, demonstrando modelagem relacional, T-SQL, organização de scripts, views analíticas e boas práticas de documentação.

Versão em consolidação: `v2.1.0` - contrato de dados para consumo externo, encerramento controlado do projeto principal e camada local demonstrativa de dashboard/API read-only.

## Objetivo do projeto

Criar uma base de dados estruturada para registrar e analisar informações de qualidade ambiental, permitindo:

- cadastrar responsáveis técnicos, pontos de coleta, tipos de amostra, status e parâmetros ambientais;
- registrar amostras coletadas em diferentes locais;
- armazenar resultados analíticos por parâmetro;
- comparar resultados com limites de referência didáticos;
- gerar views e consultas para análise de conformidade, criticidade e eficiência;
- manter o projeto organizado, versionável e compreensível para continuidade futura.

## Contexto ambiental

O monitoramento de qualidade de água e esgoto é uma atividade essencial para acompanhar condições ambientais, avaliar desempenho de tratamento e apoiar decisões técnicas.

Neste projeto, os dados representam um cenário didático de monitoramento ambiental. Os limites de referência utilizados são considerados **didáticos**, salvo revisão normativa posterior. Portanto, eles não devem ser interpretados como limites legais reais sem validação técnica e normativa específica.

## Tecnologias utilizadas

- SQL Server
- SQL Server Management Studio
- VS Code
- Codex/Cursor
- MCP SQL Server
- T-SQL
- PowerShell, quando necessário

## Estrutura de pastas

```text
QualidadeAmbiental_SQLServer/
|-- docs/
|   |-- evidencias/
|   |-- dicionario_dados.md
|   |-- evidencias_validacao.md
|   |-- modelo_dados.md
|   |-- performance_indices.md
|   |-- regras_negocio.md
|   |-- auditoria_historico.md
|   |-- backup_restore.md
|   |-- contrato_dados.md
|   |-- contrato_frontend.md
|   |-- frontend_roadmap.md
|   |-- importacao_staging.md
|   |-- stored_procedures.md
|   `-- relatorios.md
|-- scripts/
|   `-- start_dashboard_api.ps1
|-- sql/
|   |-- migrations/
|   |   |-- 2026-05-11_v1.1.0_indices_performance.sql
|   |   |-- 2026-05-12_v1.2.0_stored_procedures.sql
|   |   |-- 2026-05-12_v1.3.0_auditoria_historico.sql
|   |   |-- 2026-05-12_v1.4.0_backup_restore_validacao.sql
|   |   |-- 2026-05-13_v2.0.0_importacao_staging.sql
|   |   `-- .gitkeep
|   |-- 01_create_database.sql
|   |-- 02_create_tables.sql
|   |-- 03_insert_cadastros.sql
|   |-- 04_insert_amostras_resultados.sql
|   |-- 05_views_oficiais.sql
|   `-- 06_consultas_analiticas.sql
|-- CHANGELOG.md
`-- README.md
```

### Finalidade das pastas

- `docs/`: documentação complementar do projeto.
- `scripts/`: scripts auxiliares, quando necessários.
- `sql/`: scripts oficiais do banco de dados.
- `sql/migrations/`: scripts incrementais de correção, evolução ou manutenção.

## Documentação complementar

A documentação complementar do projeto fica na pasta `docs/` e deve ser usada como apoio para leitura técnica, continuidade do projeto e apresentação em portfólio.

- `CHANGELOG.md`: histórico de versões e evolução planejada do projeto.
- `docs/modelo_dados.md`: documenta o modelo de dados, tabelas, relacionamentos, integridade, views, limitações e evoluções futuras.
- `docs/regras_negocio.md`: documenta as regras de negócio implementadas, regras de conformidade, tratamento de resultados sem limite, eficiência de remoção da ETE e limitações atuais.
- `docs/relatorios.md`: documenta views, consultas analíticas, indicadores, interpretações e prints recomendados para portfólio.
- `docs/dicionario_dados.md`: dicionário de dados técnico com tabelas, colunas, tipos de dados, chaves, constraints e relacionamentos.
- `docs/evidencias_validacao.md`: documenta as validações executadas, os resultados confirmados e as evidências visuais registradas.
- `docs/performance_indices.md`: documenta a fase `v1.1.0`, os índices criados, critérios técnicos, trade-offs e orientações de análise de plano de execução.
- `docs/stored_procedures.md`: documenta a fase `v1.2.0`, os critérios para procedures analíticas parametrizadas, rotinas implementadas, validações e evidências.
- `docs/auditoria_historico.md`: documenta a fase `v1.3.0`, os critérios de auditoria, tabelas auditadas, triggers, validações e evidências.
- `docs/backup_restore.md`: documenta a fase `v1.4.0`, estratégia de backup, restore em banco separado, validação pós-recuperação e evidências.
- `docs/importacao_staging.md`: documenta a fase `v2.0.0`, pipeline de importação com staging, validação, classificação de registros e carga final controlada.
- `docs/contrato_dados.md`: documenta a fase `v2.1.0`, contrato de dados para consumo externo e critério de encerramento do projeto principal.
- `docs/contrato_frontend.md`: documenta o contrato entre SQL Server, API local read-only e dashboard demonstrativo.
- `docs/frontend_roadmap.md`: documenta o enquadramento do dashboard local e separa evoluções operacionais como projetos derivados.
- `docs/evidencias/`: armazena prints de validação capturados no SQL Server Management Studio.

## Ordem recomendada de execução dos scripts

Os scripts devem ser executados preferencialmente no SQL Server Management Studio, nesta ordem:

1. `sql/01_create_database.sql`
   - Cria o banco de dados `QualidadeAmbiental`, caso ele ainda não exista.

2. `sql/02_create_tables.sql`
   - Cria as tabelas principais, chaves primárias, chaves estrangeiras e constraints básicas.

3. `sql/03_insert_cadastros.sql`
   - Deve inserir dados de cadastro, como responsáveis, status, tipos de amostra, pontos de coleta, parâmetros e limites de referência.

4. `sql/04_insert_amostras_resultados.sql`
   - Deve inserir amostras coletadas e resultados analíticos.

5. `sql/05_views_oficiais.sql`
   - Cria as views oficiais de análise, conformidade e indicadores ambientais.

6. `sql/06_consultas_analiticas.sql`
   - Contém consultas de validação, exploração e relatórios analíticos.

7. `sql/migrations/2026-05-11_v1.1.0_indices_performance.sql`
   - Cria índices incrementais para apoiar consultas analíticas e valida sua existência no catálogo do SQL Server.

8. `sql/migrations/2026-05-12_v1.2.0_stored_procedures.sql`
   - Cria stored procedures analíticas parametrizadas e valida sua existência em `sys.procedures`.

9. `sql/migrations/2026-05-12_v1.3.0_auditoria_historico.sql`
   - Cria a tabela de auditoria, triggers para tabelas críticas e valida sua existência no catálogo do SQL Server.

10. `sql/migrations/2026-05-12_v1.4.0_backup_restore_validacao.sql`
    - Executa backup completo, verifica o arquivo `.bak`, orienta restore seguro em banco separado e valida objetos e indicadores pós-recuperação.

11. `sql/migrations/2026-05-13_v2.0.0_importacao_staging.sql`
    - Cria pipeline de importação com lote, staging, validação e carga controlada. A primeira validação deve ocorrer preferencialmente no banco restaurado/teste `QualidadeAmbiental_RestoreTeste`, preservando o banco principal `QualidadeAmbiental`.

## Modelo de dados resumido

Banco de dados: `QualidadeAmbiental`

Tabelas principais:

- `Tbl_Responsaveis`
- `Tbl_StatusAmostra`
- `Tbl_TiposAmostra`
- `Tbl_PontosColeta`
- `Tbl_Parametros`
- `Tbl_Amostras`
- `Tbl_ResultadosAnalise`
- `Tbl_LimitesReferencia`

Relacionamentos principais:

- `Tbl_Amostras.IdPontoColeta` referencia `Tbl_PontosColeta.IdPontoColeta`.
- `Tbl_Amostras.IdTipoAmostra` referencia `Tbl_TiposAmostra.IdTipoAmostra`.
- `Tbl_Amostras.IdResponsavel` referencia `Tbl_Responsaveis.IdResponsavel`.
- `Tbl_Amostras.IdStatus` referencia `Tbl_StatusAmostra.IdStatus`.
- `Tbl_ResultadosAnalise.IdAmostra` referencia `Tbl_Amostras.IdAmostra`.
- `Tbl_ResultadosAnalise.IdParametro` referencia `Tbl_Parametros.IdParametro`.
- `Tbl_LimitesReferencia.IdParametro` referencia `Tbl_Parametros.IdParametro`.
- `Tbl_LimitesReferencia.IdTipoAmostra` referencia `Tbl_TiposAmostra.IdTipoAmostra`.

## Descrição das tabelas

### Tbl_Responsaveis

Armazena responsáveis técnicos, analistas, coletores ou profissionais associados às amostras.

### Tbl_StatusAmostra

Armazena os possíveis status de uma amostra, como coletada, em análise, concluída, reprovada ou pendente.

### Tbl_TiposAmostra

Armazena os tipos de amostra analisados no projeto, como água bruta, água tratada, esgoto bruto, esgoto tratado e corpo hídrico.

### Tbl_PontosColeta

Armazena os pontos de coleta, incluindo município, estado, coordenadas geográficas e observações.

### Tbl_Parametros

Armazena os parâmetros ambientais avaliados, como pH, turbidez, oxigênio dissolvido, DBO, DQO, coliformes termotolerantes, temperatura, condutividade, sólidos totais, nitrogênio amoniacal, fósforo total e cloro residual livre.

### Tbl_Amostras

Registra cada amostra coletada, vinculando ponto de coleta, tipo de amostra, responsável técnico e status.

### Tbl_ResultadosAnalise

Registra os resultados laboratoriais de cada parâmetro analisado em cada amostra.

### Tbl_LimitesReferencia

Armazena limites mínimos e máximos de referência para comparação dos resultados analíticos. Os limites cadastrados são didáticos, salvo revisão normativa posterior.

## Descrição das views

As views abaixo compõem a camada analítica oficial do projeto e estão organizadas no arquivo `sql/05_views_oficiais.sql`.

### VW_ResultadosForaDoPadrao

Lista resultados analíticos classificados como acima do limite máximo ou abaixo do limite mínimo.

### VW_EficienciaRemocaoETE

Apoia a análise de eficiência de remoção em estação de tratamento de esgoto. A comparação é feita entre registros de `Esgoto Bruto` e `Esgoto Tratado` do mesmo parâmetro e da mesma data de coleta, evitando combinações indevidas quando houver mais de uma amostra.

### VW_ConformidadeResultados

Classifica os resultados analíticos em relação aos limites de referência, preservando resultados sem limite cadastrado.

Classificações esperadas:

- Conforme
- Acima do limite máximo
- Abaixo do limite mínimo
- Sem limite de referência

### VW_ConformidadeMensal

Consolida indicadores mensais de conformidade, permitindo acompanhar evolução ao longo do tempo.

### VW_RankingParametrosCriticos

Ordena parâmetros ambientais por quantidade e proporção de não conformidades.

### VW_ResultadosSemLimiteReferencia

Lista resultados analíticos que ainda não possuem limite de referência cadastrado.

## Stored procedures analíticas

A fase `v1.2.0` adicionou stored procedures analíticas parametrizadas, mantendo as regras de conformidade centralizadas nas views oficiais.

Procedures criadas:

- `dbo.usp_ConformidadePorPeriodo`: consolida indicadores de conformidade por período, tipo de amostra e ponto de coleta.
- `dbo.usp_ResultadosForaPadrao`: lista resultados acima ou abaixo dos limites didáticos com filtros opcionais.
- `dbo.usp_RankingParametrosCriticos`: gera ranking de parâmetros críticos com `TOP N` e filtros opcionais.

As procedures usam `CREATE OR ALTER PROCEDURE`, schema explícito `dbo`, prefixo `usp_`, `SET NOCOUNT ON` e validações com `THROW` para período inválido e `@TopN` inválido.

## Auditoria e rastreabilidade

A fase `v1.3.0` adicionou uma camada enxuta de auditoria para alterações em tabelas que afetam conformidade, indicadores e interpretação dos dados.

Objetos criados:

- `dbo.Tbl_AuditoriaAlteracoes`: tabela única de auditoria.
- `dbo.TRG_Tbl_ResultadosAnalise_Auditoria`: trigger para alterações em resultados analíticos.
- `dbo.TRG_Tbl_LimitesReferencia_Auditoria`: trigger para alterações em limites de referência.
- `dbo.TRG_Tbl_Amostras_Auditoria`: trigger para alterações em amostras.

A auditoria registra metadados como tabela, registro afetado, operação, data/hora, usuário SQL, host, aplicação, valores anteriores e valores novos. A validação inicial usou `UPDATEs` controlados e preservou os indicadores finais do projeto.

## Backup e restore

A fase `v1.4.0` adicionou uma rotina operacional de backup, restore em banco separado e validação pós-recuperação.

Objetos e artefatos envolvidos:

- Banco origem: `QualidadeAmbiental`.
- Banco restaurado para teste: `QualidadeAmbiental_RestoreTeste`.
- Script operacional: `sql/migrations/2026-05-12_v1.4.0_backup_restore_validacao.sql`.
- Caminho local de backup: `C:\SQLBackups\QualidadeAmbiental\`.

O arquivo `.bak` não faz parte do repositório Git/GitHub. Ele é um artefato operacional local. A validação confirmou que o banco restaurado preservou tabelas, views, procedures, índices, auditoria e os indicadores finais `72 / 57 / 15 / 50 / 7`.

## Importação com staging

A fase `v2.0.0` adicionou um pipeline enxuto de importação de resultados analíticos externos para amostras já existentes, usando controle de lote, tabela staging, validação por procedure, classificação de registros e carga final controlada.

Objetos criados:

- `dbo.Tbl_LotesImportacao`: controla lotes, origem, status, totais e período de processamento.
- `dbo.Stg_ResultadosAnaliseImportacao`: recebe dados brutos de resultados analíticos e registra status/mensagens de validação.
- `IX_Stg_ResultadosAnaliseImportacao_Lote_Status`: índice mínimo para filtros por lote e status.
- `dbo.usp_ValidarStgResultadosAnalise`: valida registros de staging por lote.
- `dbo.usp_CarregarResultadosAnaliseValidados`: carrega apenas registros válidos mediante confirmação explícita.

A validação inicial foi feita em `QualidadeAmbiental_RestoreTeste`. O banco principal `QualidadeAmbiental` foi preservado.

Na validação didática, 7 linhas foram recebidas na staging e classificadas como `INVALIDO`. A carga sem confirmação foi bloqueada, a carga com registros inválidos também foi bloqueada e nenhum registro inválido foi carregado em `dbo.Tbl_ResultadosAnalise`.

Não houve carga final de registros válidos nesta rodada, pois a base didática atual já possui as combinações reais de 6 amostras x 12 parâmetros em `dbo.Tbl_ResultadosAnalise`. A fase comprovou a segurança do pipeline e manteve os indicadores finais em `72 / 57 / 15 / 50 / 7`.

## Principais indicadores ambientais

Os indicadores esperados para o projeto incluem:

- quantidade total de resultados analíticos;
- quantidade de resultados com limite de referência;
- quantidade de resultados sem limite de referência;
- quantidade de resultados conformes;
- quantidade de resultados não conformes;
- proporção de conformidade por período;
- parâmetros mais críticos;
- resultados fora do padrão;
- eficiência de remoção em cenários de tratamento de esgoto.

## Regras de negócio

- Cada amostra deve estar vinculada a um ponto de coleta.
- Cada amostra deve ter um tipo de amostra.
- Cada amostra deve ter um responsável associado.
- Cada amostra deve ter um status.
- Cada resultado analítico deve pertencer a uma amostra.
- Cada resultado analítico deve estar associado a um parâmetro ambiental.
- Os limites de referência devem ser definidos por combinação de parâmetro e tipo de amostra.
- Resultados sem limite de referência não devem desaparecer dos relatórios analíticos.
- A classificação oficial dos resultados deve considerar quatro situações:
  - `Conforme`
  - `Acima do limite máximo`
  - `Abaixo do limite mínimo`
  - `Sem limite de referência`

## Decisões técnicas importantes

- O banco de dados oficial do projeto se chama `QualidadeAmbiental`.
- Os scripts oficiais ficam na pasta `sql/`.
- Scripts incrementais, correções futuras e alterações evolutivas devem ser colocados em `sql/migrations/`.
- O script `01_create_database.sql` deve criar o banco apenas se ele ainda não existir.
- O script `02_create_tables.sql` deve conter apenas estrutura de tabelas, relacionamentos e constraints.
- As chaves primárias não usam `IDENTITY`, pois os scripts de carga utilizam IDs explícitos para manter os dados didáticos, previsíveis e compatíveis com as validações.
- Inserts de cadastro devem ficar separados dos inserts de amostras e resultados.
- Views oficiais devem ser mantidas em arquivo próprio.
- As views de conformidade devem usar `LEFT JOIN` com `Tbl_LimitesReferencia` quando for necessário preservar resultados sem limite de referência.
- O uso de `INNER JOIN` com `Tbl_LimitesReferencia` pode ocultar resultados que ainda não têm limite cadastrado.
- Os limites de referência são didáticos e não representam, por si só, enquadramento legal ou normativo.

## Registro de desenvolvimento

Esta seção registra decisões e avanços entre os arquivos oficiais para facilitar futuras manutenções, correções ou troca de ambiente.

### Arquivo 01_create_database.sql

- Cria o banco `QualidadeAmbiental` apenas se ele ainda não existir.
- Inicia no contexto `master` antes da criação do banco.
- Ao final, muda o contexto para `QualidadeAmbiental`.

### Arquivo 02_create_tables.sql

- Cria as 8 tabelas principais do modelo.
- Define chaves primárias, chaves estrangeiras e constraints básicas.
- Mantém IDs sem `IDENTITY`, pois os inserts usam IDs explícitos.
- Padroniza colunas como `NomePonto`, `TipoPonto`, `Observacao`, `UnidadeMedida`, `Categoria`, `IdLimite`, `ValorMinimo` e `ValorMaximo`.

### Arquivo 03_insert_cadastros.sql

- Insere dados de cadastro com IDs explícitos.
- Insere 4 responsáveis, 5 status, 5 tipos de amostra, 6 pontos de coleta, 12 parâmetros e 47 limites de referência didáticos.
- Inclui bloco final de validação com consultas `COUNT`.
- A matriz de limites foi planejada para sustentar, no arquivo `04_insert_amostras_resultados.sql`, 57 resultados com limite e 15 resultados sem limite.

### Arquivo 04_insert_amostras_resultados.sql

- Insere 6 amostras didáticas.
- Insere 72 resultados analíticos, considerando 12 parâmetros para cada amostra.
- A distribuição dos resultados foi planejada para gerar 57 resultados com limite, 15 sem limite, 50 conformes com limite e 7 não conformes com limite.
- O arquivo depende diretamente dos cadastros e limites criados em `03_insert_cadastros.sql`.

### Arquivo 05_views_oficiais.sql

- Cria as views oficiais de conformidade, resultados fora do padrão, resultados sem limite, conformidade mensal, ranking de parâmetros críticos e eficiência de remoção da ETE.
- A view central é `VW_ConformidadeResultados`.
- `VW_ConformidadeResultados` usa `LEFT JOIN` com `Tbl_LimitesReferencia` para preservar resultados sem limite cadastrado.
- `VW_EficienciaRemocaoETE` compara entrada e saída por mesmo parâmetro e mesma data de coleta, reduzindo o risco de multiplicação indevida de linhas.
- `VW_EficienciaRemocaoETE` agrega os dados de entrada e saída antes da comparação e expõe `CodigoAmostraEntrada`, `CodigoAmostraSaida`, `TotalResultadosEntrada` e `TotalResultadosSaida`.
- A view foi ajustada para que as CTEs internas exponham `CodigoAmostra` usando `MAX(CodigoAmostra)`, evitando erro de coluna inválida no SQL Server.

### Arquivo 06_consultas_analiticas.sql

- Reúne consultas de validação, auditoria e apresentação dos dados.
- Contém apenas comandos `SELECT`.
- Valida cadastros, amostras, resultados analíticos, classificações, resultados fora do padrão, resultados sem limite, conformidade mensal, ranking de parâmetros críticos e eficiência de remoção.
- Inclui um checklist final com coluna de situação para indicar `OK` ou `DIVERGENTE` nos principais números esperados.

### Migration 2026-05-11_v1.1.0_indices_performance.sql

- Cria índices não clusterizados incrementais para apoiar consultas analíticas.
- Valida os índices criados por meio do catálogo do SQL Server.
- Mantém os indicadores analíticos finais consistentes após a alteração estrutural.

### Migration 2026-05-12_v1.2.0_stored_procedures.sql

- Cria as procedures `dbo.usp_ConformidadePorPeriodo`, `dbo.usp_ResultadosForaPadrao` e `dbo.usp_RankingParametrosCriticos`.
- Mantém as procedures como rotinas analíticas e somente leitura.
- Usa as views oficiais como fonte das regras de conformidade.
- Valida período inválido com `THROW`.
- Valida `@TopN` menor ou igual a zero com `THROW`.
- Mantém exemplos de execução comentados para uso manual no SSMS e captura de evidências.

### Migration 2026-05-12_v1.3.0_auditoria_historico.sql

- Cria a tabela `dbo.Tbl_AuditoriaAlteracoes`.
- Cria índice para consulta por tabela, registro e data da operação.
- Cria triggers de auditoria para `Tbl_ResultadosAnalise`, `Tbl_LimitesReferencia` e `Tbl_Amostras`.
- Registra `INSERT`, `UPDATE` e `DELETE` executados após a criação das triggers.
- Armazena snapshots em `ValoresAnteriores` e `ValoresNovos`.
- Mantém exemplos de validação manual comentados, com foco em `UPDATEs` controlados.

### Migration 2026-05-12_v1.4.0_backup_restore_validacao.sql

- Executa backup completo do banco `QualidadeAmbiental`.
- Valida o arquivo de backup com `RESTORE VERIFYONLY`.
- Lista nomes lógicos com `RESTORE FILELISTONLY`.
- Mantém o bloco `RESTORE DATABASE ... WITH MOVE` comentado por padrão para ajuste manual seguro.
- Orienta restore em banco separado `QualidadeAmbiental_RestoreTeste`.
- Valida tabelas, views, procedures, índices, auditoria e indicadores no banco restaurado.
- Não possui `DROP DATABASE`, `ALTER DATABASE ... SET SINGLE_USER`, `WITH REPLACE` ou `RESTORE DATABASE` ativos por padrão.

### Migration 2026-05-13_v2.0.0_importacao_staging.sql

- Cria `dbo.Tbl_LotesImportacao`.
- Cria `dbo.Stg_ResultadosAnaliseImportacao`.
- Cria FK da staging para lotes, checks de status e integridade básica.
- Cria o índice `IX_Stg_ResultadosAnaliseImportacao_Lote_Status`.
- Cria `dbo.usp_ValidarStgResultadosAnalise`.
- Cria `dbo.usp_CarregarResultadosAnaliseValidados`.
- Exige `@ConfirmarCarga = 1` para carga final controlada.
- Usa transação explícita e `SET XACT_ABORT ON` na procedure de carga.
- Mantém exemplos didáticos comentados para execução manual no SSMS.
- Foi validada em `QualidadeAmbiental_RestoreTeste`, sem alterar o banco principal.

## Como validar o banco

Após executar os scripts de criação, inserts e views, as consultas analíticas devem validar os seguintes números esperados. No estado atual do projeto, os scripts oficiais foram executados no SQL Server Management Studio e o checklist final retornou `OK` para os principais indicadores.

- Após executar `03_insert_cadastros.sql`:
  - Total de responsáveis: 4
  - Total de status: 5
  - Total de tipos de amostra: 5
  - Total de pontos de coleta: 6
  - Total de parâmetros: 12
  - Total de limites de referência: 47

- Após executar `04_insert_amostras_resultados.sql` e as views oficiais:
  - Total de amostras: 6
  - Total de resultados analíticos: 72
  - Resultados com limite: 57
  - Resultados sem limite: 15
  - Conformes com limite: 50
  - Não conformes com limite: 7

Validações consolidadas confirmadas:

- Total de resultados analíticos: 72
- Resultados com limite: 57
- Resultados sem limite: 15
- Conformes com limite: 50
- Não conformes com limite: 7

Essas validações estão organizadas no arquivo `sql/06_consultas_analiticas.sql`.

Validações da fase `v1.2.0`:

- As procedures `dbo.usp_ConformidadePorPeriodo`, `dbo.usp_ResultadosForaPadrao` e `dbo.usp_RankingParametrosCriticos` foram criadas e confirmadas em `sys.procedures`.
- `dbo.usp_ConformidadePorPeriodo` confirmou os totais consolidados: 72 resultados analíticos, 57 com limite, 15 sem limite, 50 conformes com limite e 7 não conformes.
- `dbo.usp_ResultadosForaPadrao` retornou 7 resultados fora do padrão no período validado.
- `dbo.usp_RankingParametrosCriticos` retornou ranking com `@TopN = 5`.
- Os erros esperados para período inválido e `@TopN = 0` foram validados com `THROW`.

Validações da fase `v1.3.0`:

- A tabela `dbo.Tbl_AuditoriaAlteracoes` foi criada e confirmada em `sys.tables`.
- As triggers `TRG_Tbl_ResultadosAnalise_Auditoria`, `TRG_Tbl_LimitesReferencia_Auditoria` e `TRG_Tbl_Amostras_Auditoria` foram criadas e confirmadas em `sys.triggers`.
- Foram registrados 8 eventos de auditoria do tipo `UPDATE`: 2 em `Tbl_ResultadosAnalise`, 4 em `Tbl_LimitesReferencia` e 2 em `Tbl_Amostras`.
- Os indicadores finais permaneceram consistentes após a auditoria: 72 resultados analíticos, 57 com limite, 15 sem limite, 50 conformes com limite e 7 não conformes.

Validações da fase `v1.4.0`:

- Backup completo do banco `QualidadeAmbiental` executado com sucesso.
- Arquivo `.bak` verificado com `RESTORE VERIFYONLY`.
- Arquivos lógicos conferidos com `RESTORE FILELISTONLY`.
- Restore realizado em banco separado `QualidadeAmbiental_RestoreTeste`.
- Banco restaurado ficou online no SQL Server.
- Foram confirmados no banco restaurado: 8 tabelas principais, 6 views oficiais, 3 procedures, 3 triggers de auditoria ativas, 2 índices incrementais ativos e a tabela de auditoria.
- Os indicadores finais permaneceram consistentes após o restore: 72 resultados analíticos, 57 com limite, 15 sem limite, 50 conformes com limite e 7 não conformes.

Validações da fase `v2.0.0`:

- Migration `sql/migrations/2026-05-13_v2.0.0_importacao_staging.sql` executada e validada no banco `QualidadeAmbiental_RestoreTeste`.
- Banco principal `QualidadeAmbiental` preservado.
- Tabelas `dbo.Tbl_LotesImportacao` e `dbo.Stg_ResultadosAnaliseImportacao` criadas.
- Procedures `dbo.usp_ValidarStgResultadosAnalise` e `dbo.usp_CarregarResultadosAnaliseValidados` criadas.
- Índice `IX_Stg_ResultadosAnaliseImportacao_Lote_Status` criado e habilitado.
- Constraints, checks e FK da staging criadas e habilitadas.
- Lote didático com `IdLoteImportacao = 1` criado.
- 7 linhas recebidas na staging como `PENDENTE`.
- Validação classificou as 7 linhas como `INVALIDO`.
- Lote atualizado para `VALIDADO`, com `TotalLinhas = 7`, `TotalValidas = 0`, `TotalInvalidas = 7` e `TotalCarregadas = 0`.
- Carga sem confirmação bloqueada.
- Carga com `@ConfirmarCarga = 1` bloqueada por haver registros `INVALIDO`.
- Nenhum registro inválido foi carregado em `dbo.Tbl_ResultadosAnalise`.
- `dbo.Tbl_ResultadosAnalise` permaneceu com 72 registros.
- Indicadores finais permaneceram consistentes: 72 resultados analíticos, 57 com limite, 15 sem limite, 50 conformes com limite e 7 não conformes.

## Como continuar o projeto

Para continuar o desenvolvimento em outro computador, ferramenta, IA ou ambiente:

1. Abrir a pasta do projeto no VS Code ou editor equivalente.
2. Conferir a estrutura de pastas descrita neste README.
3. Conferir os scripts oficiais na pasta `sql/`.
4. Em um novo ambiente, executar os scripts SQL na ordem recomendada.
5. Rodar `sql/06_consultas_analiticas.sql` e confirmar se o checklist final retorna `OK`.
6. Consultar `docs/modelo_dados.md` para entender a estrutura do modelo.
7. Consultar `docs/regras_negocio.md` para entender regras, classificações e limitações.
8. Consultar `docs/relatorios.md` para entender views, consultas e indicadores.
9. Consultar `docs/dicionario_dados.md` para referência coluna a coluna.
10. Consultar `docs/evidencias_validacao.md` e `docs/evidencias/` para verificar as evidências visuais registradas.
11. Executar as migrations incrementais em `sql/migrations/`, quando aplicável.
12. Consultar `docs/stored_procedures.md` para entender a fase `v1.2.0`.
13. Consultar `docs/auditoria_historico.md` para entender a fase `v1.3.0`.
14. Consultar `docs/backup_restore.md` para entender a fase `v1.4.0`.
15. Consultar `docs/importacao_staging.md` para entender a fase `v2.0.0`.
16. Consultar `docs/contrato_dados.md` para entender o contrato final de consumo externo e o encerramento controlado do projeto principal.
17. Registrar qualquer correção incremental em `sql/migrations/`, se houver necessidade real.
18. Manter o README e os arquivos de `docs/` atualizados a cada evolução relevante.

Caso o projeto mude de ferramenta ou responsável técnico, este README deve ser usado como documentação de referência para entender a finalidade, estrutura, regras e próximos passos.

## Roadmap de evolução

O projeto parte da versão `v1.0.0`, considerada a primeira versão publicável do portfólio. A versão `v2.1.0` representa o encerramento controlado do projeto principal como portfólio técnico SQL Server.

| Versão | Foco | Objetivo técnico |
| --- | --- | --- |
| `v1.0.0` | Publicação inicial | Base relacional, dados didáticos, views, consultas analíticas, documentação e evidências. |
| `v1.1.0` | Índices e performance | Índices incrementais para consultas analíticas, critérios técnicos, trade-offs e análise de plano de execução. |
| `v1.2.0` | Stored procedures | Criar procedures analíticas parametrizadas, validadas no SSMS e alinhadas às views oficiais. |
| `v1.3.0` | Auditoria e histórico | Adicionar auditoria e rastreabilidade para alterações em resultados, limites e amostras. |
| `v1.4.0` | Backup e restore | Implementada e validada localmente com backup completo, restore em banco separado e validação pós-recuperação. |
| `v2.0.0` | Pipeline de importação | Publicada com staging, validação, bloqueio de cargas indevidas, evidências visuais e preservação dos indicadores. |
| `v2.1.0` | Contrato de dados e encerramento | Consolidar contrato de dados para consumo externo, documentar a camada local demonstrativa e encerrar o repositório principal sem expandir para produto operacional. |

Evoluções fora do escopo do projeto principal:

- `QualidadeAmbiental_API`: API dedicada em .NET, Node.js ou tecnologia equivalente.
- `QualidadeAmbiental_PowerBI`: camada semântica, medidas e relatórios executivos.
- `QualidadeAmbiental_Dashboard`: frontend web completo consumindo uma API dedicada.
- `QualidadeAmbiental_DataOps`: automações, deploy e rotinas operacionais futuras, se houver necessidade.

Essas frentes podem reutilizar o banco `QualidadeAmbiental`, mas devem ser tratadas como projetos derivados para evitar crescimento indefinido do repositório SQL Server principal.

## Versionamento com Git

O repositório Git foi inicializado na pasta do projeto.

Estado atual do versionamento:

- A versão `v1.0.0` representa a base estável da publicação inicial no GitHub.
- A tag anotada `v1.0.0` já foi criada e publicada no GitHub, apontando para o commit da versão inicial publicável.
- A tag anotada `v1.1.0` já foi criada e publicada no GitHub, apontando para a versão de índices, performance e análise de plano de execução.
- A tag anotada `v1.2.0` já foi criada e publicada no GitHub, apontando para a versão de stored procedures analíticas parametrizadas, validações no SQL Server Management Studio e evidências visuais registradas.
- A tag anotada `v1.3.0` já foi criada e publicada no GitHub, apontando para a versão de auditoria, histórico, rastreabilidade, validações no SQL Server Management Studio e evidências visuais registradas.
- A tag anotada `v1.4.0` já foi criada e publicada no GitHub, apontando para a versão de backup completo, restore em banco separado, validação pós-recuperação e evidências visuais registradas.
- A tag anotada `v2.0.0` já foi criada e publicada no GitHub, apontando para a versão de pipeline de importação com staging, validação, bloqueio de cargas indevidas e evidências visuais registradas.
- Existe um commit inicial com os arquivos principais do projeto.
- A documentação de regras de negócio foi adicionada em commit separado.
- As documentações de relatórios, dicionário de dados e evidências foram adicionadas em commits próprios.
- O histórico deve ser mantido com commits pequenos e descritivos, especialmente para novas documentações, ajustes em scripts SQL e evoluções futuras.

## Observações sobre uso de IA no desenvolvimento

O projeto está sendo desenvolvido com apoio de ferramentas de IA, como Codex/Cursor, para organização, revisão técnica, geração de scripts e documentação.

As decisões técnicas devem ser revisadas criticamente antes de uso final, especialmente em temas como:

- limites ambientais;
- interpretação normativa;
- modelagem de dados;
- regras de negócio;
- validações de conformidade;
- performance e segurança.

A IA deve ser tratada como ferramenta de apoio técnico, não como fonte normativa definitiva.

## Status atual do projeto

Status: `v2.1.0` em consolidação documental, com contrato de dados para consumo externo, camada local demonstrativa de dashboard/API read-only e encerramento controlado do projeto principal como portfólio técnico SQL Server.

Já foi concluído:

- estrutura inicial de pastas;
- script de criação do banco de dados;
- script de criação das tabelas principais;
- script de inserção dos cadastros principais;
- script de inserção de amostras e resultados analíticos;
- script de views oficiais;
- script de consultas analíticas e validações finais;
- validações de contagem para os cadastros;
- execução dos scripts oficiais no SQL Server Management Studio;
- confirmação do checklist final com status `OK`;
- inicialização do repositório Git;
- criação do commit inicial;
- documentação principal do projeto;
- documentação técnica do modelo de dados em `docs/modelo_dados.md`;
- documentação de regras de negócio em `docs/regras_negocio.md`;
- documentação de relatórios, views e indicadores em `docs/relatorios.md`;
- dicionário de dados técnico em `docs/dicionario_dados.md`;
- documentação de evidências de validação em `docs/evidencias_validacao.md`;
- prints de validação registrados em `docs/evidencias/`;
- script incremental de índices e performance em `sql/migrations/2026-05-11_v1.1.0_indices_performance.sql`;
- documentação da fase `v1.1.0` em `docs/performance_indices.md`;
- evidências visuais da fase `v1.1.0` registradas em `docs/evidencias/`;
- execução e validação da migration `v1.1.0` no SQL Server Management Studio;
- confirmação de que os indicadores finais permaneceram consistentes após a criação dos índices;
- análise de plano de execução real para consultas analíticas da fase.
- documentação da fase `v1.2.0` em `docs/stored_procedures.md`;
- script incremental de stored procedures em `sql/migrations/2026-05-12_v1.2.0_stored_procedures.sql`;
- execução e validação da migration `v1.2.0` no SQL Server Management Studio;
- criação das procedures `dbo.usp_ConformidadePorPeriodo`, `dbo.usp_ResultadosForaPadrao` e `dbo.usp_RankingParametrosCriticos`;
- validação de execução das procedures com parâmetros válidos;
- validação de erros esperados para período inválido e `@TopN` inválido;
- evidências visuais da fase `v1.2.0` registradas em `docs/evidencias/`.
- documentação da fase `v1.3.0` em `docs/auditoria_historico.md`;
- script incremental de auditoria em `sql/migrations/2026-05-12_v1.3.0_auditoria_historico.sql`;
- execução e validação da migration `v1.3.0` no SQL Server Management Studio;
- criação da tabela `dbo.Tbl_AuditoriaAlteracoes`;
- criação das triggers de auditoria para `Tbl_ResultadosAnalise`, `Tbl_LimitesReferencia` e `Tbl_Amostras`;
- validação de eventos auditados com `UPDATEs` controlados;
- confirmação de que os indicadores finais permaneceram consistentes após a auditoria;
- evidências visuais da fase `v1.3.0` registradas em `docs/evidencias/`.
- documentação da fase `v1.4.0` em `docs/backup_restore.md`;
- script operacional de backup e restore em `sql/migrations/2026-05-12_v1.4.0_backup_restore_validacao.sql`;
- criação das pastas locais `C:\SQLBackups\QualidadeAmbiental\` e `C:\SQLBackups\QualidadeAmbiental\RestoreTeste\`;
- execução de backup completo do banco `QualidadeAmbiental`;
- validação do arquivo `.bak` com `RESTORE VERIFYONLY`;
- inspeção dos nomes lógicos com `RESTORE FILELISTONLY`;
- restore em banco separado `QualidadeAmbiental_RestoreTeste`;
- validação de objetos restaurados: tabelas, views, procedures, índices, auditoria e triggers;
- confirmação de que os indicadores finais permaneceram consistentes após o restore;
- evidências visuais da fase `v1.4.0` registradas em `docs/evidencias/`.
- documentação da fase `v2.0.0` em `docs/importacao_staging.md`;
- script incremental de importação com staging em `sql/migrations/2026-05-13_v2.0.0_importacao_staging.sql`;
- execução e validação da migration `v2.0.0` no banco `QualidadeAmbiental_RestoreTeste`;
- criação de `dbo.Tbl_LotesImportacao` e `dbo.Stg_ResultadosAnaliseImportacao`;
- criação das procedures `dbo.usp_ValidarStgResultadosAnalise` e `dbo.usp_CarregarResultadosAnaliseValidados`;
- validação de lote didático com 7 registros classificados como `INVALIDO`;
- validação de bloqueio de carga sem confirmação e de bloqueio de carga com registros inválidos;
- confirmação de que nenhum registro inválido foi carregado em `dbo.Tbl_ResultadosAnalise`;
- confirmação de que os indicadores finais permaneceram consistentes após a validação da staging;
- evidências visuais da fase `v2.0.0` registradas em `docs/evidencias/`.
- documentação da fase `v2.1.0` em `docs/contrato_dados.md`;
- documentação do contrato frontend em `docs/contrato_frontend.md`;
- documentação do enquadramento do dashboard local em `docs/frontend_roadmap.md`;
- criação de uma camada local demonstrativa com `dashboard_qualidade_ambiental.html`;
- criação de API PowerShell local, experimental e somente leitura em `scripts/start_dashboard_api.ps1`;
- definição de que API dedicada, Power BI, frontend completo, autenticação, deploy, Docker e CI/CD devem ser tratados como projetos derivados.

## Pendências identificadas

- Validar se a constraint de unicidade por amostra e parâmetro atende ao cenário final do projeto.
- Decidir se os limites didáticos serão mantidos ou se haverá revisão normativa posterior.
- Avaliar criação de índices adicionais para consultas analíticas, se o volume de dados crescer.

## Camada local demonstrativa de dashboard

O projeto possui uma camada local de demonstracao para consumo dos indicadores ambientais. Ela nao representa aplicacao produtiva, API corporativa, sistema com autenticacao ou frontend final.

O SQL Server continua sendo a fonte oficial dos dados. O arquivo `dados.csv`, quando usado, e apenas fallback didatico para demonstracao offline ou sem SQL Server ativo.

Arquivos principais:

- `dashboard_qualidade_ambiental.html`: SPA em HTML, Tailwind CSS, PapaParse e Chart.js.
- `docs/contrato_frontend.md`: contrato entre SQL Server, API local read-only e dashboard demonstrativo.
- `docs/frontend_roadmap.md`: enquadramento do dashboard local e separacao de evolucoes futuras como projetos derivados.
- `scripts/start_dashboard_api.ps1`: API PowerShell local, experimental e somente leitura para demonstracao.

Execucao local recomendada:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\start_dashboard_api.ps1 -ServerInstance ".\SQLEXPRESS" -Database "QualidadeAmbiental"
```

Depois acesse:

```text
http://127.0.0.1:5500/dashboard_qualidade_ambiental.html
```

O dashboard tenta carregar dados da API primeiro. Se a API nao estiver disponivel, tenta ler `dados.csv`. Se nenhum dos dois estiver disponivel, exibe dados de demonstracao.

Evolucoes como API dedicada, Power BI, frontend completo, autenticacao, deploy, Docker e CI/CD ficam fora do escopo deste repositorio principal.

## Status final recomendado

Status do projeto: concluivel como portfolio tecnico SQL Server.

O projeto cobre modelagem relacional, carga didatica, views analiticas, indices, plano de execucao, stored procedures, auditoria, backup/restore, staging de importacao, validacao de dados e contrato de dados para consumo externo.

A camada de dashboard/API local e apenas demonstrativa. Evolucoes futuras, como API REST dedicada, Power BI, frontend completo ou deploy, devem ser tratadas como projetos derivados para evitar expansao indefinida do escopo.
