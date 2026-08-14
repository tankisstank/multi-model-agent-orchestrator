# Agent backends

Select one backend per work package in this order.

## 1. Herdr-managed agent

Use Herdr only when `HERDR_ENV=1`, the `herdr` command is present, and the Herdr
skill is available. Load the installed skill and follow its current commands; use
`herdr --skill` or CLI help when the bundled guidance and installed CLI differ.

- Re-read pane/workspace state before every operation; Herdr display IDs are not
  durable ownership identifiers.
- Create a dedicated run-owned pane or tab and retain the returned identifiers plus
  stable metadata such as terminal ID and agent session ID.
- Start the requested provider with a verified static command in that pane. Store the
  worker contract plus package context in a UTF-8 assignment file, then use
  `scripts/send-herdr-worker-assignment.ps1` to send its contents literally and press
  Enter. Wait on agent status/output with bounded timeouts and capture output before
  cleanup.
- Herdr manages the terminal lifecycle; it does not change the requested provider or
  grant extra authority.

Do not put dynamic prompt text, here-strings, JSON, paths with user content, or
PowerShell variables inside `herdr pane run`. `pane run` is only for fixed startup
commands. In PowerShell, `\` does not escape `"`; avoid nested command strings rather
than trying to escape them.

If Herdr is installed but the leader is not inside it, do not control a focused Herdr
pane from outside. Recommend restarting/attaching through Herdr and fall back.

If Herdr or its skill is absent, recommend installing Herdr and its `herdr` skill.
Do not install either without user authorization.

## 2. Native Codex subagent

Use the host's real subagent capability. Record the task/agent ID and lifecycle
state. On completion or failure, collect its report, release/wait/interrupt through
the host API as appropriate, and mark the resource reconciled.

## 3. Direct external CLI

Use only when Herdr is not selected and a native subagent cannot satisfy the named
provider/package. Run `scripts/probe-providers.ps1`, inspect the installed CLI help,
and dispatch non-interactively only when output and process state can be captured.
Record PID, process start time, executable, session ID, command, and evidence.

Write dynamic worker text to an UTF-8 assignment file and use a provider invocation
verified from local help that reads stdin or the file. Do not construct a nested
PowerShell command containing the assignment text.

Never silently replace a provider explicitly named by the user. If the named backend
cannot be operated safely, block the package and offer the available choices.
