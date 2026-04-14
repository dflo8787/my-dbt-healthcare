# Pipeline Second Brain -- Memory Index
# Updated automatically by pipeline-intelligence-manager after each run
# Source of truth: individual files in memory/
# DO NOT edit manually -- agents maintain this file

## Memory Structure
memory/pipeline-runs/    -- One .md file per pipeline run (auto-generated)
memory/decisions/        -- Structured decision records (auto-generated)
memory/web-intelligence/ -- External monitoring findings (auto-generated)
memory/weekly-reviews/   -- Weekly analytics snapshots (auto-generated)

## Metadata Schema
Every memory file carries:
- run_date, run_id, overall_health
- p0_count, p1_count, tables_affected
- decisions_made, fixes_applied
- duration_minutes, models_created

## Index (auto-updated by intelligence manager)
| Date | Run ID | Health | P0 | P1 | Models | Duration |
|------|--------|--------|----|----|--------|----------|
| 2026-04-14 | 2026-04-14T12:00:00Z | HEALTHY | 0 | 0 | 7 | 0.45 min |
