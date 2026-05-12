# Backup, Restore e Validacao Pos-Recuperacao - v1.4.0

## 1. Objetivo da fase v1.4.0

A fase `v1.4.0` tem como objetivo planejar, implementar e validar uma rotina segura de backup, restore e validacao pos-recuperacao para o projeto `QualidadeAmbiental_SQLServer`.

O planejamento orientou a criacao e execucao controlada do script operacional:

```text
sql/migrations/2026-05-12_v1.4.0_backup_restore_validacao.sql
```

O documento registra a estrategia aplicada para:

- gerar backup do banco principal `QualidadeAmbiental`;
- restaurar esse backup em um banco separado de teste;
- validar objetos, dados, regras analiticas, procedures, indices e auditoria no banco restaurado;
- registrar evidencias visuais no SQL Server Management Studio.

## 2. Situacao atual do projeto

O projeto esta na versao `v1.4.0`, com backup completo, verificacao do backup, restore em banco separado e validacao pos-recuperacao realizados no SQL Server Management Studio.

A camada atual possui:

- banco principal `QualidadeAmbiental`;
- 8 tabelas principais do modelo;
- dados didaticos previsiveis;
- views oficiais de conformidade e indicadores;
- consultas analiticas de validacao;
- indices incrementais da v1.1.0;
- stored procedures analiticas parametrizadas da v1.2.0;
- tabela de auditoria e triggers da v1.3.0.

Os indicadores oficiais confirmados continuam sendo:

| Indicador | Valor esperado |
| --- | ---: |
| Total de resultados analiticos | 72 |
| Resultados com limite | 57 |
| Resultados sem limite | 15 |
| Conformes com limite | 50 |
| Nao conformes com limite | 7 |

## 3. Por que backup e restore sao importantes

Backup e restore demonstram uma pratica essencial de DBA: preservar uma copia recuperavel do banco e provar que essa copia pode ser restaurada com consistencia.

Um backup sem teste de restore e incompleto como evidencia tecnica. A fase v1.4.0 deve mostrar nao apenas que um arquivo `.bak` foi gerado, mas que ele pode ser restaurado em outro banco e que os principais objetos e indicadores permanecem coerentes.

No contexto deste projeto, o valor tecnico esta em:

- proteger a base didatica validada;
- demonstrar entendimento de recuperacao;
- separar ambiente principal de ambiente restaurado;
- validar que tabelas, views, procedures, indices e triggers foram preservados;
- confirmar que os indicadores continuam iguais no banco restaurado.

## 4. Diferenca entre backup, restore, auditoria e Git

| Conceito | Finalidade | O que nao substitui |
| --- | --- | --- |
| Backup | Gera uma copia recuperavel do banco de dados em determinado ponto no tempo. | Nao explica historico detalhado de alteracoes como uma auditoria. |
| Restore | Recupera um banco a partir de um backup. | Nao versiona scripts e documentacao como o Git. |
| Auditoria | Registra eventos de alteracao, contexto da operacao e valores antes/depois. | Nao recupera fisicamente arquivos, paginas ou objetos do banco. |
| Git | Versiona scripts SQL, documentacao e evidencias do projeto. | Nao substitui backup do banco de dados ja criado e carregado. |

Backup, auditoria e Git se complementam. O projeto precisa manter essa separacao clara para evitar uma narrativa tecnica incorreta.

## 5. Estrategia recomendada para a fase

A estrategia aplicada na v1.4.0 foi:

1. Fazer backup completo do banco principal `QualidadeAmbiental`.
2. Salvar o arquivo `.bak` em pasta local fora do repositorio Git.
3. Restaurar o backup em banco separado, sugerido como `QualidadeAmbiental_RestoreTeste`.
4. Validar a existencia dos principais objetos no banco restaurado.
5. Comparar os principais indicadores com os valores esperados.
6. Registrar evidencias visuais no SQL Server Management Studio.

Essa abordagem evita risco de sobrescrever o banco principal e comprova que o backup e efetivamente recuperavel.

## 6. Banco de origem e banco de destino

| Papel | Banco | Observacao |
| --- | --- | --- |
| Origem | `QualidadeAmbiental` | Banco principal validado ate a v1.3.0. |
| Destino de teste | `QualidadeAmbiental_RestoreTeste` | Banco restaurado a partir do `.bak`, usado apenas para validacao pos-recuperacao. |

Nao se deve restaurar diretamente sobre `QualidadeAmbiental` nesta fase. O objetivo e validar recuperacao com seguranca, preservando o banco principal como referencia.

## 7. Local sugerido para o arquivo .bak

O arquivo `.bak` deve ficar fora do repositorio Git.

Sugestoes de caminho local:

```text
C:\SQLBackups\QualidadeAmbiental\
```

ou:

```text
C:\SQLServer\Backups\QualidadeAmbiental\
```

O caminho final deve respeitar as permissoes do servico do SQL Server. No Windows, nao basta que o usuario do SSMS tenha acesso a pasta; a conta que executa o servico SQL Server tambem precisa conseguir gravar o backup e ler o arquivo no restore.

Arquivos `.bak` nao devem ser commitados no GitHub porque sao binarios, podem crescer rapidamente e representam artefato operacional local, nao codigo-fonte do projeto.

## 8. Riscos de sobrescrever o banco principal

Restaurar sobre `QualidadeAmbiental` sem necessidade traz riscos desnecessarios:

- perda da base validada;
- dificuldade de comparar origem e destino;
- alteracao acidental de objetos, dados ou auditoria;
- confusao entre banco principal e banco recuperado;
- perda de evidencias se o restore for feito com arquivo errado;
- necessidade de fechar conexoes ativas no banco principal.

Por isso, o restore deve usar banco separado de teste.

## 9. Por que restaurar em banco separado e mais seguro

Restaurar em `QualidadeAmbiental_RestoreTeste` permite validar a recuperacao sem tocar no banco principal.

Essa decisao oferece:

- comparacao direta entre origem e destino;
- preservacao da v1.3.0 ja validada;
- menor risco operacional;
- evidencias mais claras no SSMS;
- possibilidade de descartar o banco restaurado depois da validacao, se necessario.

O banco restaurado deve ser tratado como ambiente de teste de recuperacao, nao como nova fonte oficial do projeto.

## 10. Criterios de validacao pos-restore

A validacao pos-restore deve ser separada em tres niveis.

| Nivel | Objetivo | Exemplos |
| --- | --- | --- |
| Validacao estrutural | Confirmar que objetos do banco foram restaurados. | Tabelas, views, procedures, triggers, indices e constraints. |
| Validacao logica | Confirmar que regras e relacionamentos continuam coerentes. | FKs, checks, resultados sem limite preservados, auditoria existente. |
| Validacao de indicadores | Confirmar que os principais numeros batem com a base oficial. | 72 / 57 / 15 / 50 / 7. |

A validacao ocorreu no banco restaurado `QualidadeAmbiental_RestoreTeste`.

## 11. Objetos que devem ser validados

Objetos minimos para validar no banco restaurado:

| Grupo | Objetos esperados |
| --- | --- |
| Tabelas principais | `Tbl_Responsaveis`, `Tbl_StatusAmostra`, `Tbl_TiposAmostra`, `Tbl_PontosColeta`, `Tbl_Parametros`, `Tbl_Amostras`, `Tbl_ResultadosAnalise`, `Tbl_LimitesReferencia` |
| Views oficiais | `VW_ConformidadeResultados`, `VW_ResultadosForaDoPadrao`, `VW_ResultadosSemLimiteReferencia`, `VW_ConformidadeMensal`, `VW_RankingParametrosCriticos`, `VW_EficienciaRemocaoETE` |
| Indices v1.1.0 | `IX_Tbl_Amostras_DataColeta_Tipo_Ponto`, `IX_Tbl_ResultadosAnalise_Parametro_Amostra` |
| Procedures v1.2.0 | `usp_ConformidadePorPeriodo`, `usp_ResultadosForaPadrao`, `usp_RankingParametrosCriticos` |
| Auditoria v1.3.0 | `Tbl_AuditoriaAlteracoes`, `TRG_Tbl_ResultadosAnalise_Auditoria`, `TRG_Tbl_LimitesReferencia_Auditoria`, `TRG_Tbl_Amostras_Auditoria` |
| Constraints principais | PKs, FKs, unique constraints, checks e default documentados no modelo |

Validar apenas a existencia do banco restaurado nao e suficiente. A fase deve demonstrar que a recuperacao preservou a estrutura tecnica relevante.

## 12. Indicadores que devem ser conferidos

Os indicadores foram conferidos no banco restaurado e comparados com a base oficial:

| Indicador | Valor confirmado |
| --- | ---: |
| Total de amostras | 6 |
| Total de resultados analiticos | 72 |
| Resultados com limite | 57 |
| Resultados sem limite | 15 |
| Conformes com limite | 50 |
| Nao conformes com limite | 7 |

Tambem foram conferidos:

- total de 8 tabelas principais;
- total de 6 views oficiais;
- total de 3 procedures da v1.2.0;
- total de 3 triggers de auditoria ativas;
- total de 2 indices incrementais ativos;
- existencia da tabela `dbo.Tbl_AuditoriaAlteracoes`.

O backup usado na validacao foi gerado apos a v1.3.0, mantendo os objetos de auditoria e os indicadores finais preservados.

## 13. Evidencias visuais esperadas

As evidencias visuais registradas para a v1.4.0 foram:

| Arquivo | O que demonstra |
| --- | --- |
| `docs/evidencias/27_backup_executado_sucesso.png` | Backup completo executado com sucesso. |
| `docs/evidencias/28_restore_verifyonly_sucesso.png` | `RESTORE VERIFYONLY` executado com sucesso. |
| `docs/evidencias/29_restore_filelistonly_logical_names.png` | `RESTORE FILELISTONLY` exibindo os nomes logicos. |
| `docs/evidencias/30_restore_executado_sucesso.png` | Restore executado em banco separado. |
| `docs/evidencias/31_banco_restore_teste_visivel.png` | Banco `QualidadeAmbiental_RestoreTeste` visivel no SSMS. |
| `docs/evidencias/32_validacao_tabelas_restore.png` | Tabelas principais restauradas. |
| `docs/evidencias/33_validacao_views_restore.png` | Views oficiais restauradas. |
| `docs/evidencias/34_validacao_procedures_restore.png` | Procedures da v1.2.0 restauradas. |
| `docs/evidencias/35_validacao_auditoria_restore.png` | Tabela e triggers de auditoria restauradas. |
| `docs/evidencias/36_validacao_indices_restore.png` | Indices da v1.1.0 restaurados. |
| `docs/evidencias/37_validacao_indicadores_restore.png` | Indicadores finais preservados apos restore. |

Os prints foram salvos em `docs/evidencias/`, seguindo a numeracao posterior as evidencias da v1.3.0.

## 14. Limitacoes do ambiente local

Limitacoes esperadas em ambiente local SQL Server Express/SSMS:

- SQL Server Express nao representa uma arquitetura corporativa de alta disponibilidade.
- A fase nao deve afirmar disaster recovery corporativo.
- Permissoes de pasta podem impedir backup ou restore.
- O caminho do arquivo `.bak` precisa ser acessivel ao servico SQL Server.
- O restore em banco separado pode exigir definicao explicita dos caminhos fisicos dos arquivos `.mdf` e `.ldf`.
- Pode ser necessario usar `WITH MOVE` no script futuro para evitar conflito com nomes fisicos ou caminhos existentes.
- O arquivo `.bak` nao deve ser versionado no Git.
- A validacao visual por prints depende do ambiente onde o SSMS foi executado.

Essas limitacoes nao invalidam a fase. Elas ajudam a manter o escopo didatico, honesto e tecnicamente correto.

## 15. Entregas realizadas na v1.4.0

Entregas realizadas:

- documento de planejamento `docs/backup_restore.md`;
- script operacional `sql/migrations/2026-05-12_v1.4.0_backup_restore_validacao.sql`;
- backup completo do banco `QualidadeAmbiental`;
- restore em banco separado `QualidadeAmbiental_RestoreTeste`;
- validacoes estruturais no banco restaurado;
- validacoes logicas no banco restaurado;
- validacoes dos indicadores finais;
- evidencias visuais no SSMS;
- atualizacao de `README.md`, `CHANGELOG.md` e `docs/evidencias_validacao.md` apos implementacao e validacao.

O script operacional futuro deve ser tratado como rotina de DBA, nao como migration de alteracao de schema.

## 16. O que nao sera feito nesta fase

Fora do escopo da v1.4.0:

- restore diretamente sobre o banco principal `QualidadeAmbiental`;
- publicacao de arquivo `.bak` no GitHub;
- automacao corporativa de backup recorrente;
- job de SQL Server Agent;
- alta disponibilidade;
- replicacao;
- log shipping;
- Always On;
- estrategia formal de RPO/RTO corporativo;
- backup diferencial ou backup de log como implementacao obrigatoria;
- criptografia de backup;
- compressao obrigatoria;
- manutencao automatizada de retencao de backups.

Esses temas podem ser mencionados como evolucoes futuras, mas nao devem ser apresentados como implementados no projeto atual.

## 17. Resumo final

A v1.4.0 demonstrou maturidade operacional de DBA sem aumentar risco sobre o banco principal.

A decisao central foi fazer backup de `QualidadeAmbiental` e restaurar em `QualidadeAmbiental_RestoreTeste`, mantendo o banco principal intacto.

O arquivo `.bak` ficou fora do GitHub, em pasta local acessivel ao servico SQL Server. O restore usou banco separado e caminhos fisicos proprios para os arquivos do banco restaurado.

A validacao pos-restore comprovou tres coisas:

- os objetos foram restaurados;
- as regras e estruturas continuam coerentes;
- os indicadores oficiais permanecem iguais aos valores esperados.

Com esse recorte, a fase `v1.4.0` reforcou uma pratica essencial de engenharia de dados e DBA: backup so tem valor tecnico quando o restore tambem e validado.
