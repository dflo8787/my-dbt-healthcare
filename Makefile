.PHONY: test compile build agent-plan agent-debug agent-write-ops agent-memory status clean

test:
	dbt test --select staging

compile:
	dbt compile

build:
	dbt build --select staging

agent-plan:
	@echo "Open Claude Code and run:"
	@echo "Use the pipeline-orchestrator agent to process FEATURE_REQUEST.md and run the full pipeline factory"

agent-debug:
	@echo "Open Claude Code and run:"
	@echo "Use the root-cause-tracer agent to diagnose the most recent failure and generate a fix plan"

agent-write-ops:
	@echo "Open Claude Code and run:"
	@echo "Use the pipeline-ops-writer agent to read all current artifacts and write to Databricks tables"

agent-memory:
	@echo "Open Claude Code and run:"
	@echo "Use the pipeline-memory-agent to answer: [your question]"

status:
	git status
	git log --oneline -5

clean:
	dbt clean