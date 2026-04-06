# Pipeline Factory Gate Policy

Before git-workflow-agent opens a PR ALL of the following must be true:

## Hard Gates (pipeline stops if any fail)
- [ ] PIPELINE_SPEC.md exists in /.agent/artifacts/
- [ ] IMPLEMENTATION_NOTES.md exists in /.agent/artifacts/
- [ ] TEST_REPORT.md exists and shows STATUS: PASS
- [ ] dbt compile returns 0 errors
- [ ] dbt test returns 0 failures
- [ ] No disallowed patterns (DROP, DELETE, TRUNCATE) in any .sql file
- [ ] All acceptance criteria from PIPELINE_SPEC.md verified

## Soft Gates (warnings only, PR can still proceed)
- [ ] All models have descriptions in source.yml
- [ ] Row counts in Bronze > 0 for all new tables
- [ ] No model runs longer than 60 seconds

## If Any Hard Gate Fails
- Pipeline STOPS immediately
- Write failure reason to /.agent/artifacts/GATE_FAILURE.md
- Write to logs/execution_log.md STATUS: BLOCKED
- Do NOT open PR
- Do NOT commit model files