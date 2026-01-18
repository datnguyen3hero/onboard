---
title: "LongTaskWorker retry & scheduler hardening plan"
description: "Make cron-driven LongTaskWorker robust to failures and properly consume retries"
status: pending
priority: P2
effort: 6h
branch: main
tags: [backend, sidekiq, reliability]
created: 2026-01-13
---

## Overview
Ensure Sidekiq-scheduler cron `long_task_cronjob` reliably enqueues `LongTaskWorker`, retries failed runs with backoff, prevents unbounded overlaps, and surfaces failures via logging/metrics without over-engineering.

## Current context
- Worker: `app/workers/long_task_worker.rb` uses `Sidekiq::Worker`, queue `long_tasks`, `retry: 3`, random fail raising to Sidekiq retry set, logs start/error, no instrumentation.
- Scheduler: `config/sidekiq.yml` enables scheduler, cron `LongTaskWorker` every second, queue `long_tasks` present, limits only for other queues.
- Config: `config/initializers/sidekiq.rb` sets Redis URL, average scheduled poll 10s, no custom middleware/hooks.

## Risks / constraints
- Cron every second can enqueue new jobs faster than retries finish; risk of pile-up and duplicate work.
- No idempotency guard; retries could double side effects.
- No visibility into retry exhaustion or DLQ handling.
- Random sleep/failure makes deterministic testing harder.

## Phases
| # | Phase | Status | Effort | Link |
|---|-------|--------|--------|------|
| 1 | Baseline & requirements | pending | 1h | [phase-01](./phase-01-baseline.md) |
| 2 | Resilience design | pending | 2h | [phase-02-resilience-design.md) |
| 3 | Implementation plan | pending | 2h | [phase-03-impl.md) |
| 4 | Verification plan | pending | 1h | [phase-04-verification.md) |

## Dependencies / artifacts
- Sidekiq scheduler config in `config/sidekiq.yml`.
- Worker logic in `app/workers/long_task_worker.rb`.
- Potential middleware/hooks in `config/initializers/sidekiq.rb` or custom middleware folder.

## Acceptance criteria
- Cron enqueues exactly one job per tick; retries processed without starving new jobs.
- Failures moved to retry with backoff; after max retries errors are surfaced (logs/notifications) and DLQ observable.
- No unbounded overlapping runs; concurrency limited or job uniqueness enforced per tick.
- Tests cover success path, retry path, and scheduler config parsing.

## Unresolved questions
- Should cron remain every second or be slowed (e.g., 30s/1m) to avoid backlog?
- Should we enforce uniqueness per schedule tick (e.g., sidekiq-unique-jobs) to avoid overlap?
- What alerting/monitoring channel is available for exhausted retries? (logs only vs. error tracker)
- Should failures go to a custom DLQ queue or default dead set suffices?
