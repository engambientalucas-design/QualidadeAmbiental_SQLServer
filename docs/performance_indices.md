# Performance e Indices - v1.1.0

## Objetivo

Este documento registra a fase `v1.1.0` do projeto `QualidadeAmbiental_SQLServer`, dedicada a indices, performance e analise de plano de execucao.

O objetivo da fase nao e criar muitos indices, mas demonstrar criterio tecnico de DBA: identificar consultas relevantes, entender os joins e agrupamentos do modelo, criar poucos indices justificaveis e documentar os trade-offs.

O script oficial da fase fica em:

```text
sql/migrations/2026-05-11_v1.1.0_indices_performance.sql
```

## Contexto tecnico

A camada analitica do projeto e baseada principalmente na view `VW_ConformidadeResultados`, que consolida:

- resultados analiticos;
- amostras;
- tipos de amostra;
- pontos de coleta;
- responsaveis;
- status;
- parametros;
- limites de referencia.

As demais views e consultas usam essa camada para gerar conformidade geral, conformidade mensal, ranking de parametros criticos, resultados fora do padrao, resultados sem limite e eficiencia de remocao da ETE.

## Indices ja existentes antes da v1.1.0

Antes da fase `v1.1.0`, o projeto ja possuia indices implicitos criados por chaves primarias e constraints `UNIQUE`.

Principais estruturas ja cobertas:

- `PK_Tbl_Amostras` em `Tbl_Amostras.IdAmostra`.
- `UQ_Tbl_Amostras_CodigoAmostra` em `Tbl_Amostras.CodigoAmostra`.
- `PK_Tbl_ResultadosAnalise` em `Tbl_ResultadosAnalise.IdResultado`.
- `UQ_Tbl_ResultadosAnalise_AmostraParametro` em `Tbl_ResultadosAnalise(IdAmostra, IdParametro)`.
- `PK_Tbl_LimitesReferencia` em `Tbl_LimitesReferencia.IdLimite`.
- `UQ_Tbl_LimitesReferencia_ParametroTipoAmostra` em `Tbl_LimitesReferencia(IdParametro, IdTipoAmostra)`.
- `UQ_Tbl_Parametros_NomeParametro` em `Tbl_Parametros.NomeParametro`.
- `UQ_Tbl_TiposAmostra_NomeTipoAmostra` em `Tbl_TiposAmostra.NomeTipoAmostra`.

Essas estruturas ja ajudam joins por chaves primarias, validacao de unicidade e localizacao de limites por parametro e tipo de amostra.

## Indices criados na v1.1.0

### IX_Tbl_Amostras_DataColeta_Tipo_Ponto

Tabela:

```text
dbo.Tbl_Amostras
```

Colunas chave:

```text
DataColeta, IdTipoAmostra, IdPontoColeta
```

Colunas incluidas:

```text
CodigoAmostra, IdResponsavel, IdStatus
```

Justificativa:

Este indice apoia consultas que partem da data de coleta e depois analisam tipo de amostra ou ponto de coleta. Ele tambem favorece relatorios que ordenam ou agrupam resultados por periodo.

Beneficia principalmente:

- `VW_ConformidadeMensal`;
- `VW_EficienciaRemocaoETE`;
- analises por tipo de amostra;
- analises por ponto de coleta;
- listagens ordenadas por `DataColeta`.

### IX_Tbl_ResultadosAnalise_Parametro_Amostra

Tabela:

```text
dbo.Tbl_ResultadosAnalise
```

Colunas chave:

```text
IdParametro, IdAmostra
```

Colunas incluidas:

```text
ValorResultado, UnidadeMedida, DataAnalise, MetodoAnalise
```

Justificativa:

O projeto ja possui a constraint `UQ_Tbl_ResultadosAnalise_AmostraParametro` em `(IdAmostra, IdParametro)`, adequada para buscas que partem da amostra.

O indice `IX_Tbl_ResultadosAnalise_Parametro_Amostra` complementa essa estrutura invertendo a ordem das colunas. Ele favorece consultas que partem do parametro, como ranking de parametros criticos e comparacoes usadas na eficiencia de remocao da ETE.

As chaves primarias clusterizadas sao carregadas implicitamente nos indices nao clusterizados pelo SQL Server, por isso nao foram repetidas nas listas `INCLUDE`.

Beneficia principalmente:

- `VW_RankingParametrosCriticos`;
- `VW_EficienciaRemocaoETE`;
- analises por parametro ambiental;
- joins entre resultados, parametros e amostras.

## Indices nao criados nesta fase

Nao foram criados indices em todas as chaves estrangeiras de forma automatica.

Motivo:

O projeto tem volume didatico e algumas necessidades ja sao parcialmente atendidas por PKs e `UNIQUE`. A fase `v1.1.0` prioriza indices que dialogam diretamente com as consultas analiticas mais importantes.

Tambem nao foram criados indices para:

- `NomeTipoAmostra`;
- `NomeParametro`;
- `NomePonto`;
- `Municipio`;
- `Estado`;
- `ClassificacaoResultado`;
- `ValorResultado`;
- `ValorMinimo`;
- `ValorMaximo`.

Justificativa:

- `NomeTipoAmostra` e `NomeParametro` ja possuem unicidade nas tabelas de cadastro.
- `ClassificacaoResultado` e calculado pela view, nao e coluna persistida.
- Valores numericos de resultado e limite sao usados para classificacao, nao como filtros seletivos principais.
- Indices em excesso aumentariam custo de escrita e manutencao sem ganho claro para o escopo atual.

## Trade-offs

Indices melhoram leituras especificas, mas trazem custos:

- aumentam o trabalho em inserts, updates e deletes;
- ocupam espaco adicional;
- precisam ser mantidos pelo otimizador;
- podem ser pouco usados se nao refletirem consultas reais.

Como o projeto e didatico, o ganho de tempo pode ser pequeno com os dados atuais. Ainda assim, a fase e importante para demonstrar raciocinio profissional de performance em SQL Server.

## Como analisar plano de execucao

No SQL Server Management Studio, recomenda-se:

1. Executar os scripts oficiais ate a criacao das views.
2. Executar a migration `2026-05-11_v1.1.0_indices_performance.sql`.
3. Ativar o plano de execucao real com `Ctrl + M`.
4. Executar consultas de `sql/06_consultas_analiticas.sql`.
5. Observar:
   - uso de `Index Seek` ou `Index Scan`;
   - custo relativo das operacoes;
   - joins mais caros;
   - ordenacoes;
   - sugestoes automaticas de missing indexes, se existirem.

As sugestoes automaticas do SQL Server devem ser analisadas criticamente. Elas nao devem ser aplicadas sem avaliar impacto, duplicidade com indices existentes e padrao real de uso do banco.

## Validacao da migration

O script da `v1.1.0` inclui consultas finais em `sys.indexes`, `sys.index_columns` e `sys.columns` para confirmar:

- indices criados;
- tipo do indice;
- tabelas associadas;
- colunas chave;
- colunas incluidas.

## Validacao executada no SSMS

A migration `sql/migrations/2026-05-11_v1.1.0_indices_performance.sql` foi executada com sucesso no SQL Server Management Studio.

Foram criados e validados os seguintes indices:

### IX_Tbl_Amostras_DataColeta_Tipo_Ponto

Tabela:

```text
dbo.Tbl_Amostras
```

Tipo:

```text
NONCLUSTERED
```

Status:

```text
Ativo, com is_disabled = 0
```

Colunas chave:

```text
DataColeta, IdTipoAmostra, IdPontoColeta
```

Colunas incluidas:

```text
CodigoAmostra, IdResponsavel, IdStatus
```

### IX_Tbl_ResultadosAnalise_Parametro_Amostra

Tabela:

```text
dbo.Tbl_ResultadosAnalise
```

Tipo:

```text
NONCLUSTERED
```

Status:

```text
Ativo, com is_disabled = 0
```

Colunas chave:

```text
IdParametro, IdAmostra
```

Colunas incluidas:

```text
ValorResultado, UnidadeMedida, DataAnalise, MetodoAnalise
```

### Validacao dos indicadores

Apos a criacao dos indices, os indicadores finais permaneceram consistentes:

| Indicador | Valor confirmado |
| --- | ---: |
| Total de resultados analiticos | 72 |
| Resultados com limite | 57 |
| Resultados sem limite | 15 |
| Conformes com limite | 50 |
| Nao conformes com limite | 7 |

Essa validacao confirma que os indices nao alteraram a logica dos dados nem os resultados analiticos esperados. A alteracao foi estrutural, voltada a caminhos de acesso e preparacao para crescimento.

### Plano de execucao real

O recurso de plano de execucao real do SSMS foi ativado para analisar consultas analiticas da fase, incluindo:

- `VW_RankingParametrosCriticos`;
- `VW_EficienciaRemocaoETE`.

Na consulta de ranking de parametros criticos, foi observada operacao de busca em indice nao clusterizado na tabela `Tbl_ResultadosAnalise`, indicando compatibilidade do indice novo com o padrao de acesso da consulta.

Nao foi feita medicao formal de ganho de tempo. Como o dataset atual e didatico e pequeno, com 72 resultados analiticos, nao e adequado afirmar ganho real de performance. O valor tecnico da fase esta na escolha seletiva dos indices, na validacao por catalogo do SQL Server e na analise de plano de execucao.

### Evidencias visuais

As evidencias visuais da `v1.1.0` foram capturadas e salvas em `docs/evidencias/`:

| Arquivo | Evidencia |
| --- | --- |
| `docs/evidencias/09_indices_v1_1_criados.png` | Indices criados e ativos em `sys.indexes`. |
| `docs/evidencias/10_indices_v1_1_colunas.png` | Colunas-chave e colunas incluidas dos indices em `sys.index_columns`. |
| `docs/evidencias/11_validacao_totais_pos_indices.png` | Totais analiticos preservados apos a criacao dos indices. |
| `docs/evidencias/12_plano_execucao_ranking_parametros.png` | Plano de execucao real para ranking de parametros criticos. |
| `docs/evidencias/13_plano_execucao_eficiencia_ete.png` | Plano de execucao real para eficiencia de remocao da ETE. |

Esses prints reforcam a rastreabilidade da fase, mas nao representam medicao formal de ganho de performance.

## Resumo

A fase `v1.1.0` adiciona dois indices nao clusterizados focados nas tabelas operacionais mais importantes:

- `Tbl_Amostras`;
- `Tbl_ResultadosAnalise`.

Essa escolha preserva a simplicidade do projeto, melhora a preparacao para crescimento e demonstra criterio tecnico ao priorizar consultas analiticas reais em vez de criar indices indiscriminadamente. A migration foi executada e validada no SSMS, mantendo os indicadores finais do projeto consistentes.
