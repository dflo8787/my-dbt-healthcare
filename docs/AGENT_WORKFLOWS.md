# Agent Workflows — End-to-End Guide

## Workflow 1: Full Pipeline Run
Time: ~35-45 minutes | Human actions: 2 PR merges on GitHub

1. Update FEATURE_REQUEST.md with what you want to build
2. In Claude Code terminal type:
   Use the pipeline-orchestrator agent to process FEATURE_REQUEST.md and run the full pipeline factory
3. Phases 1-7 run automatically
4. Merge Silver PR on GitHub
5. Phases 8-9 run automatically
6. Merge Gold PR on GitHub (only if Gold was requested)
7. Phases 10-12 run automatically
8. Check DAILY_EXECUTIVE_BRIEF.md for health summary

## Workflow 2: Bronze Scan Only
Output: .agent/artifacts/BRONZE_QUALITY_REPORT.md

## Workflow 3: Query Pipeline History
## Workflow 4: Diagnose a Failure
Output: .agent/artifacts/ROOT_CAUSE_REPORT.md

## Workflow 5: Weekly Intelligence
## Workflow 6: Stack Change Check
## Workflow 7: Write to Databricks