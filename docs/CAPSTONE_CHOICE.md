# Capstone Choice — my_healthcare_project
**Date:** April 2026 | **Author:** Dennis Flomo | **Course:** Agentic AI Mastery

---

## Variant Selected: AI DevOps Agent (Option 2)
**Adapted for:** Healthcare Data Engineering

---

## Problem

Healthcare organizations generate large volumes of clinical and billing data
across disparate systems. Manual data engineering is slow, error-prone,
and does not scale. Data quality issues in source systems are not caught
until they reach analysts — causing rework, incorrect reports, and
compliance risk.

---

## Target User

- Data engineers at mid-size healthcare organizations
- Analytics teams who need clean, tested data without writing SQL manually
- Leadership teams who need executive-quality reports from raw clinical data
- BOTG Solutions LLC client engagements in healthcare and adjacent industries

---

## What the System Does

A fully autonomous, self-healing healthcare data pipeline with 13 AI agents
across 13 phases. Triggered by FEATURE_REQUEST.md or n8n schedule.

Automation: Phases 1-6, 8, 10-13 fully automated
Human gates: Phase 7 (Silver PR merge) + Phase 9 (Gold PR merge)
Notification: notification-agent emails on WARNING or CRITICAL health
Review: pipeline-reviewer-agent deep-reviews all history monthly

---

## Success Metrics

| Metric | Target | Current |
|---|---|---|
| Pipeline cycle time | Under 45 minutes | ~35 minutes |
| Manual SQL written | 0 lines | 0 lines |
| dbt test pass rate | 100% | 87 tests passing |
| Human actions per run | 2 max | 2 PR merges |
| Cost per run | Under $5 | ~$2.67 |
| Observability tables | 17 queryable | 17 tables live |
| Health dashboard | After every run | Phase 13 generates it |
| Proactive notification | On WARNING/CRITICAL | notification-agent |
| Monthly strategy review | 1st of month | pipeline-reviewer-agent |

---

## Constraints

- Healthcare compliance: Bronze is read-only forever
- Human approval required: Gold data never auto-approves
- Security: Credentials in .env only — rotate every 90 days
- Cost: X-Small Serverless warehouse — ~$2.67 per run
- Vendor independence: Model-agnostic via MODEL_ROUTING.md

---

## Supporting Documents

| Document | Purpose |
|---|---|
| Healthcare_Pipeline_Technical_Reference_v5.pdf | Full technical build guide |
| Healthcare_Pipeline_Enterprise_Blueprint_v2.pdf | Client proposal and ROI |
| Healthcare_Pipeline_Demo_Presentation_Guide_v2.pdf | 13-step demo script |
| Healthcare_Pipeline_Flow_Diagrams.html | Architecture diagrams |
| Healthcare_Pipeline_Health_Dashboard.html | Pipeline health proof |
| Healthcare_Pipeline_Success_Checklist.html | Live run validation |