---
title: "Validate Sidekiq retry config"
description: "Confirm retries enabled, queue names match, scheduler aligned"
status: pending
priority: P1
effort: 0.5h
branch: main
tags: [sidekiq]
created: 2026-01-13
---

## Context Links
- Worker: app/workers/long_task_worker.rb
- Config: config/sidekiq.yml
- Initializer: config/initializers/sidekiq.rb

## Steps
1) Verify Sidekiq launched with default retry (no `--disable-retry` or `--retry false`). Document expected CLI flags in README/ops note.
2) Ensure queue names match: worker queue `long_tasks`, sidekiq.yml includes `long_tasks`; confirm cron schedule uses same queue or class; adjust if mismatch.
3) Confirm scheduler enabled (`:scheduler.enabled: true`) and poll interval 10s honored; note any required environment variables for enabling scheduler.
4) Check no global retry disable via `Sidekiq.options[:max_retries]` or middleware; ensure worker not rescuing without re-raise.
5) Add concise ops checklist for start command, env vars, and queue existence.

## Success Criteria
- Documented start flags showing retries enabled.
- Queue/schedule alignment confirmed.
- No code blocking retries (rescues re-raise).
