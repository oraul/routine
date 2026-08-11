## 1. Shared sync

- [x] 1.1 Refactor: extract `index_sync` into `lib/index.sh`; `routine-next`
      calls it; full suite stays green
- [x] 1.2 Red→green: analyst baseline syncs before coherence — a fresh
      well-formed ticket passes the analyst gate; stale rows still fail
