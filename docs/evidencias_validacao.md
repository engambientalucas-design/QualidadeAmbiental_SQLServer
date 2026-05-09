# Evidencias de Validacao - QualidadeAmbiental_SQLServer

## Objetivo das evidencias

Este documento organiza as evidencias de validacao do projeto `QualidadeAmbiental_SQLServer`.

O objetivo e registrar quais scripts foram executados, quais validacoes foram confirmadas e quais prints devem ser capturados para comprovar visualmente que o banco `QualidadeAmbiental` foi executado e validado em ambiente real.

As evidencias visuais complementam os scripts SQL e a documentacao tecnica. Elas nao substituem os scripts oficiais, mas ajudam a demonstrar rastreabilidade, consistencia e maturidade do projeto em contexto de portfolio.

## Ambiente de validacao

Ambiente informado para validacao:

- Banco de dados: `QualidadeAmbiental`
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

## Evidencias visuais planejadas

As evidencias visuais devem ser salvas na pasta:

```text
docs/evidencias/
```

Os prints recomendados foram capturados e salvos na pasta `docs/evidencias/`.

## Relacao de prints recomendados

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
