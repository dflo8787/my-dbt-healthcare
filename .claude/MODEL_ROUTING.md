# Model Routing — Healthcare Pipeline
# Last updated: April 2026

## Routing Decision Table
| Agent | Model | Justification |
|-------|-------|---------------|
| pipeline-orchestrator | opus | Multi-phase reasoning, strategy rotation, escalation |
| data-quality-scanner | opus | Fix instruction generation, nuanced quality analysis |
| dbt-modeler | opus | Fix application in SQL, compile failure diagnosis |
| git-workflow-agent | opus | Conflict classification, PR judgment calls |
| dbt-runner | sonnet | Pure execution — runs commands, reads output, reports |
| pipeline-intelligence-manager | opus | Reads all logs, classifies events, generates briefs |

## Routing Rules
- opus: any agent that makes decisions, diagnoses, generates code,
         or writes narratives
- sonnet: any agent that only executes commands and reports results
- haiku: future — simple classification, log parsing, metric extraction

## Cost Optimization
- dbt-runner on sonnet saves ~60% on that agent with zero quality loss
- All other agents reason actively — opus is justified

## Future Routing
When CI/CD promotion agent built → opus (irreversible production writes)
When data catalog agent built    → sonnet (read schema, write tags)
When observability agent built   → haiku (log parsing, metric extraction)