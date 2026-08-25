# runs/routine — the repository as its own app

This directory ships with the repository so that harness scripts gating
routine itself (`routine-selfcheck`, `routine-release-check`,
`routine-convention-check`, `routine-road-check`, the lints) always
find their telemetry destination: `telemetry.jsonl` beside this file,
created on first emission. Without a shipped destination, every fresh
clone silently dropped the repo's own gate verdicts until something
happened to create this directory.

Only this marker is tracked. Everything else under `runs/` — telemetry,
tickets, hooks — is session-local, script-owned state: durable
knowledge travels through `evidence/` records and the specs, never
through raw run state.
