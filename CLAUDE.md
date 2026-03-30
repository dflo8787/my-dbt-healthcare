# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **dbt (data build tool) project** for healthcare data, connected to a **Databricks SQL Warehouse on Azure** via the `my_healthcare_project` profile. The project is in early/starter stage with example models.

## Common Commands

- `dbt run` — build all models
- `dbt run --select model_name` — build a single model
- `dbt test` — run all tests
- `dbt test --select model_name` — test a single model
- `dbt compile` — compile SQL without executing
- `dbt clean` — remove `target/` and `dbt_packages/`

dbt is installed at `C:\Users\dflof\AppData\Local\Programs\Python\Python312\Scripts\dbt.exe`. An MCP dbt server is also available for running dbt commands via tool calls.

## Architecture

- **Warehouse**: Databricks SQL on Azure (`adb-1958847036822438.18.azuredatabricks.net`)
- **Profile**: `my_healthcare_project` (configured outside this repo in `~/.dbt/profiles.yml`)
- **Models** (`models/`): SQL + Jinja templates. Currently contains `example/` subdirectory with starter models materialized as views (overridable per-model via `{{ config() }}`). `my_first_dbt_model` is materialized as a table; `my_second_dbt_model` refs it downstream.
- **Schema tests** are defined in `schema.yml` files alongside models using `data_tests:` syntax.
- **Seeds** (`seeds/`), **Snapshots** (`snapshots/`), **Macros** (`macros/`), **Analyses** (`analyses/`), **Tests** (`tests/`) — standard dbt directories, currently empty placeholders.

## MCP Integration

A Databricks SQL MCP server is configured in `.mcp.json` for direct SQL execution against the warehouse. The `dbt` MCP server provides tool-based access to dbt commands (build, run, test, compile, show, lineage, etc.).
