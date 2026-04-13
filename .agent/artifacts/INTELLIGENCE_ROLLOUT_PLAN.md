# Pipeline Intelligence Manager — Rollout Plan

## Phase 1 — Manual Trigger + Read Only (Days 1-3)
Action: Run intelligence manager manually after each pipeline run
Command: "Use the pipeline-intelligence-manager agent in MODE A"
Validate: Is DAILY_EXECUTIVE_BRIEF.md accurate?
          Are P0/P1 events truly urgent?
          Are P2/P3 events correctly low-priority?
Do NOT: Enable n8n scheduling yet
Do NOT: Enable analytics CSV logging yet

## Phase 2 — Analytics Logging Enabled (Days 4-5)
Action: Enable PIPELINE_ANALYTICS_LOG.csv appending
Run 3+ pipeline runs to build baseline data
Validate: CSV is populating correctly with all fields
Do NOT: Generate weekly report yet (insufficient data)
Do NOT: Activate n8n triggers yet

## Phase 3 — Full Automation (Days 6-7)
Action: Activate n8n "Healthcare Pipeline Daily Trigger" workflow
Action: Activate n8n "Healthcare Pipeline Weekly Analytics" workflow
Validate: Does the 4am run fire and complete unattended?
          Does the PR notification arrive on your phone?
          Does the Friday weekly report generate correctly?
Milestone: Fully autonomous pipeline with daily intelligence briefing

## Track During Rollout
- Misclassification rate (P0 flagged that should be P2)
- Brief accuracy (does it reflect what actually happened?)
- Suggested action quality (relevant and safe?)
- Analytics CSV integrity (no missing rows, correct values)
- n8n trigger reliability (does it fire on schedule?)