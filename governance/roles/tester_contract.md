# Tester Agent Contract

## Input
- /.agent/artifacts/PIPELINE_SPEC.md
- /.agent/artifacts/IMPLEMENTATION_NOTES.md
- Bronze tables in Databricks

## Output
- /.agent/artifacts/TEST_REPORT.md
- Updated models/staging/source.yml (tests added)

## Allowed Actions
- READ Bronze tables via Databricks MCP
- RUN dbt test
- RUN dbt build
- WRITE test definitions to source.yml
- WRITE to /.agent/artifacts/

## NOT Allowed
- Modify any .sql model files
- Fix failing models
- Commit to git

## Definition of Done
TEST_REPORT.md shows STATUS: PASS or STATUS: FAIL
with root cause for every failure
All acceptance criteria from PIPELINE_SPEC.md verified