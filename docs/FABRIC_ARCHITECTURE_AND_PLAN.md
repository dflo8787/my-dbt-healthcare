# Fabric Port — Architecture & Phased Plan

**Project:** `my_healthcare_project_fabric` (dbt-on-Microsoft-Fabric)
**Replicates:** `my_healthcare_project` (dbt-on-Databricks) using the **same source data**
**Status:** Planning — Fabric workspace not yet provisioned
**Author:** Dennis · **Date:** 2026-06-04

---

## 1. Goal

Stand up a faithful, engine-appropriate replication of the existing dbt-on-Databricks
healthcare pipeline on **Microsoft Fabric**, exercising all four Fabric workloads:
Data Engineering, Data Science, Power BI, and Real-Time Analytics.

This is a **port, not a lift-and-shift**: the medallion design, model DAG, tests, and
business logic carry over; the SQL dialect (Spark SQL → T-SQL), auth model (PAT → Entra
Service Principal), and storage layout change.

---

## 2. Locked Decisions (2026-06-04)

| # | Decision | Choice |
|---|----------|--------|
| 1 | dbt compute target | **Hybrid** — Bronze in Lakehouse, Silver/Gold in Warehouse |
| 2 | Workload scope | **All four** — DE, DS, Power BI, Real-Time Analytics |
| 3 | Repo layout | **Brand-new separate repo** named `my_healthcare_project_fabric` |
| 4 | Source data | **Same source data** as the Databricks project |
| 5 | dbt adapter | **Single-adapter** `dbt-fabric` (T-SQL, Warehouse only) |
| 6 | Auth | **Entra Service Principal** (Tenant/Client ID + secret) |

### Key simplification — dbt stays single-adapter
Although storage is hybrid, the **dbt project runs entirely on the Warehouse** with
`dbt-fabric`. It reads the Lakehouse Bronze tables as **dbt sources** via Fabric
cross-database three-part naming (`lakehouse.dbo.table`). Bronze ingestion is done with
**notebooks / Data pipelines**, not dbt. This avoids a messy `dbt-fabric` +
`dbt-fabricspark` two-adapter project.

---

## 3. Target Architecture

```
                       ┌──────────────────── Fabric Workspace ─────────────────────┐
  Source data ─ingest─▶│  LAKEHOUSE  (Bronze, Delta)                                │
  (same as DBX,        │      │                                                     │
   via notebooks/      │      │  dbt sources (cross-DB 3-part name)                 │
   pipelines/          │      ▼                                                     │
   Eventstream)        │  WAREHOUSE ── dbt-fabric ──▶ Silver ──▶ Gold ─────────────┼─▶ Power BI
                       │      ▲                                                     │   (Direct Lake)
  Real-time feeds ─────│  EVENTHOUSE (KQL) ──▶ RTA dashboards                       │
                       │                                                            │
                       │  NOTEBOOKS + MLflow (Data Science) ── read Silver/Gold     │
                       └────────────────────────────────────────────────────────────┘
```

### Layer responsibilities

| Layer | Stored in | Built by | Dialect |
|-------|-----------|----------|---------|
| Bronze (raw) | Lakehouse | Notebooks / Data pipelines | Spark / PySpark |
| Silver (clean, conformed, PII-masked) | Warehouse | **dbt** | T-SQL |
| Gold (marts, risk summaries) | Warehouse | **dbt** | T-SQL |
| Semantic / reporting | Power BI | Direct Lake on Gold | DAX |

### Workload mapping

| Workload | Fabric item(s) | Tooling | In dbt? |
|----------|----------------|---------|---------|
| Data Engineering | Lakehouse + Warehouse + Data pipeline | dbt-fabric + notebooks | Silver/Gold only |
| Data Science | Notebooks + ML experiments | Python/Spark + MLflow | No (consumes Gold) |
| Power BI | Semantic model + report | Direct Lake | No (consumes Gold) |
| Real-Time Analytics | Eventstream + Eventhouse | KQL | No (parallel path) |

---

## 4. What Carries Over vs. What's New

| Carries over (reuse) | Net-new / rewrite |
|----------------------|-------------------|
| Medallion design & model DAG | `profiles.yml` (Fabric SPN target) |
| `sources.yml` *logical* definitions | Source *physical* location → Lakehouse |
| `schema.yml` tests & naming conventions | Spark SQL → **T-SQL** translation of model bodies |
| Business logic / transformations (intent) | `mask_pii()` → T-SQL macro **or** native Dynamic Data Masking |
| Documentation & governance structure | Bronze ingestion (notebooks/pipelines) |
| Pipeline-orchestrator agent framework (adaptable) | Incremental strategies (Fabric Warehouse semantics) |

### Dialect translation watch-list (Spark SQL → T-SQL)
- `QUALIFY` → subquery + `ROW_NUMBER()` filter
- Date/time functions (`date_add`, `to_date`, `current_timestamp`) → T-SQL equivalents
- String functions (`split`, `concat_ws`, regex) → `STRING_SPLIT`, `CONCAT_WS`, etc.
- `MERGE` semantics + incremental materialization differ on Fabric Warehouse
- No enforced PRIMARY KEYS; identity columns limited — review surrogate-key strategy
- PII/PHI masking: prefer **native Dynamic Data Masking + column-level security** (better HIPAA fit) over the macro

---

## 5. Prerequisites — Provisioning Checklist

> **You are here.** Complete this before scaffolding begins.

- [ ] Fabric **capacity** (Trial F-SKU is fine to start) attached to a workspace
- [ ] Fabric **workspace** created
- [ ] **Lakehouse** created (Bronze + staging)
- [ ] **Warehouse** created (Silver/Gold)
- [ ] **Service Principal** (Entra app registration): record **Tenant ID**, **Client ID**, **Client Secret**
- [ ] SPN granted a **workspace role** (Member or Contributor)
- [ ] Tenant admin setting **"Service principals can use Fabric APIs"** enabled
- [ ] Warehouse **SQL connection string / endpoint** captured (for `profiles.yml`)
- [ ] (RTA) **Eventhouse** + **Eventstream** created
- [ ] Decide how the **same source data** lands in Bronze (reuse existing extract, or new Fabric ingestion)

---

## 6. Phased Plan

Sequenced as a **vertical slice first**, then fan out. "All four in parallel" is best read
as *parallel teams after the slice exists* — DS, Power BI, and RTA all consume the Gold
contract, so racing them ahead of a stable Silver/Gold creates rework.

### Phase 0 — Provision (no code)
- Complete §5 checklist. **Exit:** workspace + Lakehouse + Warehouse + SPN ready; dbt can connect.

### Phase 1 — Repo scaffold
- New repo `my_healthcare_project_fabric`: `dbt_project.yml`, `profiles.yml` (SPN target),
  `packages.yml`, `models/{staging,silver,gold}/`, `sources.yml` → Lakehouse, `macros/`,
  `README`, `ARCHITECTURE.md`.
- **Exit:** `dbt debug` connects to the Warehouse; empty project compiles.

### Phase 2 — Bronze ingestion (one source)
- Land **one** source entity into the Lakehouse via notebook/pipeline. Same source data as DBX.
- **Exit:** Bronze Delta table queryable from the Warehouse via 3-part name.

### Phase 3 — Vertical slice (DE)
- Port **one** Silver + **one** Gold model to T-SQL; wire PII masking; add `schema.yml` tests.
- **Exit:** `dbt build` green end-to-end on one table; row counts reconcile with DBX.

### Phase 4 — Power BI Direct Lake
- Build a Direct Lake semantic model + one report on the Gold table.
- **Exit:** report renders live from Gold with no import refresh.

### Phase 5 — Fan out DE
- Port remaining Silver/Gold models (the full ~10). Validate tests + reconciliation.
- **Exit:** full medallion parity with the Databricks project.

### Phase 6 — Data Science (parallel)
- Notebook(s) reading Silver/Gold; MLflow experiment; one model registered.
- **Exit:** reproducible notebook + tracked experiment against Gold.

### Phase 7 — Real-Time Analytics (parallel)
- Eventstream → Eventhouse; KQL queryset; real-time dashboard. Optionally feed Bronze.
- **Exit:** live KQL dashboard on a streaming source.

### Phase 8 — Hardening
- CI (dbt build on PR), docs (`dbt docs`), governance docs ported, cost/capacity review.
- **Exit:** repeatable, documented, reviewed pipeline.

---

## 7. Risks & Open Questions

| Risk / question | Notes |
|-----------------|-------|
| T-SQL translation effort underestimated | Largest single cost; mitigated by vertical-slice-first |
| Fabric Warehouse incremental/MERGE limits | Validate surrogate-key + incremental strategy early (Phase 3) |
| `dbt-fabric` feature maturity | Confirm macro/materialization coverage before fan-out |
| Same source data — reuse extract or re-ingest? | Decide in Phase 0; affects Bronze ingestion design |
| Capacity cost (F-SKU) with 4 workloads | Monitor; Trial first, size before production |
| Native DDM vs `mask_pii()` macro | Pick one in Phase 1; native is the better HIPAA fit |

---

## 8. Next Action

Provision per §5. Once `dbt debug` can reach the Warehouse, begin **Phase 1** scaffold of
`my_healthcare_project_fabric`.

_Memory: see `memory/project-fabric-port.md` for the persisted decision record._
