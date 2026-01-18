---
title: "Add retry tests"
description: "Prove retry enqueues and backoff for LongTaskWorker"
status: pending
priority: P1
effort: 1.5h
branch: main
tags: [tests, sidekiq]
created: 2026-01-13
---

## Context Links
- Specs: spec/requests/api/secure/v1/alerts_spec.rb etc. (RSpec present)
- Sidekiq testing: Sidekiq::Testing.inline!/fake!

## Steps
1) Configure spec helper to use `Sidekiq::Testing.fake!` for retry assertions; ensure cleanup per example.
2) Write worker spec for LongTaskWorker: force failure (stub rand to raise), perform job, assert retry set receives job with `retry_count` increment / enqueued in `long_tasks`.
3) Assert exhaustion hook called after 3 retries; use `Sidekiq::Testing.inline!` with controlled raises and counter.
4) Add expectation on log lines or captured logger containing retry attempt and scheduled delay.
5) Document waiting guidance: backoff uses Sidekiq defaults; in dev, expect exponential delay; advise using Sidekiq Web UI to observe retries.

## Success Criteria
- Failing job enqueues retries up to limit.
- Exhaustion handler executed after max retries.
- Tests deterministic via stubs.
