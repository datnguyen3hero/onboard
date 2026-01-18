---
title: "Improve retry visibility"
description: "Add structured logging around retry lifecycle"
status: pending
priority: P1
effort: 1h
branch: main
tags: [observability]
created: 2026-01-13
---

## Context Links
- Worker: app/workers/long_task_worker.rb
- Sidekiq docs: retry callbacks (sidekiq_retries_exhausted), job context attributes

## Steps
1) Add structured logs on perform start/end and rescue with retry count/attempt: use `sidekiq_retry_in`/`sidekiq_retries_exhausted` hooks or context `jid`, `retry_count`, `queue`.
2) Log when retry scheduled: include `jid`, `attempt`, `next_in` seconds; avoid verbose stack unless needed.
3) Log on exhaustion handler: `warn` with `jid`, `args`, `error`.
4) Keep logs single-line JSON-friendly to ease grep.
5) Optionally surface metrics hooks (counter increment) if instrumentation present; otherwise leave TODO comment respecting YAGNI.

## Success Criteria
- Logs clearly show attempt number and next retry wait.
- Exhausted handler present and logs failures.
