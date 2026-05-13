# Roadmap do Dashboard Local

## Visao geral

Este roadmap organiza a camada local de demonstracao do dashboard de qualidade de agua e esgoto em tres partes:

1. Contrato frontend.
2. API local somente leitura.
3. Evolucao operacional futura.

O objetivo nao e transformar o repositorio principal em um produto operacional. O dashboard atual e uma interface local de portfolio para visualizar dados derivados das views oficiais do SQL Server.

A preparacao operacional descrita neste roadmap representa evolucao futura. Ela nao e requisito para o encerramento do projeto principal de portfolio SQL Server.

## Fase 1 - Contrato frontend

Status: consolidada.

Entregas:

- Criar `docs/contrato_frontend.md`.
- Definir `dbo.VW_ConformidadeResultados` como fonte oficial da tabela detalhada.
- Definir colunas obrigatorias para CSV/API.
- Definir classificacoes aceitas pelo frontend.
- Manter fallback via `dados.csv` para demonstracao e apresentacao offline.

Decisao tecnica:

O SQL Server continua sendo a fonte oficial. O CSV continua sendo suportado apenas como modo de contingencia para apresentacao local ou avaliacao sem SQL Server ativo.

## Fase 2 - API local somente leitura

Status: complementar/demonstrativa.

Entregas:

- Criar `scripts/start_dashboard_api.ps1`.
- Servir o dashboard por HTTP local.
- Expor endpoint `/api/resultados` baseado em `dbo.VW_ConformidadeResultados`.
- Expor endpoints auxiliares `/api/health`, `/api/kpis`, `/api/parametros` e `/api/pontos`.
- Adaptar o HTML para tentar a API antes de usar `dados.csv`.
- Exibir aviso quando a tela estiver usando API, CSV ou dados de demonstracao.

Comando de execucao recomendado:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\start_dashboard_api.ps1 -ServerInstance ".\SQLEXPRESS" -Database "QualidadeAmbiental"
```

Depois, acessar:

```text
http://127.0.0.1:5500/dashboard_qualidade_ambiental.html
```

Dependencia:

- O script usa `Invoke-Sqlcmd`.
- Caso o comando nao esteja disponivel, instalar o modulo `SqlServer` no PowerShell ou executar em ambiente com ferramentas do SQL Server.

Observacao:

A API PowerShell e local, experimental e somente leitura. Ela nao representa API corporativa, nao implementa autenticacao, nao implementa deploy e nao deve ser vendida como producao.

## Fase 3 - Evolucao operacional futura

Status: fora do escopo de encerramento do projeto principal.

Os pontos abaixo sao recomendacoes para projetos derivados, caso o mesmo banco seja reutilizado em uma aplicacao futura. Eles nao sao requisitos para considerar o projeto `QualidadeAmbiental_SQLServer` concluido como portfolio tecnico SQL Server.

### Banco de dados

- Criar usuario SQL Server somente leitura para o frontend.
- Conceder permissao apenas nas views/procedures necessarias.
- Revisar indices para filtros frequentes:
  - `Tbl_Amostras.DataColeta`
  - `Tbl_Amostras.IdPontoColeta`
  - `Tbl_Amostras.IdTipoAmostra`
  - `Tbl_ResultadosAnalise.IdParametro`
  - `Tbl_ResultadosAnalise.IdAmostra`
- Avaliar views/materializacoes auxiliares se o volume crescer.
- Manter resultados sem limite de referencia visiveis nos relatorios.

### API

- Substituir a API PowerShell por uma API dedicada caso o projeto evolua para producao.
- Stack sugerida para Windows/SQL Server: .NET Minimal API ou Node.js com driver SQL Server.
- Implementar consultas parametrizadas reais.
- Implementar paginacao server-side em todos os endpoints tabulares.
- Registrar logs de erro, tempo de resposta e quantidade de linhas retornadas.
- Definir limites de `pageSize` e timeouts de consulta.
- Configurar CORS apenas para origens autorizadas.

### Frontend

- Adicionar filtros por periodo, tipo de amostra e municipio.
- Adicionar paginacao visual integrada ao endpoint.
- Separar assets e codigo JS em estrutura de aplicacao se a complexidade crescer.
- Adicionar estados de erro por grafico e por tabela.
- Exibir discretamente que os limites sao didaticos, nao normativos.
- Adicionar testes manuais documentados para:
  - API indisponivel.
  - CSV ausente.
  - CSV com colunas incompletas.
  - resultados nao conformes.
  - resultados sem limite.

### Seguranca

- Nunca expor string de conexao no HTML.
- Nunca permitir SQL livre vindo do navegador.
- Usar conta de servico com menor privilegio.
- Proteger endpoint se a aplicacao sair do ambiente local.
- Registrar acessos a endpoints sensiveis.

## Criterio de pronto

O dashboard local pode ser tratado como camada demonstrativa concluida quando:

- A API carregar dados diretamente das views oficiais.
- O fallback CSV estiver documentado como recurso didatico, nao como fonte oficial.
- O dashboard indicar quando esta usando API, CSV ou dados de demonstracao.
- A documentacao deixar claro que producao, autenticacao, deploy, Power BI e API dedicada ficam fora do escopo atual.
- O contrato frontend estiver alinhado ao contrato de dados principal.

## Projetos derivados recomendados

Para evitar crescimento indefinido do repositorio principal, evolucoes maiores devem ser separadas:

| Projeto derivado | Finalidade |
| --- | --- |
| `QualidadeAmbiental_API` | API dedicada com stack propria e seguranca adequada. |
| `QualidadeAmbiental_PowerBI` | Relatorios, modelo semantico e medidas. |
| `QualidadeAmbiental_Dashboard` | Frontend web completo consumindo uma API dedicada. |
