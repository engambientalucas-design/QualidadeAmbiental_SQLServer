# Relatorios e Indicadores - QualidadeAmbiental_SQLServer

## Objetivo dos relatorios

Este documento descreve a camada analitica do projeto `QualidadeAmbiental_SQLServer`, formada por views oficiais e consultas de validacao presentes nos scripts `sql/05_views_oficiais.sql` e `sql/06_consultas_analiticas.sql`.

O objetivo e explicar quais perguntas tecnicas e de negocio cada relatorio responde, quais indicadores sao gerados e como interpretar os resultados no contexto de um projeto didatico de monitoramento de qualidade de agua e esgoto.

Os limites de referencia usados nos relatorios sao didaticos e nao representam limites legais, regulatorios ou normativos reais.

## Visao geral da camada analitica

A camada analitica foi organizada sobre a view central `VW_ConformidadeResultados`. Essa view consolida amostras, pontos de coleta, tipos de amostra, responsaveis, status, parametros, resultados analiticos e limites de referencia.

A partir dela, o projeto gera relatorios de:

- conformidade geral;
- resultados fora do padrao;
- resultados sem limite de referencia;
- conformidade mensal;
- ranking de parametros criticos;
- eficiencia de remocao da ETE;
- analises por tipo de amostra;
- analises por ponto de coleta;
- checklist final de validacao.

Um ponto tecnico importante e o uso de `LEFT JOIN` entre resultados e limites na view `VW_ConformidadeResultados`. Essa decisao preserva resultados sem limite cadastrado e permite que eles sejam analisados explicitamente, em vez de desaparecerem dos relatorios.

## Views oficiais

| View | Finalidade principal |
| --- | --- |
| `VW_ConformidadeResultados` | Base analitica central para classificacao dos resultados. |
| `VW_ResultadosForaDoPadrao` | Lista resultados classificados como acima ou abaixo dos limites didaticos. |
| `VW_ResultadosSemLimiteReferencia` | Lista resultados sem limite de referencia cadastrado. |
| `VW_ConformidadeMensal` | Consolida indicadores mensais de conformidade. |
| `VW_RankingParametrosCriticos` | Ranking de parametros por nao conformidade. |
| `VW_EficienciaRemocaoETE` | Calcula eficiencia de remocao comparando esgoto bruto e tratado. |

As consultas do arquivo `sql/06_consultas_analiticas.sql` usam essas views para validacao, auditoria tecnica e apresentacao de indicadores.

## Relatorio de conformidade geral

Pergunta respondida: quantos resultados possuem limite, quantos nao possuem limite, quantos estao conformes e quantos estao nao conformes?

Fonte principal:

- View: `VW_ConformidadeResultados`
- Consulta: validacao consolidada da conformidade em `sql/06_consultas_analiticas.sql`

Indicadores principais:

| Indicador | Valor confirmado |
| --- | ---: |
| Total de resultados analiticos | 72 |
| Resultados com limite | 57 |
| Resultados sem limite | 15 |
| Conformes com limite | 50 |
| Nao conformes com limite | 7 |

Como interpretar:

- `Total de resultados analiticos` representa todos os registros classificados pela view central.
- `Resultados com limite` sao aqueles que encontraram combinacao correspondente em `Tbl_LimitesReferencia`.
- `Resultados sem limite` indicam lacunas didaticas na matriz de limites.
- `Conformes com limite` sao resultados dentro dos limites minimos e maximos cadastrados.
- `Nao conformes com limite` sao resultados acima do limite maximo ou abaixo do limite minimo.

Limitacao atual: os limites sao didaticos. Portanto, a leitura de conformidade deve ser entendida como demonstracao tecnica, nao como conclusao normativa real.

## Relatorio de resultados fora do padrao

Pergunta respondida: quais resultados analiticos violaram algum limite didatico?

Fonte principal:

- View: `VW_ResultadosForaDoPadrao`
- Consulta: resultados fora do padrao em `sql/06_consultas_analiticas.sql`

Campos principais:

- `IdResultado`
- `CodigoAmostra`
- `DataColeta`
- `NomeTipoAmostra`
- `NomePonto`
- `NomeParametro`
- `ValorResultado`
- `UnidadeMedida`
- `ValorMinimo`
- `ValorMaximo`
- `ClassificacaoResultado`

Classificacoes consideradas:

- `Acima do limite maximo`
- `Abaixo do limite minimo`

Como interpretar:

- Um resultado `Acima do limite maximo` indica que `ValorResultado` superou `ValorMaximo`.
- Um resultado `Abaixo do limite minimo` indica que `ValorResultado` ficou abaixo de `ValorMinimo`.
- O relatorio deve ser usado para identificar pontos, tipos de amostra e parametros que exigiriam investigacao tecnica em um cenario real.

Limitacao atual: a view nao calcula severidade, reincidencia ou impacto ambiental. Ela apenas identifica a violacao do limite didatico.

## Relatorio de resultados sem limite de referencia

Pergunta respondida: quais resultados nao puderam ser classificados por falta de limite cadastrado?

Fonte principal:

- View: `VW_ResultadosSemLimiteReferencia`
- Consulta: resultados sem limite de referencia em `sql/06_consultas_analiticas.sql`

Campos principais:

- `IdResultado`
- `CodigoAmostra`
- `DataColeta`
- `NomeTipoAmostra`
- `NomePonto`
- `NomeParametro`
- `Categoria`
- `ValorResultado`
- `UnidadeMedida`
- `ClassificacaoResultado`

Como interpretar:

- Esses registros nao sao conformes nem nao conformes.
- Eles indicam que a combinacao entre parametro e tipo de amostra nao possui limite em `Tbl_LimitesReferencia`.
- O total confirmado no projeto e de 15 resultados sem limite.

Esse relatorio e importante porque transforma ausencia de regra em informacao visivel. Sem o `LEFT JOIN` na view central, esses registros poderiam ser ocultados em relatorios baseados apenas em limites cadastrados.

## Relatorio de conformidade mensal

Pergunta respondida: qual e a conformidade dos resultados por mes de coleta?

Fonte principal:

- View: `VW_ConformidadeMensal`
- Consulta: conformidade mensal em `sql/06_consultas_analiticas.sql`

Indicadores principais:

- `AnoColeta`
- `MesColeta`
- `TotalResultados`
- `ResultadosComLimite`
- `ResultadosSemLimite`
- `ResultadosConformesComLimite`
- `ResultadosNaoConformesComLimite`
- `PercentualConformidadeComLimite`

Como interpretar:

- O percentual de conformidade considera apenas resultados com limite.
- Resultados sem limite sao contados separadamente e nao entram como conformes ou nao conformes.
- O agrupamento usa `YEAR(DataColeta)` e `MONTH(DataColeta)`.

Limitacao atual: o conjunto didatico possui poucos meses de dados. Em um cenario maior, esse relatorio ganharia valor para analise temporal, tendencia e sazonalidade.

## Ranking de parametros criticos

Pergunta respondida: quais parametros concentram maior numero ou percentual de nao conformidades?

Fonte principal:

- View: `VW_RankingParametrosCriticos`
- Consulta: ranking de parametros criticos em `sql/06_consultas_analiticas.sql`

Indicadores principais:

- `IdParametro`
- `NomeParametro`
- `Categoria`
- `TotalResultados`
- `ResultadosComLimite`
- `ResultadosSemLimite`
- `TotalNaoConformidades`
- `PercentualNaoConformidadeComLimite`

Como interpretar:

- Parametros com maior `TotalNaoConformidades` merecem atencao prioritaria.
- O percentual de nao conformidade e calculado sobre resultados com limite.
- Parametros com muitos resultados sem limite indicam possivel necessidade de revisar a matriz didatica de limites.

Limitacao atual: o ranking nao pondera severidade, recorrencia por ponto de coleta nem criticidade ambiental real.

## Relatorio de eficiencia de remocao da ETE

Pergunta respondida: qual e a eficiencia de remocao entre esgoto bruto e esgoto tratado para parametros selecionados?

Fonte principal:

- View: `VW_EficienciaRemocaoETE`
- Consulta: eficiencia de remocao da ETE em `sql/06_consultas_analiticas.sql`

Regra atual:

- compara `Esgoto Bruto` com `Esgoto Tratado`;
- usa o mesmo `IdParametro`;
- usa a mesma `DataColeta`;
- considera os parametros `DBO`, `DQO`, `Solidos Totais`, `Nitrogenio Amoniacal` e `Fosforo Total`;
- calcula a media dos valores antes da comparacao;
- usa `NULLIF` para evitar divisao por zero.

Indicadores principais:

- `IdParametro`
- `NomeParametro`
- `UnidadeMedida`
- `DataColetaComparacao`
- `ValorEsgotoBruto`
- `ValorEsgotoTratado`
- `PercentualRemocao`
- `CodigoAmostraEntrada`
- `CodigoAmostraSaida`
- `TotalResultadosEntrada`
- `TotalResultadosSaida`

Formula:

```text
100 * (ValorEsgotoBruto - ValorEsgotoTratado) / ValorEsgotoBruto
```

Como interpretar:

- Percentual positivo indica reducao do valor no esgoto tratado em relacao ao bruto.
- Percentual negativo indicaria aumento do valor apos tratamento.
- Percentual nulo indicaria ausencia de alteracao entre entrada e saida.

Limitacao atual: a comparacao depende de nomes textuais de tipos de amostra e parametros. Uma evolucao futura poderia parametrizar essa regra por IDs ou tabela de configuracao.

## Analises por tipo de amostra e ponto de coleta

### Analise por tipo de amostra

Pergunta respondida: quais tipos de amostra concentram mais resultados, resultados sem limite e nao conformidades?

Fonte:

- Consulta 10 de `sql/06_consultas_analiticas.sql`
- Base: `VW_ConformidadeResultados`

Indicadores:

- `NomeTipoAmostra`
- `TotalResultados`
- `ResultadosComLimite`
- `ResultadosSemLimite`
- `ConformesComLimite`
- `NaoConformesComLimite`

Como interpretar:

- Tipos de amostra com mais nao conformidades podem representar maior criticidade didatica.
- Tipos com muitos resultados sem limite indicam lacunas na matriz de limites.

### Analise por ponto de coleta

Pergunta respondida: quais pontos de coleta concentram mais nao conformidades?

Fonte:

- Consulta 11 de `sql/06_consultas_analiticas.sql`
- Base: `VW_ConformidadeResultados`

Indicadores:

- `NomePonto`
- `TipoPonto`
- `Municipio`
- `Estado`
- `TotalResultados`
- `NaoConformesComLimite`

Como interpretar:

- Pontos com maior quantidade de nao conformidades devem ser destacados em analises exploratorias.
- Em um cenario real, esse relatorio poderia apoiar priorizacao de investigacao em campo.

Limitacao atual: a consulta usa quantidade absoluta de nao conformidades. Nao ha calculo de taxa por ponto de coleta.

## Checklist final de validacao

Pergunta respondida: o banco esta consistente com os totais esperados do projeto?

Fonte:

- Consulta 12 de `sql/06_consultas_analiticas.sql`
- Base: `VW_ConformidadeResultados`

Validacoes confirmadas:

| Validacao | Valor esperado |
| --- | ---: |
| Total de resultados analiticos | 72 |
| Resultados com limite | 57 |
| Resultados sem limite | 15 |
| Conformes com limite | 50 |
| Nao conformes com limite | 7 |

Como interpretar:

- A coluna `Situacao` deve retornar `OK` para cada item.
- Resultado `DIVERGENTE` indicaria problema em carga de dados, matriz de limites, view de conformidade ou alteracao nao planejada.

Esse checklist e uma evidencia tecnica importante para o portfolio, pois demonstra que os scripts nao apenas criam objetos, mas tambem produzem resultados validaveis.

## Como usar esses relatorios no portfolio

Os relatorios podem ser apresentados como uma narrativa tecnica:

1. O modelo registra amostras ambientais e resultados laboratoriais.
2. A view `VW_ConformidadeResultados` consolida dados operacionais e limites didaticos.
3. Os relatorios identificam conformidade, nao conformidade e ausencia de limite.
4. Os indicadores mensais e rankings mostram capacidade analitica.
5. A view de eficiencia de remocao demonstra uso de CTEs, agregacao e comparacao tecnica entre entrada e saida.
6. O checklist final comprova consistencia entre dados carregados e resultados esperados.

Em entrevista tecnica, vale destacar:

- uso de `LEFT JOIN` para preservar resultados sem limite;
- separacao entre resultados conformes, nao conformes e sem limite;
- uso de views para criar camada semantica;
- uso de `NULLIF` para evitar divisao por zero;
- limitacoes conhecidas e evolucoes futuras.

## Prints recomendados para apresentacao

Esta secao apenas recomenda evidencias uteis. Ela nao assume que os prints ja existem e nao substitui a execucao manual no SSMS ou em dashboard.

Prints recomendados:

- Resultado do checklist final com todos os itens em `OK`.
- Consulta de validacao consolidada da conformidade.
- Lista de resultados fora do padrao.
- Lista de resultados sem limite de referencia.
- Resultado de `VW_ConformidadeMensal`.
- Resultado de `VW_RankingParametrosCriticos`.
- Resultado de `VW_EficienciaRemocaoETE`.
- Estrutura das views oficiais no SSMS.
- Dashboard HTML do projeto, se usado como demonstracao visual complementar.

Essas evidencias ajudam a mostrar fluxo completo: modelagem, carga, validacao, analise e comunicacao dos resultados.

## Limitacoes atuais dos relatorios

- Os limites de referencia sao didaticos e nao representam norma real.
- Os relatorios nao possuem camada de seguranca ou controle de acesso.
- Nao ha auditoria completa de alteracoes nos dados.
- Nao ha historico de vigencia para limites de referencia.
- A eficiencia de remocao depende de nomes textuais e da mesma `DataColeta`.
- O ranking de parametros nao pondera severidade ambiental.
- As analises por ponto de coleta usam contagem absoluta, sem taxa normalizada.
- O volume de dados e didatico, portanto os indicadores ainda nao representam comportamento estatistico robusto.

## Evolucoes futuras recomendadas

- Criar `docs/dicionario_dados.md` para detalhar campos usados nos relatorios.
- Criar indices para otimizar joins, filtros por data e agrupamentos.
- Criar relatorios com taxa de nao conformidade por ponto de coleta.
- Criar analises temporais mais detalhadas, como tendencia por parametro.
- Criar vigencia de limites para permitir comparacoes historicas.
- Parametrizar a regra da ETE por IDs ou tabela de configuracao.
- Criar visoes ou consultas especificas para dashboards.
- Revisar limites com base normativa real apenas se o projeto deixar de ser didatico.

## Resumo final

A camada analitica do `QualidadeAmbiental_SQLServer` demonstra que o projeto nao apenas armazena dados ambientais, mas tambem gera indicadores uteis de conformidade, lacunas de referencia, criticidade e eficiencia.

As views oficiais organizam uma camada semantica clara sobre o modelo relacional. As consultas analiticas validam os dados carregados e produzem resultados interpretaveis para portfolio e entrevista tecnica.

Com `modelo_dados.md`, `regras_negocio.md` e este documento de relatorios, o projeto passa a ter uma narrativa completa: estrutura, regras e analise.
