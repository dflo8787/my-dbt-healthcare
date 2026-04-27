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
Type in Claude Code terminal:
Use the data-quality-scanner agent to profile all Bronze tables and generate a quality report

Output: .agent/artifacts/BRONZE_QUALITY_REPORT.md

## Workflow 3: Query Pipeline History
Type in Claude Code terminal:
Use the pipeline-memory-agent to answer: [your question in plain English]

## Workflow 4: Diagnose a Failure
Type in Claude Code terminal:
Use the root-cause-tracer agent to diagnose the most recent failure and generate a fix plan

Output: .agent/artifacts/ROOT_CAUSE_REPORT.md

## Workflow 5: Weekly Intelligence Report
Type in Claude Code terminal:
Use the pipeline-intelligence-manager agent in MODE B

Output: WEEKLY_PIPELINE_ANALYTICS.md with sentiment analysis

## Workflow 6: Stack Change Check
Type in Claude Code terminal:
Use the web-monitor-agent to check all monitored sources for changes relevant to the healthcare pipeline stack

Output: memory/web-intelligence/[date]-findings.md

## Workflow 7: Write All Artifacts to Databricks
Type in Claude Code terminal:
Use the pipeline-ops-writer agent to read all current artifacts and write to li_ws.intelligence_layer and li_ws.second_brain tables in Databricks

Output: 17 Databricks tables updated

## Workflow 8: Monthly Pipeline Review
Type in Claude Code terminal:
Use the pipeline-reviewer-agent to perform a deep review of all pipeline history and generate the monthly review with strategic recommendations

Output: memory/monthly-reviews/[YYYY-MM]-pipeline-review.md

When to run: Manually on the 1st of every month

## Workflow 9: Manual Notification Test
Type in Claude Code terminal:
Use the notification-agent to read the current DAILY_EXECUTIVE_BRIEF.md and send notification if health is WARNING or CRITICAL

Output: Email via n8n webhook if WARNING or CRITICAL — SKIPPED log entry if HEALTHY