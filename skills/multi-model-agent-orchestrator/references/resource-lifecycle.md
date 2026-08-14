# Resource lifecycle

Register a resource immediately when the run creates it. Minimum record:

```json
{
  "id": "R1",
  "kind": "herdr-pane | native-agent | process | playwright | temp-path | worktree",
  "owner_run_id": "run-id",
  "work_package_id": "WP1",
  "created_by_run": true,
  "locator": {},
  "status": "active",
  "cleanup": { "policy": "auto | approval | preserve", "result": null }
}
```

Use strong locators: Herdr terminal/session metadata rather than a stale pane ID;
PID plus process creation time and executable rather than a process name; canonical
absolute path plus an allowed cleanup root for files; repository root, worktree path,
base SHA, and HEAD SHA for worktrees.

## Reconcile order

1. Stop new dispatch and collect output, reports, logs, screenshots, traces, and
   checksums required as evidence.
2. Ask the owning worker to close Playwright pages, contexts, browsers, and servers.
   If it cannot, stop only the exact registered child process after identity checks.
3. Release/interrupt native agents through the host. For Herdr, refresh the pane list,
   match stable metadata, refuse the leader/focused pane, then close owned panes.
4. Delete only registered temporary paths under their recorded cleanup roots.
5. For worktrees, record HEAD and status. Remove only a clean, registered worktree
   whose evidence/commit is retained. Preserve dirty or untracked content and report
   recovery commands.
6. Close an owned tab/workspace only after proving it contains no pre-existing or
   unowned pane.

Run cleanup on success, failure, timeout, cancellation, and resume. A missing resource
is `not-found`, not automatically `cleaned`. Retry boundedly; then record `blocked`
with the failing command and manual recovery action.

Never use broad process-name termination, wildcard deletion, an unverified changing
Herdr ID, or forced worktree removal as routine cleanup.
