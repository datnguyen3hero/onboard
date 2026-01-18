# Phase 2 – Resilience design

## Objectives
- Define retry/backoff, uniqueness, and observability approach for cron-enqueued LongTaskWorker.

## Design options
- Retry/backoff: keep Sidekiq defaults or customize exponential; ensure `retry: 3` with jitter; add DLQ notification hook.
- Concurrency/overlap: limit `long_tasks` queue concurrency via `:limits` or `sidekiq_options concurrency`; or uniqueness per cron tick via middleware (e.g., Redis lock) without new gems.
- Scheduler cadence: consider reducing cron frequency to align with poll interval (e.g., 10s) to avoid burst enqueue.
- Observability: structured logs on enqueue, success, retry attempt, death; optional error tracker hook if available.

## Decisions (to finalize)
- Set cron to ≥ poll interval (10s) unless requirement for 1s throughput.
- Add lightweight Redis lock per job execution window to avoid overlap; release on completion/failure with TTL.
- Add `sidekiq_retries_exhausted` block logging fatal and pushing to notifier (if present).

## Data flow
1) Scheduler enqueues LongTaskWorker to `long_tasks` with metadata (attempt timestamp).
2) Worker acquires lock; if unavailable, log and skip (no-op) to avoid duplicates.
3) On success: log duration; release lock.
4) On failure: log; raise to Sidekiq; Sidekiq schedules retry with backoff; lock TTL prevents overlap.
5) On retries exhausted: callback logs fatal, emits notification.

## Risks
- Lock TTL mis-set could block legitimate runs; choose TTL >= max sleep + retry gap.
- Cron slower may miss tight SLAs; confirm requirement.

## Success criteria
- No overlapping executions from cron/retries.
- Failed jobs retried with backoff; exhausted jobs visible.
- Scheduler cadence does not flood queue.
