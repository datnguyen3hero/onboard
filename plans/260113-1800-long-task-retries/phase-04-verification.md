# Phase 4 – Verification plan

## Goals
- Validate scheduler cadence, retry behavior, overlap prevention, and logging.

## Checks
- Config: parse `config/sidekiq.yml` to ensure cron expression updated and queue present.
- Unit tests: LongTaskWorker lock behavior, success, failure/retry, retries exhausted handler.
- Integration (optional): enqueue worker via `Sidekiq::Testing.fake!` to verify lock/skip logic and logging markers.

## Manual verification
- Run Sidekiq with scheduler; observe only one job per cadence, retries scheduled on failures; verify dead set entries include log/notify when retries exhausted.

## Definition of done
- Tests green.
- Observability signals present (logs/notify) for success/failure/exhausted.
- Cron cadence prevents backlog at configured poll interval.
