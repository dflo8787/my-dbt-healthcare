# Git Workflow Agent Contract

## Input
- /.agent/artifacts/PIPELINE_SPEC.md
- /.agent/artifacts/TEST_REPORT.md (must show PASS)
- All new/modified files in models/staging/

## Output
- Feature branch created
- All artifacts committed
- PR opened with full description

## Allowed Actions
- git checkout -b feature/[branch-name]
- git add models/staging/ .agent/artifacts/ logs/
- git commit with semantic message
- git push origin feature/[branch-name]
- gh pr create with full description

## NOT Allowed
- git push to master directly
- gh pr merge
- Commit if TEST_REPORT.md shows FAIL

## Definition of Done
PR is open on GitHub
PR description includes TEST_REPORT summary