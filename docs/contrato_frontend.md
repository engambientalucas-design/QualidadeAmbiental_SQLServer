# Contrato Frontend - Dashboard Local Demonstrativo

## Objetivo

Este documento define o contrato minimo entre o SQL Server, a API local somente leitura e o dashboard `dashboard_qualidade_ambiental.html`.

O dashboard atual funciona como uma camada local de demonstracao para consumo dos indicadores ambientais. Ele nao representa uma aplicacao produtiva, mas sim uma interface de portfolio para visualizar dados derivados das views oficiais do SQL Server.

O SQL Server continua sendo a fonte oficial dos dados. O CSV e apenas um artefato de fallback para apresentacao offline ou demonstracao local.

## Fonte oficial

| Uso no frontend | Fonte SQL Server | Observacao |
| --- | --- | --- |
| Tabela de resultados | `dbo.VW_ConformidadeResultados` | Fonte analitica principal. |
| KPIs consolidados | `dbo.VW_ConformidadeResultados` ou `dbo.usp_ConformidadePorPeriodo` | Preferir procedure quando houver filtros de periodo. |
| Grafico de pH | `dbo.VW_ConformidadeResultados` | Filtrar `NomeParametro = 'pH'`. |
| Grafico de carga biologica | `dbo.VW_ConformidadeResultados` | Filtrar `NomeParametro IN ('DBO', 'DQO')`. |
| Ranking critico | `dbo.VW_RankingParametrosCriticos` ou procedure dedicada | Pode ser exposto em endpoint proprio. |
| Resultados fora do padrao | `dbo.VW_ResultadosForaDoPadrao` | Recorte operacional para investigacao. |
| Eficiencia ETE | `dbo.VW_EficienciaRemocaoETE` | Recorte especifico para entrada e saida da ETE. |

## Papel do `dados.csv`

Enquanto a API local nao estiver disponivel, o dashboard aceita um arquivo `dados.csv` na raiz do projeto ou upload manual pelo navegador.

O arquivo `dados.csv` e mantido apenas como fallback didatico para demonstracao sem API ou sem SQL Server ativo. Ele nao substitui a view oficial nem deve ser tratado como fonte definitiva.

| Coluna | Tipo esperado | Obrigatoria? | Origem recomendada | Uso no frontend |
| --- | --- | --- | --- | --- |
| `IdResultado` | Numero inteiro | Nao | `VW_ConformidadeResultados.IdResultado` | Identificacao tecnica. |
| `CodigoAmostra` | Texto | Nao | `VW_ConformidadeResultados.CodigoAmostra` | Identificacao da amostra. |
| `DataColeta` | Data `YYYY-MM-DD` | Sim | `VW_ConformidadeResultados.DataColeta` | Filtros, tabela e graficos. |
| `NomeTipoAmostra` | Texto | Sim | `VW_ConformidadeResultados.NomeTipoAmostra` | Filtro e contexto ambiental. |
| `NomePonto` | Texto | Sim | `VW_ConformidadeResultados.NomePonto` | Busca por ponto de monitoramento. |
| `Municipio` | Texto | Nao | `VW_ConformidadeResultados.Municipio` | Contexto e filtros futuros. |
| `Estado` | Texto | Nao | `VW_ConformidadeResultados.Estado` | Contexto e filtros futuros. |
| `NomeParametro` | Texto | Sim | `VW_ConformidadeResultados.NomeParametro` | Filtro, tabela e graficos. |
| `Categoria` | Texto | Nao | `VW_ConformidadeResultados.Categoria` | Agrupamentos futuros. |
| `ValorResultado` | Decimal | Sim | `VW_ConformidadeResultados.ValorResultado` | KPIs, tabela e graficos. |
| `UnidadeMedida` | Texto | Nao | `VW_ConformidadeResultados.UnidadeMedida` | Exibicao do resultado. |
| `DataAnalise` | Data `YYYY-MM-DD` | Nao | `VW_ConformidadeResultados.DataAnalise` | Rastreabilidade tecnica. |
| `ValorMinimo` | Decimal | Nao | `VW_ConformidadeResultados.ValorMinimo` | Avaliacao visual de conformidade. |
| `ValorMaximo` | Decimal | Nao | `VW_ConformidadeResultados.ValorMaximo` | Avaliacao visual de conformidade. |
| `ClassificacaoResultado` | Texto | Sim | `VW_ConformidadeResultados.ClassificacaoResultado` | Selo de conformidade. |
| `PossuiLimiteReferencia` | `0` ou `1` | Nao | `VW_ConformidadeResultados.PossuiLimiteReferencia` | Diferenciar ausencia de limite. |
| `IndicadorNaoConforme` | `0`, `1` ou vazio | Nao | `VW_ConformidadeResultados.IndicadorNaoConforme` | Destaque automatico de alerta. |

## Classificacoes aceitas

| Valor oficial | Tratamento no frontend |
| --- | --- |
| `Conforme` | Status verde. |
| `Acima do limite maximo` | Status vermelho. |
| `Abaixo do limite minimo` | Status vermelho. |
| `Sem limite de referencia` | Status amarelo. |

O frontend tambem infere o status quando `ClassificacaoResultado` estiver ausente, usando `ValorResultado`, `ValorMinimo` e `ValorMaximo`.

## Endpoints da API local

A API PowerShell e uma implementacao local e somente leitura para demonstracao do consumo das views oficiais pelo dashboard. A implementacao de referencia fica em `scripts/start_dashboard_api.ps1`.

Caso o projeto evolua para uma aplicacao operacional, a API deve ser substituida por uma implementacao dedicada, como .NET Minimal API ou Node.js com driver SQL Server. Essa evolucao deve ser tratada como projeto derivado, nao como requisito do repositorio principal.

| Endpoint | Metodo | Finalidade |
| --- | --- | --- |
| `/` | `GET` | Redireciona para o HTML do dashboard. |
| `/dashboard_qualidade_ambiental.html` | `GET` | Serve a SPA. |
| `/api/health` | `GET` | Informa status da API e conectividade basica. |
| `/api/resultados` | `GET` | Lista resultados da view central. |
| `/api/parametros` | `GET` | Lista parametros disponiveis. |
| `/api/pontos` | `GET` | Lista pontos de coleta disponiveis. |
| `/api/kpis` | `GET` | Retorna indicadores consolidados. |

## Parametros de consulta previstos

| Parametro | Exemplo | Aplicacao |
| --- | --- | --- |
| `dataInicio` | `2026-04-01` | Filtra `DataColeta >= dataInicio`. |
| `dataFim` | `2026-04-30` | Filtra `DataColeta <= dataFim`. |
| `parametro` | `pH` | Filtra por `NomeParametro`. |
| `ponto` | `Saida ETE Sul` | Busca textual em `NomePonto`. |
| `tipoAmostra` | `Esgoto Tratado` | Filtra por `NomeTipoAmostra`. |
| `status` | `nao-conforme` | Filtra classificacoes de conformidade. |
| `page` | `1` | Pagina atual da tabela. |
| `pageSize` | `100` | Quantidade maxima por pagina. |

## Regras de governanca

- O frontend nao deve conter string de conexao, credenciais ou SQL livre.
- A API local deve permanecer somente leitura.
- Nenhum trecho SQL informado pelo navegador deve ser concatenado livremente.
- Qualquer evolucao operacional deve utilizar usuario SQL Server somente leitura, consultas parametrizadas e controle explicito de permissoes.
- Endpoints operacionais com escrita ficam fora do escopo deste dashboard local.
- Os limites de referencia do projeto sao didaticos e nao devem ser apresentados como enquadramento legal ou normativo real.
- Resultados sem limite de referencia nao devem ser ocultados do dashboard.
- A tela deve sempre destacar resultados nao conformes e diferenciar resultados sem limite cadastrado.

## Enquadramento de encerramento

Este contrato frontend complementa o contrato de dados principal documentado em `docs/contrato_dados.md`.

O projeto principal pode ser encerrado como portfolio tecnico SQL Server com esta camada local demonstrativa. API dedicada, Power BI, frontend completo, autenticacao, deploy, Docker e CI/CD devem ser tratados como projetos derivados ou backlog futuro, nao como requisitos para concluir o repositorio principal.
