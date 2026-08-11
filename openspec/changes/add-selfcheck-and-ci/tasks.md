## 1. Scaffold, test-first

- [x] 1.1 Bootstrap the bats harness (`test/test_helper.bash`, first failing
      scaffold test) and make it green with `.claude-plugin/plugin.json`,
      `.gitignore` (single entry `runs/`), and the `bin/`/`lib/` layout
- [x] 1.2 Red→green: `lib/paths.sh` resolves the root as `ROUTINE_ROOT` →
      `$CLAUDE_PLUGIN_ROOT` → the script's own repo root

## 2. Selfcheck

- [x] 2.1 Red→green: `bin/routine-selfcheck` green path — shellcheck over
      `bin/` + `lib/` (+ sidecars when present), then the bats suite, exit 0,
      verified against a fixture tree via `ROUTINE_ROOT`
- [x] 2.2 Red→green: selfcheck exits non-zero on a lint failure without
      running tests, exits non-zero on a failing suite, and tolerates absent
      `caffeine/` sidecars

## 3. CI and docs

- [ ] 3.1 Add `.github/workflows/ci.yml`: `lint` (shellcheck), `test` matrix
      `[ubuntu-latest, macos-latest]` (bats), `openspec-validate` (strict)
- [ ] 3.2 Extend `CONTRIBUTING.md` with the conventions and the loop,
      verbatim, keeping the existing hard rules on sensitive data
- [ ] 3.3 Add the `README.md` stub opening with the thesis
