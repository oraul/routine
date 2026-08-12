## 1. Branch-push transport

- [x] 1.1 Red→green: `release/v*` push triggers the same gate-first
      job with the tag derived from the branch name; lint pins push
      triggers to `release/v*` only
