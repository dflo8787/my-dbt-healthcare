# Planner Agent Contract

## Input
- FEATURE_REQUEST.md
- Current Bronze schema from Databricks
- Existing models in models/staging/

## Output
- /.agent/artifacts/PIPELINE_SPEC.md
- /.agent/artifacts/task_list.json

## Allowed Actions
- READ any file in project
- READ Databricks Bronze schema via MCP
- WRITE only to /.agent/artifacts/

## NOT Allowed
- Create or modify any .sql files
- Run any dbt commands
- Commit to git

## Definition of Done
PIPELINE_SPEC.md exists with all sections complete
task_list.json lists every task in execution order