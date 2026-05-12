# Auditoria, Historico e Rastreabilidade - v1.3.0

## 1. Objetivo da fase v1.3.0

A fase `v1.3.0` tem como objetivo planejar tecnicamente uma camada enxuta de auditoria, historico e rastreabilidade para o projeto `QualidadeAmbiental_SQLServer`.

Esta etapa e apenas de planejamento. Nao cria tabelas de auditoria, triggers ou scripts SQL.

O documento deve orientar a criacao futura de uma migration no padrao:

```text
sql/migrations/YYYY-MM-DD_v1.3.0_auditoria_historico.sql
```

A data final do arquivo deve ser definida no momento da implementacao da fase.

## 2. Situacao atual do projeto

O projeto esta na versao `v1.2.0`, publicada com stored procedures analiticas parametrizadas, validacoes no SQL Server Management Studio, evidencias visuais e tag anotada publicada no GitHub.

A camada atual possui:

- tabelas relacionais principais;
- dados didaticos previsiveis;
- views oficiais de conformidade e indicadores;
- consultas analiticas de validacao;
- indices incrementais da v1.1.0;
- stored procedures analiticas parametrizadas da v1.2.0.

Ainda nao existem campos de auditoria, historico de alteracoes, historico de status ou vigencia temporal de limites. Esses pontos ja aparecem como limitacoes e evolucoes futuras nos documentos `docs/modelo_dados.md`, `docs/regras_negocio.md` e `docs/dicionario_dados.md`.

## 3. Por que auditar dados

Auditoria de dados serve para registrar alteracoes relevantes em tabelas sensiveis, permitindo responder perguntas como:

- qual registro foi alterado;
- qual operacao ocorreu;
- quando ocorreu;
- por qual login SQL;
- de qual host e aplicacao veio a alteracao;
- quais valores existiam antes;
- quais valores passaram a existir depois.

No contexto deste projeto, a auditoria deve proteger principalmente a rastreabilidade das informacoes que afetam conformidade, indicadores e interpretacao tecnica dos resultados.

Auditoria nao deve ser criada apenas para aumentar o numero de objetos do banco. Ela precisa ter utilidade clara para investigacao, manutencao e demonstracao tecnica.

## 4. Diferenca entre auditoria, historico e backup

Auditoria registra eventos de alteracao em dados, normalmente com contexto da operacao e snapshots antes/depois.

Historico preserva evolucao de estado ou vigencia de informacoes ao longo do tempo. Exemplo: historico de status de amostra ou vigencia de limites de referencia.

Backup preserva uma copia recuperavel do banco ou de seus arquivos em determinado ponto no tempo.

Auditoria nao substitui backup. Backup tambem nao substitui auditoria. Um backup permite recuperar dados; uma auditoria ajuda a explicar o que mudou, quando mudou e por qual contexto tecnico.

## 5. Criterios para escolher tabelas auditaveis

A v1.3.0 nao deve auditar todas as tabelas. A escolha deve priorizar tabelas cuja alteracao possa mudar resultados analiticos, conformidade, rankings, evidencias ou interpretacao tecnica.

Criterios adotados:

- impacto direto nas views oficiais;
- impacto nos indicadores validados;
- impacto em stored procedures analiticas da v1.2.0;
- risco de alteracao manual pos-carga;
- necessidade de rastrear correcao, exclusao ou retificacao;
- valor claro para portfolio e entrevista tecnica;
- baixo risco de gerar ruido excessivo.

Auditoria da v1.3.0 deve priorizar alteracoes manuais ou futuras manutencoes pos-carga. A carga didatica inicial do projeto nao deve ser tratada como principal caso de uso da auditoria.

## 6. Tabelas candidatas a auditoria

As principais candidatas sao:

- `Tbl_ResultadosAnalise`;
- `Tbl_LimitesReferencia`;
- `Tbl_Amostras`.

Essas tabelas sustentam a classificacao de conformidade, os indicadores, os rankings e as consultas parametrizadas.

Tabelas de cadastro tambem podem afetar interpretacao, mas nao devem entrar automaticamente na primeira implementacao.

## 7. Avaliacao das tabelas candidatas

| Tabela | Importancia para o negocio | Impacto se alterada | Eventos sugeridos | Classificacao | Justificativa |
| --- | --- | --- | --- | --- | --- |
| `Tbl_ResultadosAnalise` | Armazena os valores medidos por parametro em cada amostra. | Altera conformidade, resultados fora do padrao, ranking de parametros criticos, totais e evidencias. | `UPDATE`, `DELETE`; avaliar `INSERT` com cautela. | Auditar agora | E a tabela mais sensivel para a leitura analitica. Alteracoes em valor, parametro, amostra ou data de analise mudam diretamente os indicadores. |
| `Tbl_LimitesReferencia` | Define limites didaticos por parametro e tipo de amostra. | Altera a classificacao dos resultados e a separacao entre conforme, nao conforme e sem limite. | `UPDATE`, `DELETE`; avaliar `INSERT` com cautela. | Auditar agora | Mudancas em limites podem reinterpretar resultados ja existentes, mesmo sem alterar os resultados laboratoriais. |
| `Tbl_Amostras` | Registra data, ponto, tipo, responsavel e status da coleta. | Altera periodo, ponto, tipo de amostra, matriz de limites aplicada e agrupamentos analiticos. | `UPDATE`, `DELETE`; avaliar `INSERT` com cautela. | Auditar agora | Mudancas em `DataColeta`, `IdPontoColeta` ou `IdTipoAmostra` impactam filtros, views e procedures parametrizadas. |
| `Tbl_Parametros` | Define parametros ambientais, unidade padrao, categoria e status ativo. | Afeta nomes, categorias e interpretacao dos resultados e limites. | `UPDATE`, `DELETE`. | Adiar | E importante, mas muda pouco no escopo didatico. Deve ser considerada em fase posterior ou se houver manutencao de cadastros tecnicos. |
| `Tbl_TiposAmostra` | Define tipos usados em amostras e limites. | Pode afetar interpretacao de limites e regras dependentes de tipo de amostra. | `UPDATE`, `DELETE`. | Adiar | Possui impacto real, mas a primeira fase deve priorizar tabelas operacionais e limites. |
| `Tbl_PontosColeta` | Define locais de coleta e contexto geografico. | Altera interpretacao espacial de amostras e analises por ponto. | `UPDATE`, `DELETE`. | Adiar | Relevante para rastreabilidade espacial, mas menos critico que resultados, limites e amostras na primeira implementacao. |
| `Tbl_StatusAmostra` | Define catalogo de status possiveis. | Afeta leitura operacional do status, mas nao altera diretamente conformidade. | `UPDATE`, `DELETE`. | Fora do escopo | O projeto nao possui historico de workflow operacional nesta fase. Pode ser reconsiderada junto com historico de status. |
| `Tbl_Responsaveis` | Armazena responsaveis tecnicos associados a amostras. | Afeta rastreabilidade de responsabilidade, mas nao altera indicadores analiticos. | `UPDATE`, `DELETE`. | Fora do escopo | Baixa prioridade para a v1.3.0. Auditoria aqui pode gerar escopo sem ganho direto para a camada analitica. |

## 8. Tabelas recomendadas para implementacao inicial

As tabelas recomendadas para a primeira implementacao sao:

1. `Tbl_ResultadosAnalise`
2. `Tbl_LimitesReferencia`
3. `Tbl_Amostras`

Esse recorte e suficiente para demonstrar auditoria com valor real sem transformar a v1.3.0 em uma camada ampla e artificial.

## 9. Tabelas adiadas ou fora do escopo inicial

Devem ser adiadas:

- `Tbl_Parametros`;
- `Tbl_TiposAmostra`;
- `Tbl_PontosColeta`.

Essas tabelas tem impacto tecnico, mas podem ser auditadas em uma fase posterior, caso o projeto passe a tratar manutencao formal de cadastros tecnicos.

Devem ficar fora do escopo inicial:

- `Tbl_StatusAmostra`;
- `Tbl_Responsaveis`.

No desenho atual, essas tabelas nao alteram diretamente a classificacao de conformidade ou os indicadores principais. Historico de status deve ser tratado como evolucao propria, nao como auditoria generica da tabela de status.

## 10. Eventos a auditar: INSERT, UPDATE e DELETE

Eventos recomendados para a primeira implementacao:

| Evento | Recomendacao | Motivo |
| --- | --- | --- |
| `INSERT` | Avaliar com cautela | Pode gerar ruido se a auditoria for usada durante cargas didaticas. Faz mais sentido para inclusoes manuais pos-carga ou novas manutencoes. |
| `UPDATE` | Auditar agora | Principal evento para rastrear correcao, retificacao ou alteracao de dados que afetam indicadores. |
| `DELETE` | Auditar agora | Exclusoes podem remover evidencias analiticas e precisam de rastreabilidade. FKs reduzem alguns riscos, mas nao substituem auditoria. |

Nao se deve planejar auditoria de `SELECT` nesta fase. Triggers DML nao capturam leitura de dados. Auditoria de consulta exigiria outra abordagem, como SQL Server Audit, Extended Events ou controle na camada de aplicacao.

## 11. Campos minimos de auditoria

| Campo | Finalidade | Observacao tecnica |
| --- | --- | --- |
| `IdAuditoria` | Identificador unico do evento de auditoria. | Pode ser `INT IDENTITY` ou outro mecanismo definido na implementacao. |
| `NomeTabela` | Indicar a tabela auditada. | Necessario em estrategia de tabela unica generica. |
| `IdRegistroAfetado` | Identificar o registro alterado. | Deve armazenar o ID principal do registro afetado como texto ou inteiro, conforme decisao futura. |
| `Operacao` | Registrar `INSERT`, `UPDATE` ou `DELETE`. | Pode usar `VARCHAR(10)` com validacao por `CHECK`. |
| `DataHoraOperacao` | Registrar momento da alteracao. | Recomenda-se avaliar `SYSDATETIME()` na implementacao. |
| `UsuarioSQL` | Registrar login SQL associado a operacao. | Pode usar `SUSER_SNAME()` ou funcao equivalente. |
| `HostName` | Registrar maquina de origem. | Pode usar `HOST_NAME()`. |
| `Aplicacao` | Registrar aplicacao cliente. | Pode usar `APP_NAME()`, geralmente exibindo SSMS no contexto atual. |
| `ValoresAnteriores` | Guardar snapshot antes da alteracao. | Avaliar formato JSON textual para preservar estrutura sem criar colunas demais. |
| `ValoresNovos` | Guardar snapshot depois da alteracao. | Em `DELETE`, pode ser `NULL`; em `INSERT`, `ValoresAnteriores` pode ser `NULL`. |
| `Observacao` | Registrar contexto ou limitacao tecnica. | Campo opcional para mensagens da trigger ou comentario futuro. |

## 12. Estrategia tecnica sugerida

Para a v1.3.0, a estrategia mais adequada e uma tabela unica de auditoria generica, por exemplo:

```text
dbo.Tbl_AuditoriaAlteracoes
```

Essa abordagem e recomendada porque:

- mantem a fase enxuta;
- permite auditar mais de uma tabela com estrutura comum;
- facilita evidencias no SSMS;
- evita criar uma tabela de historico para cada entidade;
- demonstra criterio tecnico sem inflar o modelo.

Trade-off: uma tabela unica e menos tipada e menos relacional que tabelas especificas por entidade. Ainda assim, para o escopo didatico e de portfolio, ela oferece bom equilibrio entre clareza, rastreabilidade e manutencao.

Os campos `ValoresAnteriores` e `ValoresNovos` devem ser avaliados em formato JSON textual ou outro formato estruturado suportado pelo SQL Server. O importante e evitar concatenacoes confusas e manter um padrao legivel.

## 13. Uso futuro de triggers

Triggers podem ser usadas futuramente para capturar alteracoes DML nas tabelas auditadas.

Papel esperado das triggers:

- ler os pseudo-registros `inserted` e `deleted`;
- identificar operacao realizada;
- registrar metadados da sessao;
- gravar snapshots antes e depois na tabela de auditoria;
- manter a operacao original e o registro de auditoria na mesma transacao.

Triggers devem ser criadas apenas para as tabelas aprovadas no escopo da fase. Nao devem recalcular conformidade, alterar regras de negocio ou executar logica analitica.

## 14. Riscos e cuidados com triggers

Riscos principais:

- aumento de custo em operacoes de escrita;
- dificuldade de depuracao;
- risco de erro na trigger bloquear a operacao original;
- crescimento rapido da tabela de auditoria;
- captura excessiva de dados sem valor pratico;
- acoplamento invisivel entre alteracao de dados e logica de auditoria;
- comportamento mais complexo em operacoes com multiplas linhas.

Cuidados recomendados:

- considerar operacoes multi-linha desde o inicio;
- manter triggers curtas e especificas;
- evitar cursores;
- evitar regras analiticas dentro da trigger;
- documentar claramente os eventos auditados;
- validar cenario de `UPDATE` e `DELETE` no SSMS;
- nao usar auditoria como substituta de backup.

## 15. Validacao no SSMS

A implementacao futura deve ser validada manualmente no SQL Server Management Studio.

Validacoes sugeridas:

- confirmar criacao da tabela de auditoria;
- confirmar criacao das triggers aprovadas;
- executar `UPDATE` controlado em registro de teste ou registro didatico reversivel;
- executar `DELETE` apenas em cenario seguro e planejado, respeitando FKs;
- avaliar `INSERT` somente se esse evento entrar no escopo final;
- consultar `dbo.Tbl_AuditoriaAlteracoes`;
- verificar `NomeTabela`, `IdRegistroAfetado`, `Operacao`, `DataHoraOperacao`, `UsuarioSQL`, `HostName`, `Aplicacao`, `ValoresAnteriores` e `ValoresNovos`;
- confirmar que os indicadores principais continuam coerentes apos os testes ou que as alteracoes de teste foram revertidas de forma controlada.

## 16. Estrategia de evidencias visuais

As evidencias visuais da v1.3.0 devem registrar:

- tabela de auditoria criada;
- triggers criadas;
- evento de `UPDATE` auditado em `Tbl_ResultadosAnalise`;
- evento de `UPDATE` auditado em `Tbl_LimitesReferencia`;
- evento de `UPDATE` auditado em `Tbl_Amostras`;
- consulta da tabela de auditoria exibindo metadados da operacao;
- exemplo de valores anteriores e novos;
- validacao final dos indicadores principais, quando aplicavel.

Os prints devem seguir a numeracao ja usada em `docs/evidencias/`, iniciando apos as evidencias da v1.2.0.

## 17. Limitacoes atuais

Limitacoes relevantes:

- nao existe usuario de aplicacao;
- `UsuarioSQL`, `HostName` e `Aplicacao` refletem o contexto da conexao SQL/SSMS;
- os dados sao didaticos;
- os limites nao representam norma real;
- nao ha fluxo operacional de manutencao com aprovacao;
- nao ha historico de status da amostra;
- nao ha vigencia temporal de limites;
- auditoria planejada nao cobre leitura de dados (`SELECT`);
- auditoria nao substitui backup, restore ou controle de acesso.

## 18. Entregas previstas para v1.3.0

Entregas previstas:

- documento de planejamento `docs/auditoria_historico.md`;
- script futuro `sql/migrations/YYYY-MM-DD_v1.3.0_auditoria_historico.sql`;
- criacao de uma tabela unica de auditoria, se mantida a estrategia recomendada;
- triggers somente para tabelas aprovadas;
- validacoes controladas no SSMS;
- evidencias visuais em `docs/evidencias/`;
- atualizacao futura de `README.md`, `CHANGELOG.md` e documentos relacionados apos implementacao e validacao.

Nesta etapa, somente o documento de planejamento e criado.

## 19. Resumo final

A v1.3.0 deve adicionar rastreabilidade sem auditar o banco inteiro.

O escopo inicial recomendado e auditar:

- `Tbl_ResultadosAnalise`;
- `Tbl_LimitesReferencia`;
- `Tbl_Amostras`.

O foco deve estar em `UPDATE` e `DELETE`, avaliando `INSERT` com cautela para evitar ruido durante cargas didaticas.

A estrategia mais adequada para a primeira implementacao e uma tabela unica de auditoria, com metadados da operacao e snapshots de valores anteriores e novos. Triggers podem ser usadas futuramente, desde que sejam simples, documentadas, preparadas para operacoes multi-linha e restritas ao registro de auditoria.

Com esse recorte, a fase `v1.3.0` acrescenta valor tecnico real ao projeto: rastreabilidade das alteracoes que podem afetar conformidade, indicadores e interpretacao dos dados, sem criar auditoria artificial em todas as tabelas.
