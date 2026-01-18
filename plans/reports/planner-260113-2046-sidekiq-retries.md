# Plan Summary

## Objective
Ensure Sidekiq retries for LongTaskWorker execute and are observable; add tests proving retry enqueue/backoff.

## Plan Location
/Users/dinhdat/Documents/source-code/onboard/alert-active-record/alert-subscription/plans/260113-2046-sidekiq-retries/plan.md

## Key Steps (phases)
- Validate config & flags: confirm no `--disable-retry`, queues align, scheduler enabled, rescues re-raise.
- Improve retry visibility: add structured logs for attempts, scheduled retry, exhaustion.
- Add retry tests: Sidekiq::Testing.fake!/inline! specs to assert retry enqueues and exhaustion, stub randomness.

## Files to touch
- app/workers/long_task_worker.rb (logging hooks)
- config/sidekiq.yml (queue/schedule confirmation) if needed
- config/initializers/sidekiq.rb (doc poll/retry expectations if needed)
- spec/support / spec/workers (new retry specs)
- README/ops note for start flags/observation guidance

## Notes
- Scheduler enabled; poll interval 10s.
- Worker already re-raises; retry: 3 set; queue long_tasks in config.

## Unresolved Questions
- Do we have a preferred logger format (JSON vs plain)?
- Is Sidekiq Web available for observing retries in environments?
