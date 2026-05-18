# Security Guide — my_healthcare_project

## Credentials — Never Commit

| File | Contains | Status |
|---|---|---|
| .env | Databricks PAT, n8n API key, MCP keys | Gitignored — never commit |
| ~/.dbt/profiles.yml | Databricks host + token | Outside repo — never commit |
| .mcp.json | MCP server URLs + tokens | Gitignored — never commit |

If any of these are accidentally committed:
1. Rotate the token immediately in the issuing service
2. Use git filter-branch or BFG to remove from history
3. Force push the cleaned history

## Least Privilege — Agent Permissions

| Agent | Can Write To | Cannot Touch |
|---|---|---|
| dbt-modeler | models/staging/, models/gold/ | Bronze, CI files, credentials |
| pipeline-ops-writer | li_ws.intelligence_layer, li_ws.second_brain | Bronze, Silver, Gold schemas |
| git-workflow-agent | git commands only | No direct file edits |
| All agents | .agent/artifacts/ | .env, .mcp.json, .github/workflows/ |

## Data Boundaries
- li_ws.bronze is READ ONLY for all agents — forever
- Patient data never appears in logs or Databricks ops tables
- PII columns are never written to intelligence_layer or second_brain

## CI Gate — SQL Policy Scan
Every PR triggers a scan for DROP TABLE, DELETE FROM, TRUNCATE.
Any match blocks the merge automatically.
File: .github/workflows/pipeline-review.yml

## Secrets Rotation Schedule
- Databricks PAT: rotate every 90 days
- n8n API key: rotate every 90 days