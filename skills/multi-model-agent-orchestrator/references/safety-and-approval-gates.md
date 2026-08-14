# Safety and approval gates

| Level | Allowed actions |
| --- | --- |
| Safe auto | Read, inspect, plan, non-mutating checks |
| Workspace auto | Edit in the selected workspace under recorded ownership/lease when implementation is requested |
| Approval required | Push, merge, deploy, production write, migration apply, external message, credential use |
| Forbidden by default | Broad destructive operations, credential extraction, policy/security bypass |

Require human approval for production database operations, deployment or traffic
switching, destructive data, outbound communications, security weakening, and
credential use beyond normal least privilege. State exact target, action, evidence,
impact, rollback, and expiry. A dry-run approval never authorizes apply.

Stop immediately if base revision changes materially; a forbidden path is touched;
data scope differs; a backup/checksum/health check/rollback is absent; a contract
check fails; authority is exceeded; evidence is insufficient; or budget is exhausted.
