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
- Dashboard HTML didático para apresentação dos indicadores.

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

## Próximas versões planejadas

| Versão | Foco |
| --- | --- |
| `v1.2.0` | Stored procedures operacionais e analíticas. |
| `v1.3.0` | Auditoria, histórico e rastreabilidade. |
| `v1.4.0` | Backup, restore e validação pós-recuperação. |
| `v2.0.0` | Pipeline de importação com staging e validação. |
| `v2.1.0` | Power BI e camada visual executiva. |
