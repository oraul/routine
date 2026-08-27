## Context

The carry check compares each MODIFIED requirement's live block
against the delta block, line by line, and fails on the first live
line the delta does not contain. It has no concept of intent.

## Decisions

- **Declaration lives in the delta file, not a sidecar** — the reader
  who sees the removal sees why in the same file; a separate manifest
  would drift from the delta it describes.
- **`## Removed Lines` sits outside the requirement blocks** — the
  block extractor stops at `## `/`### ` headings, so the section is
  naturally invisible to the carry comparison and needs no special
  casing in the block walk.
- **Exact-match bullets, not patterns** — a declaration matching by
  prefix or regex could exempt more than the author read. One bullet,
  one line, compared with `grep -qF` the same way the carry itself
  compares.
- **Undeclared losses still fail in the same run** — the first
  undeclared line is named, so a change cannot hide one removal
  behind another's declaration.
