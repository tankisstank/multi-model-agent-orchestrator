# Provider adapters

This is the direct-CLI fallback. Use it only when Herdr is not selected and native
Codex subagents cannot satisfy the package. Probe the installed CLI before use.
Provider names do not guarantee equivalent commands or capabilities.

| Tier | Required capability | Suitable work |
| --- | --- | --- |
| 0 | Terminal process only | Interactive/manual observation |
| 1 | Non-interactive prompt and process detection | Bounded read-only work |
| 2 | Structured output and session resume | Managed implementation/review |
| 3 | Hooks, permission controls, or native API | Long-running governed work |

- Prefer Herdr-managed panes; otherwise use native subagents through the host's real
  capability before considering direct CLI dispatch.
- Require structured output for automated parsing; otherwise treat output as manual
  evidence and verify more strictly.
- Prefer a different provider/model for critical review.
- Never silently fall back when the user names a provider.
- Never use flags guessed from memory; inspect local CLI help and record the
  discovered invocation in run state.
