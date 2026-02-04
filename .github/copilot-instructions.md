# Copilot instructions for airbnb-dbt

## Quick summary
- This repository currently contains raw CSV datasets under `Data/`: `bookings.csv`, `listings.csv`, and `hosts.csv`.
- Files are plain UTF-8 CSVs with headers using snake_case column names and predictable id columns (`listing_id`, `host_id`, `booking_id`).

## Big-picture intent (discoverable)
- The repo name `airbnb-dbt` and the dataset layout suggest a data transformation project centered on these CSV sources. There are no dbt models, configs, or code in the repo yet — the codebase is currently data-only.
- Primary data flows you will encounter:
  - `bookings.csv` references `listing_id` (UUID-like `booking_id`; booking_date, booking_amount) → transactional event source
  - `listings.csv` contains listing-level attributes (price_per_night, property_type, city, country, created_at)
  - `hosts.csv` contains host attributes keyed by `host_id` and a `host_since` date

## Patterns and conventions to preserve
- Column naming: snake_case (e.g., `booking_amount`, `price_per_night`, `created_at`). Keep this convention for any new CSVs or schema changes.
- Keys and joins:
  - bookings.listing_id → listings.listing_id (primary join key for revenue/occupancy analyses)
  - listings.host_id → hosts.host_id (link listings to host metadata)
- Timestamps:
  - `created_at` appears as a full timestamp (e.g., `2025-12-26 14:15:54.011160`) in multiple files; `booking_date` and `host_since` use YYYY-MM-DD date format. Treat `created_at` as ingestion timestamp when building incremental pipelines.
- ID formats: `booking_id` values are UUIDs, while `listing_id` and `host_id` are integers. Avoid mixing types for the same logical key.
- File layout: all source data lives in `Data/` and filenames use lowercase plural nouns (keep that pattern).

## Concrete examples (copyable)
- Safe join example (SQL style):
  SELECT
    b.listing_id,
    l.city,
    h.host_since,
    SUM(b.booking_amount) AS total_revenue
  FROM Data/bookings.csv AS b
  JOIN Data/listings.csv AS l ON b.listing_id = l.listing_id
  JOIN Data/hosts.csv AS h ON l.host_id = h.host_id
  WHERE b.booking_status = 'confirmed'
  GROUP BY 1,2,3;

- Column references you can rely on (examples):
  - `listings.csv`: listing_id, host_id, property_type, room_type, city, country, price_per_night, created_at
  - `hosts.csv`: host_id, host_name, host_since, is_superhost, response_rate, created_at
  - `bookings.csv`: booking_id, listing_id, booking_date, nights_booked, booking_amount, cleaning_fee, service_fee, booking_status, created_at

## For AI agents: how to be helpful and safe here
- Make minimal changes to existing CSV files; if you must change a header or datatype, include a migration plan and update README/docs.
- Use relative paths (`Data/*.csv`) and avoid absolute or machine-specific paths (e.g., OneDrive user folders).
- Preserve id formats and timestamps when generating new samples/tests.
- When adding code (dbt models, SQL, ETL scripts), include a small README and at least one example query that demonstrates the expected joins and aggregates above.

## What *not* to assume
- There are no existing tests, CI, or dbt config files to infer build/test commands. If you add tooling, include clear instructions and sample commands in the repo README and in CI.

## Useful follow-ups for maintainers (ask in PRs or issues)
- Confirm intended execution environment (dbt + warehouse, or local ETL notebooks). 
- Confirm whether `created_at` is an ingestion timestamp (currently identical for many rows) or true event time.

---
If anything above is unclear or you'd like me to expand a section (e.g., add recommended dbt layout or CI templates), tell me which part to expand and I will iterate. ✅