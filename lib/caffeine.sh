# shellcheck shell=bash
# Caffeine topic resolution, shared by every lint that claims a
# caffeine/<ns>/<name> pair exists: routine-spec-lint (task manifests)
# and routine-record-lint (release Caffeine entries). One resolver, so
# neither can drift from what "resolves" means — test/derivation.bats
# guards this class of duplication.

# caffeine_topic_resolves <caffeine-root> <topic>
# Exit 0 when <caffeine-root>/<topic>.sh or <caffeine-root>/<topic>.md
# exists; non-zero otherwise. <topic> is the "<ns>/<name>" form.
caffeine_topic_resolves() {
  [ -f "$1/$2.sh" ] || [ -f "$1/$2.md" ]
}

# caffeine_topic_list <caffeine-root>
# Space-joined, sorted list of every topic with a doc file — the
# vocabulary named back to the author on a refusal.
caffeine_topic_list() {
  find "$1" -mindepth 2 -maxdepth 2 -name '*.md' 2>/dev/null \
    | sed "s|^$1/||; s|\.md\$||" | sort | tr '\n' ' '
}
