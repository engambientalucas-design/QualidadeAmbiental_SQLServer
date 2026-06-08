<div align="center">

<br/>

```
╔═══════════════════════════════════════════════════════════════╗
║          Q U A L I D A D E   A M B I E N T A L               ║
║                    SQL Server · v2.1.0                        ║
╚═══════════════════════════════════════════════════════════════╝
```

**Relational database for environmental quality monitoring — water and wastewater.**  
Structured for analytical consumption, audit traceability, and external data contracts.

<br/>

[![SQL Server](https://img.shields.io/badge/SQL%20Server-CC2927?style=flat-square&logo=microsoftsqlserver&logoColor=white)](https://www.microsoft.com/sql-server)
[![T-SQL](https://img.shields.io/badge/T--SQL-0078D4?style=flat-square&logo=microsoft&logoColor=white)](#)
[![Version](https://img.shields.io/badge/version-v2.1.0-0A7ECC?style=flat-square)](#roadmap)
[![Status](https://img.shields.io/badge/status-portfolio%20complete-1A8C4E?style=flat-square)](#status)
[![License](https://img.shields.io/badge/license-MIT-6B7280?style=flat-square)](#)

</div>

---

## Overview

**QualidadeAmbiental\_SQLServer** is a relational database project built on SQL Server, applied to environmental engineering — specifically the monitoring of water and wastewater quality.

The project organizes collection points, analytical samples, environmental parameters, laboratory results, reference limits, and analytical reporting. Beyond functional coverage, it was designed as a **technical portfolio artifact**: demonstrating relational modeling depth, T-SQL fluency, layered documentation, version-controlled migrations, and production-grade practices such as audit triggers, staging pipelines, stored procedures, and formal data contracts.

> The reference limits used throughout the project are **didactic** in nature and do not constitute regulatory or legal thresholds without specific technical and normative validation.

---

## Table of Contents

- [Architecture](#architecture)
- [Data Model](#data-model)
- [Repository Structure](#repository-structure)
- [Execution Order](#execution-order)
- [Analytical Layer](#analytical-layer)
- [Stored Procedures](#stored-procedures)
- [Audit & Traceability](#audit--traceability)
- [Backup & Restore](#backup--restore)
- [Staging Import Pipeline](#staging-import-pipeline)
- [Data Contract](#data-contract)
- [Validation Indicators](#validation-indicators)
- [Roadmap](#roadmap)
- [Git History](#git-history)
- [Continuing the Project](#continuing-the-project)
- [Note on AI Usage](#note-on-ai-usage)

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                     QualidadeAmbiental · System Layers              │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   ┌──────────────────────────────────────────────────────────────┐  │
│   │  CONSUMPTION LAYER                                           │  │
│   │  dashboard_qualidade_ambiental.html  ·  PowerShell API       │  │
│   └──────────────────────────────┬───────────────────────────────┘  │
│                                  │ read-only / data contract        │
│   ┌──────────────────────────────▼───────────────────────────────┐  │
│   │  ANALYTICAL LAYER                                            │  │
│   │  VW_ConformidadeResultados  ·  VW_RankingParametrosCriticos  │  │
│   │  VW_ResultadosForaDoPadrao  ·  VW_ConformidadeMensal         │  │
│   │  VW_EficienciaRemocaoETE    ·  VW_ResultadosSemLimite        │  │
│   └──────────────────────────────┬───────────────────────────────┘  │
│                                  │                                  │
│   ┌──────────────────────────────▼───────────────────────────────┐  │
│   │  STORED PROCEDURES                                           │  │
│   │  usp_ConformidadePorPeriodo  ·  usp_ResultadosForaPadrao     │  │
│   │  usp_RankingParametrosCriticos                               │  │
│   └──────────────────────────────┬───────────────────────────────┘  │
│                                  │                                  │
│   ┌──────────────────────────────▼───────────────────────────────┐  │
│   │  CORE TABLES                                                 │  │
│   │  Tbl_Amostras  ·  Tbl_ResultadosAnalise                      │  │
│   │  Tbl_LimitesReferencia  ·  Tbl_PontosColeta                  │  │
│   │  Tbl_Parametros  ·  Tbl_TiposAmostra                         │  │
│   │  Tbl_Responsaveis  ·  Tbl_StatusAmostra                      │  │
│   └──────────────────────────────┬───────────────────────────────┘  │
│                                  │                                  │
│   ┌──────────────────────────────▼───────────────────────────────┐  │
│   │  OPERATIONAL INFRASTRUCTURE                                  │  │
│   │  Audit Triggers  ·  Performance Indexes  ·  Staging Pipeline │  │
│   │  Backup/Restore  ·  Import Lot Control                       │  │
│   └──────────────────────────────────────────────────────────────┘  │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Data Model

### Entity-Relationship Overview

```
  Tbl_Responsaveis          Tbl_StatusAmostra        Tbl_TiposAmostra
  ┌────────────────┐         ┌───────────────┐        ┌──────────────┐
  │ IdResponsavel  │         │ IdStatus      │        │ IdTipoAmostra│
  │ NomeResponsavel│         │ DescricaoStatus│       │ Descricao    │
  └───────┬────────┘         └───────┬───────┘        └──────┬───────┘
          │                          │                        │
          │           ┌──────────────▼────────────────────────▼──────┐
          └──────────►│              Tbl_Amostras                     │
                      │  IdAmostra · CodigoAmostra · DataColeta       │
                      │  IdPontoColeta · IdTipoAmostra                │
                      │  IdResponsavel · IdStatus                     │
                      └──────────────┬────────────────────────────────┘
                                     │
          ┌──────────────────────────▼──────────────────────────────┐
          │                 Tbl_ResultadosAnalise                    │
          │  IdResultado · IdAmostra · IdParametro · ValorResultado  │
          └──────────────────────────┬──────────────────────────────┘
                                     │
                 ┌───────────────────┼───────────────────────┐
                 │                   │                        │
  ┌──────────────▼──────┐   ┌────────▼──────────┐   ┌────────▼─────────────┐
  │   Tbl_Parametros    │   │ Tbl_LimitesRef... │   │  Tbl_PontosColeta    │
  │ IdParametro         │   │ IdLimite          │   │ IdPontoColeta        │
  │ NomeParametro       │   │ IdParametro       │   │ NomePonto · TipoPonto│
  │ UnidadeMedida       │   │ IdTipoAmostra     │   │ Municipio · Estado   │
  │ Categoria           │   │ ValorMinimo       │   │ Latitude · Longitude │
  └─────────────────────┘   │ ValorMaximo       │   └──────────────────────┘
                             └───────────────────┘
```

### Tables

| Table | Purpose | Key Relations |
|---|---|---|
| `Tbl_Responsaveis` | Technical analysts and field collectors | Referenced by `Tbl_Amostras` |
| `Tbl_StatusAmostra` | Sample lifecycle states | Referenced by `Tbl_Amostras` |
| `Tbl_TiposAmostra` | Sample types (raw water, treated water, wastewater…) | Referenced by `Tbl_Amostras`, `Tbl_LimitesReferencia` |
| `Tbl_PontosColeta` | Collection points with geographic coordinates | Referenced by `Tbl_Amostras` |
| `Tbl_Parametros` | Environmental parameters (pH, BOD, turbidity…) | Referenced by `Tbl_ResultadosAnalise`, `Tbl_LimitesReferencia` |
| `Tbl_Amostras` | Collected samples — central operational entity | References 4 lookup tables |
| `Tbl_ResultadosAnalise` | Laboratory results per parameter per sample | References `Tbl_Amostras`, `Tbl_Parametros` |
| `Tbl_LimitesReferencia` | Didactic reference limits by parameter and sample type | References `Tbl_Parametros`, `Tbl_TiposAmostra` |

> **Design decision:** Primary keys do not use `IDENTITY`. Explicit IDs preserve the deterministic, didactic dataset and ensure reproducible validation across environments.

---

## Repository Structure

```
QualidadeAmbiental_SQLServer/
│
├── docs/
│   ├── evidencias/                        # SSMS validation screenshots
│   ├── dicionario_dados.md                # Column-level data dictionary
│   ├── evidencias_validacao.md            # Validation results and evidence log
│   ├── modelo_dados.md                    # Data model, tables, relationships
│   ├── performance_indices.md             # v1.1.0 — indexes and execution plans
│   ├── regras_negocio.md                  # Business rules and conformance logic
│   ├── auditoria_historico.md             # v1.3.0 — audit strategy and triggers
│   ├── backup_restore.md                  # v1.4.0 — backup/restore procedures
│   ├── contrato_dados.md                  # v2.1.0 — external data contract
│   ├── contrato_frontend.md               # SQL Server ↔ local API ↔ dashboard contract
│   ├── frontend_roadmap.md                # Dashboard scope and derived projects
│   ├── importacao_staging.md              # v2.0.0 — staging import pipeline
│   ├── stored_procedures.md               # v1.2.0 — analytical procedures
│   └── relatorios.md                      # Views, indicators, portfolio guidance
│
├── scripts/
│   └── start_dashboard_api.ps1            # Local read-only PowerShell API
│
├── sql/
│   ├── migrations/
│   │   ├── 2026-05-11_v1.1.0_indices_performance.sql
│   │   ├── 2026-05-12_v1.2.0_stored_procedures.sql
│   │   ├── 2026-05-12_v1.3.0_auditoria_historico.sql
│   │   ├── 2026-05-12_v1.4.0_backup_restore_validacao.sql
│   │   └── 2026-05-13_v2.0.0_importacao_staging.sql
│   │
│   ├── 01_create_database.sql             # Database creation (idempotent)
│   ├── 02_create_tables.sql               # Schema: tables, PKs, FKs, constraints
│   ├── 03_insert_cadastros.sql            # Reference data inserts
│   ├── 04_insert_amostras_resultados.sql  # Sample and result inserts
│   ├── 05_views_oficiais.sql              # Official analytical views
│   └── 06_consultas_analiticas.sql        # Validation queries and final checklist
│
├── dashboard_qualidade_ambiental.html     # Local SPA dashboard (Tailwind + Chart.js)
├── CHANGELOG.md
└── README.md
```

---

## Execution Order

Scripts must be executed in SQL Server Management Studio in the following sequence:

```
 Step   Script                                          Purpose
──────  ──────────────────────────────────────────────  ──────────────────────────────────────
  01    sql/01_create_database.sql                      Creates database if not exists
  02    sql/02_create_tables.sql                        Schema: tables, PKs, FKs, constraints
  03    sql/03_insert_cadastros.sql                     Reference data (4 types, 47 limits…)
  04    sql/04_insert_amostras_resultados.sql           6 samples · 72 analytical results
  05    sql/05_views_oficiais.sql                       Official analytical views (6 views)
  06    sql/06_consultas_analiticas.sql                 Validation checklist → expect all OK
──────  ──────────────────────────────────────────────  ──────────────────────────────────────
 M-01   migrations/v1.1.0_indices_performance.sql       Non-clustered performance indexes
 M-02   migrations/v1.2.0_stored_procedures.sql         Analytical stored procedures
 M-03   migrations/v1.3.0_auditoria_historico.sql       Audit table + DML triggers
 M-04   migrations/v1.4.0_backup_restore_validacao.sql  Backup, verify, restore to test DB
 M-05   migrations/v2.0.0_importacao_staging.sql        Staging pipeline (run on test DB)
──────  ──────────────────────────────────────────────  ──────────────────────────────────────
```

> Migration M-05 (`v2.0.0`) must be executed on `QualidadeAmbiental_RestoreTeste` to preserve the main database's state.

---

## Analytical Layer

Six official views compose the analytical reporting layer, defined in `sql/05_views_oficiais.sql`:

| View | Description | Design note |
|---|---|---|
| `VW_ConformidadeResultados` | Classifies all results against reference limits | Uses `LEFT JOIN` to preserve results without a registered limit |
| `VW_ResultadosForaDoPadrao` | Lists results exceeding max or below min | Subset of the conformance view |
| `VW_ConformidadeMensal` | Monthly conformance trend indicators | Supports temporal evolution tracking |
| `VW_RankingParametrosCriticos` | Parameters ranked by non-conformance count and proportion | Input for `usp_RankingParametrosCriticos` |
| `VW_EficienciaRemocaoETE` | Removal efficiency for wastewater treatment | Aggregates by parameter + collection date to prevent row multiplication |
| `VW_ResultadosSemLimiteReferencia` | Results without a reference limit registered | Audit surface for coverage gaps |

**Conformance classification taxonomy:**

```
  ┌─────────────────────────────────────────┐
  │  Result has a reference limit?          │
  │                                         │
  │   YES ──► Value > max?  ──► ABOVE MAX   │
  │           Value < min?  ──► BELOW MIN   │
  │           Otherwise     ──► CONFORMANT  │
  │                                         │
  │   NO  ──────────────────► NO LIMIT REG. │
  └─────────────────────────────────────────┘
```

> Using `INNER JOIN` with `Tbl_LimitesReferencia` would silently drop results without limits — this is a deliberate `LEFT JOIN` design decision.

---

## Stored Procedures

Three parametrized analytical procedures added in `v1.2.0`:

| Procedure | Parameters | Validation |
|---|---|---|
| `dbo.usp_ConformidadePorPeriodo` | `@DataInicio`, `@DataFim`, `@TipoAmostra` (opt.), `@PontoColeta` (opt.) | `THROW` on invalid date range |
| `dbo.usp_ResultadosForaPadrao` | `@DataInicio`, `@DataFim`, `@Parametro` (opt.), `@PontoColeta` (opt.) | — |
| `dbo.usp_RankingParametrosCriticos` | `@TopN`, `@DataInicio` (opt.), `@DataFim` (opt.) | `THROW` if `@TopN ≤ 0` |

All procedures follow: `CREATE OR ALTER PROCEDURE` · explicit `dbo` schema · `usp_` prefix · `SET NOCOUNT ON` · views as single source of conformance truth.

---

## Audit & Traceability

`v1.3.0` introduced a lightweight, targeted audit layer for tables that directly affect conformance indicators and analytical interpretation.

```
  Audited Tables                    Audit Table
  ─────────────────────             ──────────────────────────────────────
  Tbl_ResultadosAnalise    INSERT   dbo.Tbl_AuditoriaAlteracoes
  Tbl_LimitesReferencia    UPDATE   ├── Tabela
  Tbl_Amostras             DELETE   ├── IdRegistro
                                    ├── Operacao
                                    ├── DataHora
                                    ├── UsuarioSQL · HostName · Aplicacao
                                    ├── ValoresAnteriores (snapshot)
                                    └── ValoresNovos (snapshot)
```

**Validated in `v1.3.0`:** 8 `UPDATE` audit events recorded — 2 on results, 4 on limits, 2 on samples. Final indicators remained consistent at `72 / 57 / 15 / 50 / 7`.

---

## Backup & Restore

`v1.4.0` implemented a full operational backup-and-restore cycle:

```
  QualidadeAmbiental (main)
          │
          ├── BACKUP DATABASE → C:\SQLBackups\QualidadeAmbiental\
          │       └── RESTORE VERIFYONLY
          │       └── RESTORE FILELISTONLY
          │
          └── RESTORE DATABASE → QualidadeAmbiental_RestoreTeste
                  └── Validate: 8 tables · 6 views · 3 procedures
                  └── Validate: 3 audit triggers · 2 incremental indexes
                  └── Validate: indicators 72 / 57 / 15 / 50 / 7 ✓
```

> The `.bak` file is a local operational artifact and is **not** tracked in Git.

---

## Staging Import Pipeline

`v2.0.0` introduced a controlled import pipeline for external analytical results targeting existing samples:

```
  External Data Source
          │
          ▼
  Stg_ResultadosAnaliseImportacao   ← raw insert (PENDING status)
          │
          ▼
  usp_ValidarStgResultadosAnalise   ← validates: FK integrity, duplicates, nulls
          │
          ├── VALID records ──────────────────────────────────────────┐
          └── INVALID records → Tbl_LotesImportacao (status: INVALID) │
                                                                       │
                        @ConfirmarCarga = 1 required ◄─────────────── │
                                                                       ▼
                                               usp_CarregarResultadosAnaliseValidados
                                                       │
                                                       ▼
                                               Tbl_ResultadosAnalise (final table)
```

**Safety mechanisms:** load without confirmation is blocked · load with any `INVALID` records is blocked · explicit transaction with `SET XACT_ABORT ON`.

**`v2.0.0` validation result:** 7 didactic staging rows classified as `INVALID`. Zero records loaded to `Tbl_ResultadosAnalise`. Final indicators preserved at `72 / 57 / 15 / 50 / 7`.

---

## Data Contract

`v2.1.0` formalizes the contract for external consumption:

```
  SQL Server (source of truth)
          │
          └── docs/contrato_dados.md        ← fields, types, nullability, semantics
          └── docs/contrato_frontend.md     ← SQL Server ↔ local API ↔ dashboard contract
          └── docs/frontend_roadmap.md      ← scope boundary: what stays, what is a derived project
```

**Derived projects (out of this repository's scope):**

| Project | Description |
|---|---|
| `QualidadeAmbiental_API` | Dedicated REST API (.NET, Node.js, FastAPI, or equivalent) |
| `QualidadeAmbiental_PowerBI` | Semantic layer, DAX measures, executive reports |
| `QualidadeAmbiental_Dashboard` | Full frontend consuming a dedicated API |
| `QualidadeAmbiental_DataOps` | Deployment automation and operational routines |

---

## Validation Indicators

Final state of the main database `QualidadeAmbiental`, consistent across all phases:

| Indicator | Expected | Status |
|---|---|---|
| Total analytical results | 72 | ✓ |
| Results with reference limit | 57 | ✓ |
| Results without reference limit | 15 | ✓ |
| Conformant results (with limit) | 50 | ✓ |
| Non-conformant results (with limit) | 7 | ✓ |

**Reference data (after `03_insert_cadastros.sql`):**

| Entity | Count |
|---|---|
| Technical analysts | 4 |
| Sample statuses | 5 |
| Sample types | 5 |
| Collection points | 6 |
| Environmental parameters | 12 |
| Reference limits | 47 |

These numbers are validated by the checklist query in `sql/06_consultas_analiticas.sql`.

---

## Roadmap

| Version | Focus | Objective |
|---|---|---|
| `v1.0.0` | Initial publication | Relational base, didactic data, views, analytical queries, documentation, evidence |
| `v1.1.0` | Indexes & performance | Non-clustered indexes, technical criteria, trade-offs, execution plan analysis |
| `v1.2.0` | Stored procedures | Parametrized analytical procedures, SSMS-validated, aligned with official views |
| `v1.3.0` | Audit & traceability | Audit table, DML triggers for results, limits, and samples |
| `v1.4.0` | Backup & restore | Full backup, restore to separate DB, post-recovery validation |
| `v2.0.0` | Import pipeline | Staging with lot control, validation, load blocking, evidence |
| `v2.1.0` | Data contract & closure | External consumption contract, local demonstrative layer, controlled repository closure |

---

## Git History

| Tag | Description |
|---|---|
| `v1.0.0` | Initial stable release — published to GitHub |
| `v1.1.0` | Indexes, performance, execution plan evidence |
| `v1.2.0` | Stored procedures, parametrized analytics |
| `v1.3.0` | Audit layer, DML triggers, traceability |
| `v1.4.0` | Backup/restore cycle, cross-environment validation |
| `v2.0.0` | Staging import pipeline, load control, evidence |
| `v2.1.0` | Data contract, frontend contract, portfolio closure |

Commit discipline: small, descriptive commits per concern — documentation, schema changes, migration scripts, and data inserts tracked independently.

---

## Continuing the Project

To reproduce or continue this project in another environment:

1. Clone the repository and review the folder structure in this README.
2. Execute the SQL scripts in the [prescribed order](#execution-order).
3. Run `sql/06_consultas_analiticas.sql` — the final checklist must return all `OK`.
4. Consult `docs/modelo_dados.md` for data model detail.
5. Consult `docs/regras_negocio.md` for conformance rules and business logic.
6. Consult `docs/dicionario_dados.md` for column-level reference.
7. Consult `docs/evidencias_validacao.md` and `docs/evidencias/` for SSMS screenshots.
8. Apply migrations incrementally from `sql/migrations/`.
9. Consult phase-specific documentation for `v1.1.0` through `v2.1.0`.

If the project changes environment or owner, this README is the authoritative reference.

---

## Note on AI Usage

This project was developed with support from AI tools (Codex/Cursor) for organization, script generation, and documentation review.

All technical decisions — reference limits, business rules, conformance logic, data modeling, performance trade-offs — were critically reviewed before final use. AI tools were treated as assistants, not as authoritative sources.

---

## Technologies

[![SQL Server](https://img.shields.io/badge/SQL%20Server-CC2927?style=flat-square&logo=microsoftsqlserver&logoColor=white)](https://www.microsoft.com/sql-server)
[![T-SQL](https://img.shields.io/badge/T--SQL-0078D4?style=flat-square&logo=microsoft&logoColor=white)](#)
[![VS Code](https://img.shields.io/badge/VS%20Code-007ACC?style=flat-square&logo=visualstudiocode&logoColor=white)](https://code.visualstudio.com)
[![PowerShell](https://img.shields.io/badge/PowerShell-5391FE?style=flat-square&logo=powershell&logoColor=white)](https://learn.microsoft.com/powershell)
[![Git](https://img.shields.io/badge/Git-F05032?style=flat-square&logo=git&logoColor=white)](https://git-scm.com)
[![GitHub](https://img.shields.io/badge/GitHub-181717?style=flat-square&logo=github&logoColor=white)](https://github.com)

---

<div align="center">

<br/>

```
QualidadeAmbiental_SQLServer · v2.1.0 · Portfolio Complete
```

</div>
