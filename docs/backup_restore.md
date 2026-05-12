# Backup, Restore e Validacao Pos-Recuperacao - v1.4.0

## 1. Objetivo da fase v1.4.0

A fase `v1.4.0` tem como objetivo planejar tecnicamente uma rotina segura de backup, restore e validacao pos-recuperacao para o projeto `QualidadeAmbiental_SQLServer`.

Esta etapa e apenas de planejamento. Nao cria scripts SQL, nao executa comandos no banco e nao altera a estrutura atual.

O documento deve orientar a criacao futura de um script operacional para:

- gerar backup do banco principal `QualidadeAmbiental`;
- restaurar esse backup em um banco separado de teste;
- validar objetos, dados, regras analiticas, procedures, indices e auditoria no banco restaurado;
- registrar evidencias visuais no SQL Server Management Studio.

## 2. Situacao atual do projeto

O projeto esta na versao `v1.3.0`, publicada com auditoria, historico, rastreabilidade, triggers, validacoes no SQL Server Management Studio, evidencias visuais e tag anotada no GitHub.

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

A estrategia recomendada para a v1.4.0 e:

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

A validacao deve ocorrer no banco restaurado `QualidadeAmbiental_RestoreTeste`.

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

Os indicadores devem ser conferidos no banco restaurado e comparados com a base oficial:

| Indicador | Valor esperado |
| --- | ---: |
| Total de amostras | 6 |
| Total de resultados analiticos | 72 |
| Resultados com limite | 57 |
| Resultados sem limite | 15 |
| Conformes com limite | 50 |
| Nao conformes com limite | 7 |

Tambem devem ser conferidos:

- total de 47 limites de referencia;
- total de 12 parametros;
- total de 8 eventos de auditoria registrados na v1.3.0, se o backup for gerado apos a validacao da auditoria;
- existencia das 3 triggers de auditoria ativas.

Se o backup for gerado em outro momento, o total de eventos de auditoria pode variar. O documento de evidencias deve registrar o momento exato usado para gerar o `.bak`.

## 13. Evidencias visuais esperadas

Evidencias futuras recomendadas para a v1.4.0:

| Evidencia | O que deve demonstrar |
| --- | --- |
| Backup executado com sucesso | Mensagem de sucesso no SSMS ou resultado do comando operacional futuro. |
| Arquivo `.bak` criado | Arquivo visivel na pasta local de backup, fora do repositorio Git. |
| Restore concluido | Banco `QualidadeAmbiental_RestoreTeste` criado a partir do backup. |
| Banco restaurado visivel no SSMS | Object Explorer exibindo o banco de teste. |
| Tabelas principais restauradas | Consulta ao catalogo confirmando as tabelas esperadas. |
| Views oficiais restauradas | Consulta ao catalogo confirmando as views da camada analitica. |
| Procedures restauradas | Consulta a `sys.procedures` confirmando as procedures da v1.2.0. |
| Indices restaurados | Consulta a `sys.indexes` confirmando indices da v1.1.0. |
| Auditoria restaurada | Tabela `Tbl_AuditoriaAlteracoes` e triggers da v1.3.0 existentes. |
| Indicadores conferidos | Totais 72 / 57 / 15 / 50 / 7 no banco restaurado. |

Os prints devem ser salvos em `docs/evidencias/`, seguindo a numeracao posterior as evidencias da v1.3.0.

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

## 15. Entregas previstas para v1.4.0

Entregas previstas:

- documento de planejamento `docs/backup_restore.md`;
- script operacional futuro para backup e restore;
- backup completo do banco `QualidadeAmbiental`;
- restore em banco separado `QualidadeAmbiental_RestoreTeste`;
- validacoes estruturais no banco restaurado;
- validacoes logicas no banco restaurado;
- validacoes dos indicadores finais;
- evidencias visuais no SSMS;
- atualizacao futura de `README.md`, `CHANGELOG.md` e `docs/evidencias_validacao.md` apos implementacao e validacao.

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

A v1.4.0 deve demonstrar maturidade operacional de DBA sem aumentar risco sobre o banco principal.

A decisao central e fazer backup de `QualidadeAmbiental` e restaurar em `QualidadeAmbiental_RestoreTeste`, mantendo o banco principal intacto.

O arquivo `.bak` deve ficar fora do GitHub, em pasta local acessivel ao servico SQL Server. O script futuro deve considerar permissoes de pasta e possivel uso de `WITH MOVE` para os arquivos fisicos do banco restaurado.

A validacao pos-restore deve comprovar tres coisas:

- os objetos foram restaurados;
- as regras e estruturas continuam coerentes;
- os indicadores oficiais permanecem iguais aos valores esperados.

Com esse recorte, a fase `v1.4.0` reforca uma pratica essencial de engenharia de dados e DBA: backup so tem valor tecnico quando o restore tambem e validado.
