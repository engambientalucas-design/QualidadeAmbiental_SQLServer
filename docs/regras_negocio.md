# Regras de Negocio - QualidadeAmbiental_SQLServer

## Objetivo das regras de negocio

Este documento descreve as regras de negocio implementadas ou documentadas no projeto `QualidadeAmbiental_SQLServer`, um banco SQL Server aplicado ao monitoramento didatico de qualidade de agua e esgoto.

O objetivo e deixar claro como os dados devem ser cadastrados, relacionados, validados e interpretados pelas views oficiais do projeto. A documentacao tambem separa regras ja implementadas de limitacoes atuais e evolucoes futuras recomendadas.

Os scripts oficiais da pasta `sql/` sao a fonte de verdade para esta documentacao. Nenhuma regra abaixo deve ser interpretada como norma ambiental real. Os limites de referencia usados no projeto sao didaticos.

## Regras de cadastro

As tabelas de cadastro sustentam a parte operacional e analitica do modelo. Elas devem existir antes da carga de amostras, resultados e limites.

| Tabela | Regra implementada |
| --- | --- |
| `Tbl_Responsaveis` | Cada responsavel possui `IdResponsavel` como chave primaria. |
| `Tbl_StatusAmostra` | Cada status possui `IdStatus` como chave primaria e `NomeStatus` unico. |
| `Tbl_TiposAmostra` | Cada tipo de amostra possui `IdTipoAmostra` como chave primaria e `NomeTipoAmostra` unico. |
| `Tbl_PontosColeta` | Cada ponto possui `IdPontoColeta` como chave primaria e nao pode repetir a combinacao `NomePonto`, `Municipio` e `Estado`. |
| `Tbl_Parametros` | Cada parametro possui `IdParametro` como chave primaria, `NomeParametro` unico e `Ativo` com valor padrao `1`. |

Regras adicionais implementadas:

- Pontos de coleta devem ter `NomePonto`, `TipoPonto`, `Municipio` e `Estado`.
- Latitude e longitude sao opcionais, mas quando informadas precisam respeitar faixas validas: latitude entre -90 e 90; longitude entre -180 e 180.
- Parametros podem ter unidade, categoria e descricao, mas esses campos nao sao obrigatorios no modelo atual.

## Regras de amostras

As amostras representam eventos de coleta. Cada registro em `Tbl_Amostras` precisa estar conectado aos cadastros que contextualizam a coleta.

Regras implementadas:

- Cada amostra deve possuir um identificador unico em `IdAmostra`.
- Cada amostra deve possuir `CodigoAmostra` unico.
- Cada amostra deve estar vinculada a um ponto de coleta por `IdPontoColeta`.
- Cada amostra deve possuir um tipo de amostra por `IdTipoAmostra`.
- Cada amostra deve possuir um responsavel por `IdResponsavel`.
- Cada amostra deve possuir um status por `IdStatus`.
- Cada amostra deve possuir `DataColeta`.
- `HoraColeta` e `Observacao` sao opcionais.

Essas regras sao aplicadas por `NOT NULL`, chave primaria, constraint unique e chaves estrangeiras.

## Regras de resultados analiticos

Os resultados analiticos representam os valores medidos para parametros ambientais em cada amostra.

Regras implementadas:

- Cada resultado deve possuir um identificador unico em `IdResultado`.
- Cada resultado analitico deve estar vinculado a uma amostra existente por `IdAmostra`.
- Cada resultado analitico deve estar vinculado a um parametro ambiental existente por `IdParametro`.
- Cada resultado deve possuir `ValorResultado`.
- Cada resultado deve possuir `DataAnalise`.
- `UnidadeMedida`, `MetodoAnalise` e `Observacao` sao opcionais.
- Um mesmo parametro nao deve se repetir na mesma amostra.

A regra de nao repeticao do parametro na mesma amostra e implementada pela constraint `UQ_Tbl_ResultadosAnalise_AmostraParametro`, definida sobre `IdAmostra` e `IdParametro`.

Limitacao importante: no desenho atual, essa regra impede replicatas, contraprovas ou reanalises do mesmo parametro na mesma amostra. Se esse comportamento for necessario, o modelo precisara evoluir.

## Regras de limites de referencia

Os limites de referencia sao usados para classificar os resultados analiticos nas views oficiais.

Regras implementadas:

- Cada limite deve possuir um identificador unico em `IdLimite`.
- Cada limite deve estar vinculado a um parametro existente por `IdParametro`.
- Cada limite deve estar vinculado a um tipo de amostra existente por `IdTipoAmostra`.
- Os limites de referencia sao definidos por combinacao de parametro e tipo de amostra.
- Nao pode existir mais de um limite para a mesma combinacao de `IdParametro` e `IdTipoAmostra`.
- Cada limite deve possuir pelo menos `ValorMinimo` ou `ValorMaximo`.
- Quando `ValorMinimo` e `ValorMaximo` forem informados juntos, `ValorMinimo` deve ser menor ou igual a `ValorMaximo`.

Essas regras sao implementadas por chave primaria, chaves estrangeiras, constraint unique e checks.

Importante: os limites cadastrados sao didaticos e nao representam norma legal, regulatoria ou ambiental real.

## Regras de conformidade

A classificacao oficial dos resultados e calculada na view `VW_ConformidadeResultados`.

Classificacoes oficiais:

| Classificacao | Regra |
| --- | --- |
| `Sem limite de referencia` | Nao existe limite para a combinacao entre parametro do resultado e tipo da amostra. |
| `Acima do limite maximo` | Existe `ValorMaximo` e `ValorResultado` e maior que esse limite. |
| `Abaixo do limite minimo` | Existe `ValorMinimo` e `ValorResultado` e menor que esse limite. |
| `Conforme` | Existe limite de referencia e o resultado nao viola minimo nem maximo. |

A view tambem calcula:

- `PossuiLimiteReferencia`: retorna `1` quando existe limite associado e `0` quando nao existe.
- `IndicadorNaoConforme`: retorna `1` para resultado fora do limite, `0` para resultado conforme com limite e `NULL` quando nao ha limite de referencia.

Essa distincao e importante porque resultados sem limite nao devem ser contados como conformes nem como nao conformes.

## Regras para resultados sem limite

Resultados sem limite de referencia nao devem desaparecer dos relatorios.

Regra implementada:

- `VW_ConformidadeResultados` usa `LEFT JOIN` com `Tbl_LimitesReferencia`.

Essa decisao preserva todos os resultados analiticos, mesmo quando nao existe limite cadastrado para a combinacao de parametro e tipo de amostra.

Regras derivadas nas views:

- `VW_ResultadosSemLimiteReferencia` lista apenas resultados classificados como `Sem limite de referencia`.
- `VW_ConformidadeMensal` contabiliza resultados com limite e sem limite separadamente.
- `VW_RankingParametrosCriticos` tambem separa resultados com limite e sem limite.

Esse comportamento evita que lacunas da matriz de limites sejam escondidas nos relatorios.

## Regras de eficiencia de remocao da ETE

A view `VW_EficienciaRemocaoETE` calcula a eficiencia didatica de remocao comparando resultados de entrada e saida de uma ETE.

Regras implementadas:

- A entrada e representada por registros com `NomeTipoAmostra = 'Esgoto Bruto'`.
- A saida e representada por registros com `NomeTipoAmostra = 'Esgoto Tratado'`.
- A comparacao ocorre apenas para os parametros:
  - `DBO`
  - `DQO`
  - `Solidos Totais`
  - `Nitrogenio Amoniacal`
  - `Fosforo Total`
- A comparacao deve ocorrer pelo mesmo `IdParametro`.
- O criterio temporal atual e a mesma `DataColeta`.
- Antes da comparacao, a view agrega os valores por parametro, unidade e data de coleta.
- O percentual de remocao e calculado por:

```text
100 * (ValorEsgotoBruto - ValorEsgotoTratado) / ValorEsgotoBruto
```

A view usa `NULLIF` para evitar divisao por zero quando `ValorEsgotoBruto` for zero.

Limitacao atual: a view depende de nomes textuais de tipos de amostra e parametros. Em um modelo mais robusto, essa regra poderia ser configurada por IDs ou por tabela de configuracao.

## Regras de integridade e consistencia

Regras implementadas por constraints:

- Chaves primarias impedem duplicidade de identificadores.
- Chaves estrangeiras impedem que amostras, resultados e limites referenciem cadastros inexistentes.
- Constraints unique impedem duplicidades relevantes para o negocio.
- Checks validam latitude, longitude e consistencia dos limites.

Regras de consistencia analitica:

- A classificacao de conformidade depende da combinacao entre `Tbl_ResultadosAnalise.IdParametro` e `Tbl_Amostras.IdTipoAmostra`.
- Resultados sem limite devem ser preservados e destacados.
- Indicadores de conformidade devem considerar apenas resultados com limite quando calcularem percentuais de conformidade ou nao conformidade.
- A unidade apresentada em `VW_ConformidadeResultados` segue a ordem `Resultado`, `Parametro`, `Limite`, usando `COALESCE`.

Validacoes finais esperadas:

| Validacao | Valor esperado |
| --- | ---: |
| Total de resultados analiticos | 72 |
| Resultados com limite | 57 |
| Resultados sem limite | 15 |
| Conformes com limite | 50 |
| Nao conformes com limite | 7 |

Essas validacoes estao documentadas em `sql/06_consultas_analiticas.sql` e representam consistencia interna do projeto.

## Regras de exclusao e manutencao de dados

O modelo atual nao define `ON DELETE CASCADE` nas chaves estrangeiras.

Consequencias:

- Um responsavel referenciado por amostra nao deve ser excluido diretamente.
- Um ponto de coleta referenciado por amostra nao deve ser excluido diretamente.
- Um tipo de amostra referenciado por amostra ou limite nao deve ser excluido diretamente.
- Um status referenciado por amostra nao deve ser excluido diretamente.
- Um parametro referenciado por resultado ou limite nao deve ser excluido diretamente.
- Uma amostra com resultados analiticos vinculados nao deve ser excluida diretamente.

Na pratica, as FKs protegem a integridade e tendem a bloquear exclusoes de registros referenciados.

Limitacao atual: nao existe politica avancada de exclusao, inativacao ou auditoria de manutencao implementada nos scripts atuais.

Recomendacao futura: para cenarios mais proximos de producao, avaliar exclusao logica, campos de auditoria e processos formais de manutencao.

## Limitacoes atuais

- Nao ha auditoria completa implementada.
- Nao ha historico de alteracoes de resultados analiticos.
- Nao ha historico de status da amostra.
- Nao ha vigencia temporal para limites de referencia.
- Nao ha politica avancada de exclusao ou inativacao para todas as entidades.
- Os limites sao didaticos e nao representam norma legal real.
- A regra atual permite apenas um resultado por parametro em cada amostra.
- A eficiencia de remocao da ETE depende de nomes textuais em vez de uma configuracao parametrizada.
- Nao ha tabela dedicada para unidades de medida.
- Nao ha indices adicionais explicitamente definidos para otimizar consultas analiticas.

## Evolucoes futuras recomendadas

- Criar auditoria para alteracoes em resultados, limites, status e cadastros criticos.
- Criar historico de status da amostra.
- Criar vigencia para limites de referencia, permitindo comparacao conforme a data da coleta ou analise.
- Avaliar exclusao logica para entidades de cadastro e operacionais.
- Criar tabela de unidades de medida para padronizacao.
- Revisar a regra de unicidade de resultados caso sejam necessarias replicatas, reanalises ou retificacoes.
- Criar indices em colunas usadas em joins, filtros e agrupamentos.
- Substituir regras dependentes de texto por configuracoes baseadas em IDs ou tabelas auxiliares.
- Revisar os limites com fonte normativa real apenas se o objetivo do projeto deixar de ser didatico.

## Resumo final

As regras de negocio do `QualidadeAmbiental_SQLServer` mostram que o projeto vai alem de um conjunto de tabelas. O modelo define como amostras, resultados, parametros, limites e classificacoes devem se relacionar para gerar analises ambientais didaticas e consistentes.

As principais decisoes tecnicas sao o uso de chaves estrangeiras para integridade, constraints unique para evitar duplicidades criticas, checks para validar coordenadas e limites, e `LEFT JOIN` nas views de conformidade para preservar resultados sem limite cadastrado.

O modelo atual atende bem ao objetivo de portfolio e entrevista tecnica. Para evoluir em direcao a um uso mais robusto, os pontos mais importantes sao auditoria, historico, vigencia de limites, politica de manutencao e otimizacao de consultas.
