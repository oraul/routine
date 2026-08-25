# shellcheck shell=bash
# The sensitive shapes — one implementation, shared by every check
# that hunts them (routine-convention-check over diffs and commit
# messages, routine-pr-body-check over saved pull request bodies).
# Breadth is GitHub secret scanning's job; this list is this
# repository's own hard-rule history. Every consumer excludes this
# file from its own scan, since it must name what it hunts.
# shellcheck disable=SC2034  # consumed by the scripts that source it
routine_sensitive='claude\.ai/code/session|session_[A-Za-z0-9]{16,}|ghp_[A-Za-z0-9]{36}|github_pat_[A-Za-z0-9_]{22,}|sk-[A-Za-z0-9_-]{20,}|AKIA[0-9A-Z]{16}|BEGIN [A-Z ]*PRIVATE KEY'
