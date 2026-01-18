# Phase 3 – Implementation plan

## Files to touch
- Modify: `/Users/dinhdat/Documents/source-code/onboard/alert-active-record/alert-subscription/app/workers/long_task_worker.rb`
- Modify: `/Users/dinhdat/Documents/source-code/onboard/alert-active-record/alert-subscription/config/sidekiq.yml`
- Modify (if needed): `/Users/dinhdat/Documents/source-code/onboard/alert-active-record/alert-subscription/config/initializers/sidekiq.rb`
- Add tests: `/Users/dinhdat/Documents/source-code/onboard/alert-active-record/alert-subscription/spec/workers/long_task_worker_spec.rb` (if not existing)

## Steps
1) Scheduler cadence
- Set `long_task_cronjob` to align with poll interval (e.g., every 10s) unless requirement states 1s.
- Add queue for scheduler entry if missing; ensure `long_tasks` exists (already defined).

2) Worker resilience
- Add Redis lock (e.g., `Sidekiq.redis` with SET NX PX) keyed by worker name to prevent overlap; TTL > max execution (e.g., 30s) to cover sleep+retry gaps.
- On lock miss, log and return (avoid duplicate work).
- Wrap perform to measure duration; log structured context including `jid`, `attempt` (from `sidekiq_retry_count`), `sleep_time`.

3) Retry exhaustion handling
- Add `sidekiq_retries_exhausted` block to log fatal and emit notification hook if available (e.g., `ErrorNotifier.notify(e, context)`, guarded if defined).

4) Backoff/Retry config
- Keep `retry: 3`; optionally add `sidekiq_options backtrace: true` already present; consider `sidekiq_retry_in` for jitter if needed, otherwise rely on default exponential.

5) Tests
- Unit: lock prevents concurrent perform (simulate redis lock); on lock miss, does not sleep/raise.
- Retry: simulate failure, ensure error re-raises and `sidekiq_retries_exhausted` logs/notify when retries done.
- Scheduler: config spec to assert cron expression for `long_task_cronjob` matches decided cadence.

## Acceptance criteria mapping
- Single job per cadence: enforced by lock+cadence.
- Retries: default exponential; exhaustion visible via log/notify.
- Overlap: prevented by lock with TTL.
- Tests cover success, failure, scheduler config.
