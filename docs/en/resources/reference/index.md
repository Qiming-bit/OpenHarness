# English Reference

These notes explain how to use the templates as a working harness instead of a
loose pile of files.

## Internal Reference Notes

- [`method-map.md`](./method-map.md): map common long-running failure modes to
  the artifact or policy that addresses them first
- [`initializer-agent-playbook.md`](./initializer-agent-playbook.md): what the
  initializer should leave behind before feature work starts
- [`coding-agent-startup-flow.md`](./coding-agent-startup-flow.md): fixed
  session-start flow for later coding runs
- [`prompt-calibration.md`](./prompt-calibration.md): how to keep root
  instructions sharp without making them bloated and brittle

## Primary Articles

This list is intentionally narrow. A harness means the execution system around
the model: the agent loop, tool execution, sandboxing, state, context,
verification, termination, orchestration, and observability. General prompt
engineering or broad agent-framework articles do not belong in the primary
list.

The original three articles remain the backbone of the course:

- [OpenAI: Harness engineering: leveraging Codex in an agent-first world](https://openai.com/index/harness-engineering/) (2026-02-11): agent-first repositories, repo-local context, custom linting, and structural guardrails.
- [Anthropic: Effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents) (2025-11-26): initializer agent, coding agent, feature list, progress log, and handoff across context windows.
- [Anthropic: Harness design for long-running application development](https://www.anthropic.com/engineering/harness-design-long-running-apps) (2026-03-24): planner / generator / evaluator roles, context resets, harness simplification, and stale assumptions.

Only a few highly relevant 2026 articles are added:

- [OpenAI: Unrolling the Codex agent loop](https://openai.com/index/unrolling-the-codex-agent-loop/) (2026-01-23): the Codex runtime harness, tool calls, context growth, and loop termination.
- [OpenAI: Unlocking the Codex harness: how we built the App Server](https://openai.com/index/unlocking-the-codex-harness/) (2026-02-04): the harness as a reusable App Server protocol with thread lifecycle, resume, fork, diffs, and client integrations.
- [Anthropic: Demystifying evals for AI agents](https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents) (2026-01-09): evaluating the model and harness together, and distinguishing evaluation harnesses from agent harnesses.
- [Anthropic: Building a C compiler with a team of parallel Claudes](https://www.anthropic.com/engineering/building-c-compiler) (2026-02-05): parallel agent teams, task locks, git synchronization, container isolation, and autonomous loops.
- [Anthropic: Scaling Managed Agents: Decoupling the brain from the hands](https://www.anthropic.com/engineering/managed-agents) (2026-04-08): a meta-harness view that separates session, harness, and sandbox as swappable interfaces.
- [OpenAI: An open-source spec for Codex orchestration: Symphony](https://openai.com/index/open-source-codex-orchestration-symphony/) (2026-04-27): turning an issue tracker or Linear board into a multi-agent control plane.

## 2026 Extended References

These are not core course sources, but they are useful when designing specific
harness modules:

- [OpenAI Developers: Run long horizon tasks with Codex](https://developers.openai.com/blog/run-long-horizon-tasks-with-codex) (2026-02-23): durable project memory, milestone validation, and done-when examples for long-running tasks.
- [OpenAI: The next evolution of the Agents SDK](https://openai.com/index/the-next-evolution-of-the-agents-sdk/) (2026-04-15): model-native harnesses, sandbox execution, and file/command execution.
- [Anthropic: An update on recent Claude Code quality reports](https://www.anthropic.com/engineering/april-23-postmortem) (2026-04-23): reasoning effort, context pruning, and system prompts as harness changes that need regression governance.
- [Microsoft: Agent Harness in Agent Framework](https://devblogs.microsoft.com/agent-framework/agent-harness-in-agent-framework/) (2026-03-12): shell/filesystem harnesses, approval flow, hosted shell execution, and context compaction.
- [Google: Announcing ADK for Java 1.0.0](https://developers.googleblog.com/announcing-adk-for-java-100-building-the-future-of-ai-agents-in-java/) (2026-03-30): plugins, event compaction, HITL, session/memory services, and A2A.
- [GitHub: Automate repository tasks with GitHub Agentic Workflows](https://github.blog/ai-and-ml/automate-repository-tasks-with-github-agentic-workflows/) (2026-02-13): agentic workflows inside GitHub Actions with safe outputs, sandboxing, permissions, and review.
- [AWS: AI agents in enterprises: Best practices with Amazon Bedrock AgentCore](https://aws.amazon.com/blogs/machine-learning/ai-agents-in-enterprises-best-practices-with-amazon-bedrock-agentcore/) (2026-02-03): enterprise harness layers across Runtime, Memory, Gateway, Policy, Observability, and Evaluations.

Strictly 2025-only general references are excluded from the primary list. The
original 2025 Anthropic harness article remains because it is a foundation
source for the course.

## Suggested Reading Order

1. `method-map.md`
2. `initializer-agent-playbook.md`
3. `coding-agent-startup-flow.md`
4. `prompt-calibration.md`
5. OpenAI Harness engineering
6. Anthropic Effective harnesses
7. Anthropic Harness design for long-running application development
8. OpenAI Codex agent loop
9. Anthropic agent evals
