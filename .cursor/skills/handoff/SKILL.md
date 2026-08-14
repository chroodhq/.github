Post a short German `@cursor` comment on the issue that tells the agent how to work—not what the ticket already says. Always: one repo, one branch created from main by the agent (never assume Linear’s gitBranchName exists), one PR only. Add only concrete pitfalls, paths, and out-of-scope the description doesn’t carry.

Only that comment starts the agent—do not also set `delegate` / status via API (that double-spawns).

Before posting, skim the issue and enough of the codebase to name those pitfalls precisely. Follow-up fixes (CI, lint, review) go as further commits on that same branch/PR.
