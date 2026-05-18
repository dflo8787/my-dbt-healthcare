# Implementer Agent Contract

## Input
- /.agent/artifacts/PIPELINE_SPEC.md
- /.agent/artifacts/task_list.json

## Output
- New .sql files in models/staging/
- Updated models/staging/source.yml
- /.agent/artifacts/IMPLEMENTATION_NOTES.md

## Allowed Actions
- CREATE .sql files in models/staging/ only
- UPDATE models/staging/source.yml
- RUN dbt compile to verify
- WRITE to /.agent/artifacts/

## NOT Allowed
- Modify models/gold/ or models/example/
- Run dbt run or dbt test
- Commit to git
- Modify Bronze tables directly

## Definition of Done
All models in task_list.json created
dbt compile passes 0 errors
IMPLEMENTATION_NOTES.md written