# Phase 1 – Baseline & requirements

## Context links
- Worker: `/Users/dinhdat/Documents/source-code/onboard/alert-active-record/alert-subscription/app/workers/long_task_worker.rb`
- Scheduler: `/Users/dinhdat/Documents/source-code/onboard/alert-active-record/alert-subscription/config/sidekiq.yml`
- Sidekiq init: `/Users/dinhdat/Documents/source-code/onboard/alert-active-record/alert-subscription/config/initializers/sidekiq.rb`

## Goals
- Capture current behavior, risks, and requirements for retries/cron.

## Key observations
- Scheduler enabled; cron `LongTaskWorker` every second to queue `long_tasks`.
- Worker retries 3 times with backtrace; random sleep and random failure; logs start/error but no metrics.
- Poll interval 10s; cron 1s may enqueue multiple jobs per poll.
- No uniqueness/concurrency guard; possible overlap/backlog.

## Requirements to confirm
- Desired cron frequency (every second vs slower).
- Acceptable concurrency for long tasks; need for uniqueness per tick.
- Notification path when retries exhausted (log vs alerting).
- Whether side effects need idempotency protections.

## Exit criteria
- Agreed constraints on frequency/concurrency/visibility.
- Checklist of required safeguards to address in design.
