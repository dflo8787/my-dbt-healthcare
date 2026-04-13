# Pipeline Event Classification Schema
# Output format for pipeline-intelligence-manager agent

## Required JSON Output Per Event

{
  "event_id": "EVT-[YYYYMMDD]-[sequence]",
  "timestamp": "ISO 8601",
  "source_artifact": "filename that triggered this event",
  "priority": "P0 | P1 | P2 | P3",
  "category": "QUALITY_ISSUE | SCHEMA_CHANGE | PIPELINE_FAILURE | PERFORMANCE | GOVERNANCE | SUCCESS | SECURITY",
  "phase": "1-10 or null",
  "agent_responsible": "agent name or null",
  "action_required": true | false,
  "deadline": "ISO 8601 or null",
  "summary": "1-2 sentence plain English description",
  "suggested_action": "specific action to take or null",
  "auto_executable": false,
  "confidence": 0.0-1.0,
  "sensitive": true | false,
  "affected_tables": ["list of Bronze/Silver/Gold tables affected"],
  "vip_table_involved": true | false
}

## Escalation Rule
If sensitive=true OR confidence<0.6 → escalate to human, no auto-labeling.
If priority=P0 OR vip_table_involved=true → always human review.
auto_executable is ALWAYS false — this agent never executes, only suggests.