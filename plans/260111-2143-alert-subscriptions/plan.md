---
title: "Alert subscriptions research plan"
description: "Summarize alert API/model landscape and sketch best-practice roadmap for subscriptions"
status: pending
priority: P2
effort: 4h
branch: main
tags: [alerts, subscriptions, architecture]
created: 2026-01-11
---

## Background
- Grape APIs under `/Users/dinhdat/Documents/source-code/onboard/alert-active-record/alert-subscription/app/api/resources/alerts_api.rb` orchestrate alert CRUD plus the nested subscriptions endpoint.
- Models `/app/models/alert.rb` and `/app/models/alert_subscription_model.rb` define bidirectional associations and callbacks that drive publish timestamps and subscriptions.
- Migration `/db/migrate/20260110151143_create_alert_subscription_table.rb` owns `alert_subscriptions` with UUIDs, channel toggles, and a guard index for uniqueness.

## Key research areas
1. Verify current REST contracts and response shaping so new subscription flows honor the Entities (`app/api/entities`) and Grape helpers.
2. Confirm data invariants: subscriptions should never duplicate per user-alert, respect channel toggles, and leverage the existing `alert_subscription_models` join.
3. Identify best practices for subscription scaling: idempotent endpoints, background notification jobs, cache boundaries, and monitoring hooks.

## Phases
1. Phase 1 – Code map review & requirement capture (status: pending). Document API surface, models, migrations, and any missing fields needed for future alert types.
2. Phase 2 – Subscription experience design (status: pending). Outline how users will subscribe/unsubscribe via API, validate params, and ensure Entities stay consistent with any new payloads.
3. Phase 3 – Best-practice research summary (status: pending). Recommend security, performance, and maintainability guardrails (e.g., authorization, rate limiting, indexing, background cleanup).

## Key files to monitor
- `/Users/dinhdat/Documents/source-code/onboard/alert-active-record/alert-subscription/app/api/resources/alerts_api.rb`
- `/Users/dinhdat/Documents/source-code/onboard/alert-active-record/alert-subscription/app/models/alert.rb`
- `/Users/dinhdat/Documents/source-code/onboard/alert-active-record/alert-subscription/app/models/alert_subscription_model.rb`
- `/Users/dinhdat/Documents/source-code/onboard/alert-active-record/alert-subscription/db/migrate/20260110151143_create_alert_subscription_table.rb`

## Security & performance considerations
- Ensure subscription endpoints authenticate/authorize users before updating or deleting records; expand ApiHelpers if needed.
- Rate-limit subscription mutations and retry background notification dispatches to avoid thundering herd.
- Keep indexes covering `user_id`/`alert_id` and consider partial indexes for active alerts to speed lookups.
- Validate email/push toggles server-side to prevent malformed channel preferences.

## Outstanding questions
- Are there additional alert types or scopes that will require subscription feature toggles?
- What telemetry or audit trails are required for subscription changes?
- Should subscriptions trigger any background jobs (deliveries, analytics) once established?
