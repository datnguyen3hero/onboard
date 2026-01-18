---
title: "Sidekiq retry observability and enforcement"
description: "Ensure LongTaskWorker retries trigger and are visible with logging and tests"
status: pending
priority: P1
effort: 3h
branch: main
tags: [sidekiq, retries, observability]
created: 2026-01-13
---

# Plan

## Goal
Make Sidekiq retries for LongTaskWorker actually happen and be observable via logs/metrics, with tests proving retry enqueues.

## Context
- LongTaskWorker includes Sidekiq::Worker with retry: 3, backtrace: true, queue: long_tasks.
- sidekiq.yml lists queue long_tasks and schedules long_task_cronjob and mark_overdue_alert.
- initializer sets poll interval 10s; no global retry disable; worker rescues and re-raises.

## Phases
| # | Phase | Status | Effort | Link |
|---|-------|--------|--------|------|
| 1 | Validate config & flags | Pending | 0.5h | ./phase-01-validate.md |
| 2 | Improve retry visibility | Pending | 1h | ./phase-02-visibility.md |
| 3 | Add retry tests | Pending | 1.5h | ./phase-03-tests.md |

## Dependencies
- Sidekiq server startup flags; sidekiq.yml queues/schedule; Redis available.

## Risks
- Cron schedule frequency may affect test timing; backoff waits slow tests.

## Success
- Retries not disabled; errors propagate; logs show retry attempts; queue names match; tests assert retry enqueue/backoff.
