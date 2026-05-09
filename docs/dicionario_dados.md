# Dicionario de Dados - QualidadeAmbiental_SQLServer

## Objetivo

Este documento apresenta o dicionario de dados tecnico do banco `QualidadeAmbiental`, usado no projeto `QualidadeAmbiental_SQLServer`.

O objetivo e servir como referencia coluna a coluna das tabelas fisicas criadas no SQL Server, documentando tipos de dados, obrigatoriedade, chaves, descricoes e observacoes tecnicas.

A fonte de verdade para este documento e o script `sql/02_create_tables.sql`.

## Escopo do dicionario

Este dicionario cobre as tabelas fisicas criadas pelo script `sql/02_create_tables.sql`.

Fora do escopo deste arquivo:

- Views oficiais e consultas analiticas, documentadas em `docs/relatorios.md`.
- Regras de negocio, classificacoes e limitacoes funcionais, documentadas em `docs/regras_negocio.md`.
- Explicacao conceitual do modelo de dados, documentada em `docs/modelo_dados.md`.

O foco aqui e a estrutura fisica das tabelas: colunas, tipos, obrigatoriedade, chaves, constraints e relacionamentos.

## Convencoes de leitura

| Marcador | Significado |
| --- | --- |
| `PK` | Chave primaria. |
| `FK` | Chave estrangeira. |
| `Unica` | Coluna com constraint `UNIQUE` individual ou participante de regra de unicidade composta. |
| `Nao` | Coluna sem papel direto de chave ou unicidade. |

Regras usadas:

- `Obrigatoria?` recebe `Sim` quando a coluna e `NOT NULL`.
- `Obrigatoria?` recebe `Nao` quando a coluna permite `NULL`.
- Defaults e checks sao registrados em `Observacoes` ou na secao de constraints principais.
- Constraints compostas sao detalhadas na secao `Constraints principais`.

## Tbl_Responsaveis

Finalidade: armazenar responsaveis tecnicos, analistas, coletores ou profissionais associados as amostras.

| Coluna | Tipo de dado | Obrigatoria? | Chave | Descricao | Observacoes |
| --- | --- | --- | --- | --- | --- |
| `IdResponsavel` | `INT` | Sim | PK | Identificador do responsavel. | Chave primaria `PK_Tbl_Responsaveis`. |
| `NomeResponsavel` | `VARCHAR(150)` | Sim | Nao | Nome do responsavel. | Campo obrigatorio. |
| `Cargo` | `VARCHAR(100)` | Nao | Nao | Cargo ou funcao do responsavel. | Campo opcional. |
| `Email` | `VARCHAR(150)` | Nao | Nao | E-mail de contato. | Campo opcional. |
| `Telefone` | `VARCHAR(30)` | Nao | Nao | Telefone de contato. | Campo opcional. |

## Tbl_StatusAmostra

Finalidade: armazenar os status operacionais possiveis para uma amostra.

| Coluna | Tipo de dado | Obrigatoria? | Chave | Descricao | Observacoes |
| --- | --- | --- | --- | --- | --- |
| `IdStatus` | `INT` | Sim | PK | Identificador do status. | Chave primaria `PK_Tbl_StatusAmostra`. |
| `NomeStatus` | `VARCHAR(50)` | Sim | Unica | Nome do status da amostra. | Constraint `UQ_Tbl_StatusAmostra_NomeStatus`. |
| `Descricao` | `VARCHAR(200)` | Nao | Nao | Descricao do status. | Campo opcional. |

## Tbl_TiposAmostra

Finalidade: armazenar os tipos de amostra usados no projeto, como agua bruta, agua tratada, esgoto bruto, esgoto tratado e corpo hidrico.

| Coluna | Tipo de dado | Obrigatoria? | Chave | Descricao | Observacoes |
| --- | --- | --- | --- | --- | --- |
| `IdTipoAmostra` | `INT` | Sim | PK | Identificador do tipo de amostra. | Chave primaria `PK_Tbl_TiposAmostra`. |
| `NomeTipoAmostra` | `VARCHAR(80)` | Sim | Unica | Nome do tipo de amostra. | Constraint `UQ_Tbl_TiposAmostra_NomeTipoAmostra`. |
| `Descricao` | `VARCHAR(200)` | Nao | Nao | Descricao do tipo de amostra. | Campo opcional. |

## Tbl_PontosColeta

Finalidade: armazenar os pontos de coleta, com localizacao, tipo de ponto e coordenadas geograficas opcionais.

| Coluna | Tipo de dado | Obrigatoria? | Chave | Descricao | Observacoes |
| --- | --- | --- | --- | --- | --- |
| `IdPontoColeta` | `INT` | Sim | PK | Identificador do ponto de coleta. | Chave primaria `PK_Tbl_PontosColeta`. |
| `NomePonto` | `VARCHAR(100)` | Sim | Unica | Nome do ponto de coleta. | Participa da unique composta `UQ_Tbl_PontosColeta_NomeMunicipioEstado`. |
| `TipoPonto` | `VARCHAR(80)` | Sim | Nao | Tipo ou categoria do ponto. | Campo obrigatorio. |
| `Municipio` | `VARCHAR(100)` | Sim | Unica | Municipio do ponto de coleta. | Participa da unique composta `UQ_Tbl_PontosColeta_NomeMunicipioEstado`. |
| `Estado` | `CHAR(2)` | Sim | Unica | Unidade federativa do ponto de coleta. | Participa da unique composta `UQ_Tbl_PontosColeta_NomeMunicipioEstado`. |
| `Latitude` | `DECIMAL(9,6)` | Nao | Nao | Latitude do ponto de coleta. | Check permite `NULL` ou valores entre -90 e 90. |
| `Longitude` | `DECIMAL(9,6)` | Nao | Nao | Longitude do ponto de coleta. | Check permite `NULL` ou valores entre -180 e 180. |
| `Observacao` | `VARCHAR(255)` | Nao | Nao | Observacoes sobre o ponto de coleta. | Campo opcional. |

## Tbl_Parametros

Finalidade: armazenar os parametros ambientais analisados nas amostras.

| Coluna | Tipo de dado | Obrigatoria? | Chave | Descricao | Observacoes |
| --- | --- | --- | --- | --- | --- |
| `IdParametro` | `INT` | Sim | PK | Identificador do parametro ambiental. | Chave primaria `PK_Tbl_Parametros`. |
| `NomeParametro` | `VARCHAR(120)` | Sim | Unica | Nome do parametro ambiental. | Constraint `UQ_Tbl_Parametros_NomeParametro`. |
| `UnidadeMedida` | `VARCHAR(30)` | Nao | Nao | Unidade de medida padrao do parametro. | Campo opcional. |
| `Categoria` | `VARCHAR(80)` | Nao | Nao | Categoria tecnica do parametro. | Campo opcional. |
| `Descricao` | `VARCHAR(255)` | Nao | Nao | Descricao do parametro. | Campo opcional. |
| `Ativo` | `BIT` | Sim | Nao | Indica se o parametro esta ativo. | Default `DF_Tbl_Parametros_Ativo` com valor `1`. |

## Tbl_Amostras

Finalidade: registrar amostras coletadas, vinculando ponto de coleta, tipo de amostra, responsavel e status.

| Coluna | Tipo de dado | Obrigatoria? | Chave | Descricao | Observacoes |
| --- | --- | --- | --- | --- | --- |
| `IdAmostra` | `INT` | Sim | PK | Identificador da amostra. | Chave primaria `PK_Tbl_Amostras`. |
| `CodigoAmostra` | `VARCHAR(50)` | Sim | Unica | Codigo unico da amostra. | Constraint `UQ_Tbl_Amostras_CodigoAmostra`. |
| `IdPontoColeta` | `INT` | Sim | FK | Ponto de coleta da amostra. | FK para `Tbl_PontosColeta.IdPontoColeta`. |
| `IdTipoAmostra` | `INT` | Sim | FK | Tipo da amostra. | FK para `Tbl_TiposAmostra.IdTipoAmostra`. |
| `IdResponsavel` | `INT` | Sim | FK | Responsavel associado a amostra. | FK para `Tbl_Responsaveis.IdResponsavel`. |
| `IdStatus` | `INT` | Sim | FK | Status da amostra. | FK para `Tbl_StatusAmostra.IdStatus`. |
| `DataColeta` | `DATE` | Sim | Nao | Data da coleta. | Campo obrigatorio. |
| `HoraColeta` | `TIME(0)` | Nao | Nao | Hora da coleta. | Campo opcional, sem casas de fracao de segundo. |
| `Observacao` | `VARCHAR(255)` | Nao | Nao | Observacoes sobre a amostra. | Campo opcional. |

## Tbl_ResultadosAnalise

Finalidade: registrar os resultados laboratoriais de parametros ambientais medidos em cada amostra.

| Coluna | Tipo de dado | Obrigatoria? | Chave | Descricao | Observacoes |
| --- | --- | --- | --- | --- | --- |
| `IdResultado` | `INT` | Sim | PK | Identificador do resultado analitico. | Chave primaria `PK_Tbl_ResultadosAnalise`. |
| `IdAmostra` | `INT` | Sim | FK, Unica | Amostra associada ao resultado. | FK para `Tbl_Amostras.IdAmostra`; participa da unique composta `UQ_Tbl_ResultadosAnalise_AmostraParametro`. |
| `IdParametro` | `INT` | Sim | FK, Unica | Parametro analisado. | FK para `Tbl_Parametros.IdParametro`; participa da unique composta `UQ_Tbl_ResultadosAnalise_AmostraParametro`. |
| `ValorResultado` | `DECIMAL(18,4)` | Sim | Nao | Valor medido no resultado analitico. | Campo obrigatorio. |
| `UnidadeMedida` | `VARCHAR(30)` | Nao | Nao | Unidade de medida informada no resultado. | Campo opcional. |
| `DataAnalise` | `DATE` | Sim | Nao | Data da analise laboratorial. | Campo obrigatorio. |
| `MetodoAnalise` | `VARCHAR(100)` | Nao | Nao | Metodo de analise utilizado. | Campo opcional. |
| `Observacao` | `VARCHAR(255)` | Nao | Nao | Observacoes sobre o resultado. | Campo opcional. |

## Tbl_LimitesReferencia

Finalidade: armazenar limites minimos e/ou maximos didaticos por combinacao de parametro e tipo de amostra.

Importante: os limites de referencia deste projeto sao didaticos e nao devem ser interpretados como limites legais, regulatorios ou normativos reais.

| Coluna | Tipo de dado | Obrigatoria? | Chave | Descricao | Observacoes |
| --- | --- | --- | --- | --- | --- |
| `IdLimite` | `INT` | Sim | PK | Identificador do limite de referencia. | Chave primaria `PK_Tbl_LimitesReferencia`. |
| `IdParametro` | `INT` | Sim | FK, Unica | Parametro ao qual o limite se aplica. | FK para `Tbl_Parametros.IdParametro`; participa da unique composta `UQ_Tbl_LimitesReferencia_ParametroTipoAmostra`. |
| `IdTipoAmostra` | `INT` | Sim | FK, Unica | Tipo de amostra ao qual o limite se aplica. | FK para `Tbl_TiposAmostra.IdTipoAmostra`; participa da unique composta `UQ_Tbl_LimitesReferencia_ParametroTipoAmostra`. |
| `ValorMinimo` | `DECIMAL(18,4)` | Nao | Nao | Valor minimo didatico permitido. | Deve existir `ValorMinimo` ou `ValorMaximo`. |
| `ValorMaximo` | `DECIMAL(18,4)` | Nao | Nao | Valor maximo didatico permitido. | Deve existir `ValorMinimo` ou `ValorMaximo`. |
| `UnidadeMedida` | `VARCHAR(30)` | Nao | Nao | Unidade de medida do limite. | Campo opcional. |
| `ReferenciaNormativa` | `VARCHAR(150)` | Nao | Nao | Referencia textual associada ao limite. | No projeto atual, usada de forma didatica. |
| `Observacao` | `VARCHAR(255)` | Nao | Nao | Observacoes sobre o limite. | Campo opcional. |

## Constraints principais

### Chaves primarias

| Constraint | Tabela | Coluna |
| --- | --- | --- |
| `PK_Tbl_Responsaveis` | `Tbl_Responsaveis` | `IdResponsavel` |
| `PK_Tbl_StatusAmostra` | `Tbl_StatusAmostra` | `IdStatus` |
| `PK_Tbl_TiposAmostra` | `Tbl_TiposAmostra` | `IdTipoAmostra` |
| `PK_Tbl_PontosColeta` | `Tbl_PontosColeta` | `IdPontoColeta` |
| `PK_Tbl_Parametros` | `Tbl_Parametros` | `IdParametro` |
| `PK_Tbl_Amostras` | `Tbl_Amostras` | `IdAmostra` |
| `PK_Tbl_ResultadosAnalise` | `Tbl_ResultadosAnalise` | `IdResultado` |
| `PK_Tbl_LimitesReferencia` | `Tbl_LimitesReferencia` | `IdLimite` |

### Constraints de unicidade

| Constraint | Tabela | Colunas | Regra |
| --- | --- | --- | --- |
| `UQ_Tbl_StatusAmostra_NomeStatus` | `Tbl_StatusAmostra` | `NomeStatus` | Impede status com nome duplicado. |
| `UQ_Tbl_TiposAmostra_NomeTipoAmostra` | `Tbl_TiposAmostra` | `NomeTipoAmostra` | Impede tipos de amostra com nome duplicado. |
| `UQ_Tbl_PontosColeta_NomeMunicipioEstado` | `Tbl_PontosColeta` | `NomePonto`, `Municipio`, `Estado` | Impede duplicidade do mesmo ponto no mesmo municipio e estado. |
| `UQ_Tbl_Parametros_NomeParametro` | `Tbl_Parametros` | `NomeParametro` | Impede parametros com nome duplicado. |
| `UQ_Tbl_Amostras_CodigoAmostra` | `Tbl_Amostras` | `CodigoAmostra` | Impede codigo de amostra duplicado. |
| `UQ_Tbl_ResultadosAnalise_AmostraParametro` | `Tbl_ResultadosAnalise` | `IdAmostra`, `IdParametro` | Impede repetir o mesmo parametro na mesma amostra. |
| `UQ_Tbl_LimitesReferencia_ParametroTipoAmostra` | `Tbl_LimitesReferencia` | `IdParametro`, `IdTipoAmostra` | Impede mais de um limite para o mesmo parametro e tipo de amostra. |

### Defaults e checks

| Constraint | Tabela | Regra |
| --- | --- | --- |
| `DF_Tbl_Parametros_Ativo` | `Tbl_Parametros` | Define `Ativo` como `1` por padrao. |
| `CK_Tbl_PontosColeta_Latitude` | `Tbl_PontosColeta` | Permite `Latitude` nula ou entre -90 e 90. |
| `CK_Tbl_PontosColeta_Longitude` | `Tbl_PontosColeta` | Permite `Longitude` nula ou entre -180 e 180. |
| `CK_Tbl_LimitesReferencia_LimiteInformado` | `Tbl_LimitesReferencia` | Exige pelo menos `ValorMinimo` ou `ValorMaximo`. |
| `CK_Tbl_LimitesReferencia_MinimoMenorOuIgualMaximo` | `Tbl_LimitesReferencia` | Quando minimo e maximo existirem, exige `ValorMinimo <= ValorMaximo`. |

## Relacionamentos principais

| Constraint | Tabela origem | Coluna origem | Tabela destino | Coluna destino |
| --- | --- | --- | --- | --- |
| `FK_Tbl_Amostras_Tbl_PontosColeta` | `Tbl_Amostras` | `IdPontoColeta` | `Tbl_PontosColeta` | `IdPontoColeta` |
| `FK_Tbl_Amostras_Tbl_TiposAmostra` | `Tbl_Amostras` | `IdTipoAmostra` | `Tbl_TiposAmostra` | `IdTipoAmostra` |
| `FK_Tbl_Amostras_Tbl_Responsaveis` | `Tbl_Amostras` | `IdResponsavel` | `Tbl_Responsaveis` | `IdResponsavel` |
| `FK_Tbl_Amostras_Tbl_StatusAmostra` | `Tbl_Amostras` | `IdStatus` | `Tbl_StatusAmostra` | `IdStatus` |
| `FK_Tbl_ResultadosAnalise_Tbl_Amostras` | `Tbl_ResultadosAnalise` | `IdAmostra` | `Tbl_Amostras` | `IdAmostra` |
| `FK_Tbl_ResultadosAnalise_Tbl_Parametros` | `Tbl_ResultadosAnalise` | `IdParametro` | `Tbl_Parametros` | `IdParametro` |
| `FK_Tbl_LimitesReferencia_Tbl_Parametros` | `Tbl_LimitesReferencia` | `IdParametro` | `Tbl_Parametros` | `IdParametro` |
| `FK_Tbl_LimitesReferencia_Tbl_TiposAmostra` | `Tbl_LimitesReferencia` | `IdTipoAmostra` | `Tbl_TiposAmostra` | `IdTipoAmostra` |

As chaves estrangeiras nao declaram `ON DELETE CASCADE` no script atual. Portanto, o comportamento padrao do SQL Server tende a impedir a exclusao de registros referenciados, preservando a integridade entre cadastros, amostras, resultados e limites.

## Observacoes sobre IDs explicitos

As tabelas usam IDs numericos explicitos e nao usam `IDENTITY`.

Essa decisao esta alinhada ao carater didatico do projeto, pois os scripts de carga usam identificadores fixos para manter os dados previsiveis e facilitar validacoes esperadas.

Em um cenario produtivo, seria necessario avaliar se os IDs continuariam sendo controlados manualmente ou se passariam a usar `IDENTITY`, sequences ou outra estrategia de geracao.

## Observacoes sobre limites didaticos

A tabela `Tbl_LimitesReferencia` armazena limites por parametro e tipo de amostra. No projeto atual, esses limites sao usados para demonstrar classificacoes analiticas como:

- `Conforme`
- `Acima do limite maximo`
- `Abaixo do limite minimo`
- `Sem limite de referencia`

Esses limites sao didaticos e nao representam, por si so, enquadramento legal, regulatorio ou normativo real.

## Limitacoes atuais do modelo

- Nao ha campos de auditoria como usuario de criacao, data de criacao, usuario de alteracao ou data de alteracao.
- Nao ha historico de status da amostra.
- Nao ha historico de vigencia dos limites de referencia.
- Nao ha tabela padronizada para unidades de medida.
- A regra atual de `Tbl_ResultadosAnalise` permite apenas um resultado por parametro em cada amostra.
- Nao ha indices adicionais explicitamente definidos alem das chaves e constraints.
- Nao ha politica avancada de exclusao ou inativacao em todas as tabelas.
- As FKs nao declaram `ON DELETE CASCADE`; exclusoes dependem do comportamento padrao de integridade referencial.

## Evolucoes futuras recomendadas

- Avaliar colunas de auditoria nas tabelas operacionais e em tabelas criticas de cadastro.
- Criar historico de status da amostra.
- Criar vigencia temporal para limites de referencia.
- Normalizar unidades de medida em tabela propria.
- Revisar a regra de unicidade de resultados caso sejam necessarias replicatas, reanalises ou retificacoes.
- Criar indices adicionais para colunas usadas em joins, filtros e agrupamentos.
- Avaliar exclusao logica para cadastros e registros operacionais.
- Revisar limites com fonte normativa real apenas se o projeto deixar de ser didatico.

## Resumo final

Este dicionario de dados documenta a estrutura fisica das 8 tabelas principais do banco `QualidadeAmbiental`.

Ele complementa `docs/modelo_dados.md`, `docs/regras_negocio.md` e `docs/relatorios.md`, oferecendo uma referencia objetiva para leitura tecnica, manutencao, entrevistas e continuidade do projeto.
