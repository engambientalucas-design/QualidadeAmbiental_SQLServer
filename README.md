# QualidadeAmbiental SQL Server

## Resumo executivo

O projeto **QualidadeAmbiental_SQLServer** é um banco de dados relacional em SQL Server aplicado à Engenharia Ambiental, com foco no monitoramento de qualidade de água e esgoto.

A proposta é organizar dados de pontos de coleta, amostras, parâmetros ambientais, resultados laboratoriais, limites de referência e relatórios analíticos. O projeto também tem finalidade de portfólio técnico, demonstrando modelagem relacional, T-SQL, organização de scripts, views analíticas e boas práticas de documentação.

Versão atual: `v1.0.0` - base relacional, carga didática, views analíticas, consultas de validação, documentação técnica e evidências de execução.

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
|   `-- relatorios.md
|-- scripts/
|-- sql/
|   |-- migrations/
|   |   |-- 2026-05-11_v1.1.0_indices_performance.sql
|   |   `-- .gitkeep
|   |-- 01_create_database.sql
|   |-- 02_create_tables.sql
|   |-- 03_insert_cadastros.sql
|   |-- 04_insert_amostras_resultados.sql
|   |-- 05_views_oficiais.sql
|   `-- 06_consultas_analiticas.sql
|-- CHANGELOG.md
|-- dados.csv
|-- dashboard_qualidade_agua.html
|-- dashboard_qualidade_agua_final.html
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
11. Registrar qualquer correção incremental em `sql/migrations/`.
12. Manter o README e os arquivos de `docs/` atualizados a cada evolução relevante.

Caso o projeto mude de ferramenta ou responsável técnico, este README deve ser usado como documentação de referência para entender a finalidade, estrutura, regras e próximos passos.

## Roadmap de evolução

O projeto parte da versão `v1.0.0`, considerada a primeira versão publicável do portfólio. As próximas fases devem ser evoluídas com commits e tags próprias.

| Versão | Foco | Objetivo técnico |
| --- | --- | --- |
| `v1.0.0` | Publicação inicial | Base relacional, dados didáticos, views, consultas analíticas, documentação e evidências. |
| `v1.1.0` | Índices e performance | Índices incrementais para consultas analíticas, critérios técnicos, trade-offs e análise de plano de execução. |
| `v1.2.0` | Stored procedures | Criar procedures úteis para operações e relatórios, evitando objetos artificiais sem valor de negócio. |
| `v1.3.0` | Auditoria e histórico | Adicionar rastreabilidade para alterações relevantes, especialmente resultados e limites de referência. |
| `v1.4.0` | Backup e restore | Documentar e implementar scripts operacionais de backup, restore e validação pós-recuperação. |
| `v2.0.0` | Pipeline de importação | Criar fluxo de carga com staging, validação, tratamento de inconsistências e carga final. |
| `v2.1.0` | Power BI | Construir uma camada visual executiva conectada aos indicadores principais do projeto. |

Melhorias transversais:

- revisar futuramente limites de referência com base normativa, se esse for o objetivo;
- manter documentação, evidências e changelog atualizados a cada evolução relevante;
- registrar decisões técnicas, limitações e critérios de validação por versão.

## Versionamento com Git

O repositório Git foi inicializado na pasta do projeto.

Estado atual do versionamento:

- A versão `v1.0.0` representa a base estável da publicação inicial no GitHub.
- A tag anotada `v1.0.0` já foi criada e publicada no GitHub, apontando para o commit da versão inicial publicável.
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

Status: `v1.1.0` em preparação, com a fase de índices e performance adicionada em script incremental e documentação técnica.

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
- documentação da fase `v1.1.0` em `docs/performance_indices.md`.

Ainda precisa ser concluído:

- execução da migration `v1.1.0` no SQL Server Management Studio;
- análise visual do plano de execução das consultas analíticas após a criação dos índices.

## Pendências identificadas

- Validar se a constraint de unicidade por amostra e parâmetro atende ao cenário final do projeto.
- Decidir se os limites didáticos serão mantidos ou se haverá revisão normativa posterior.
- Avaliar criação de índices adicionais para consultas analíticas, se o volume de dados crescer.
