# shellcheck shell=bash
# index.tsv helpers: the index has a single writer (the calling script),
# awk-based and BSD-portable. Columns: task_id briefing task status updated_at.

# index_first_with_status <index> <status>
# Prints "id<TAB>briefing<TAB>task" of the first matching row; non-zero when none.
index_first_with_status() {
  awk -F'\t' -v s="$2" \
    '$4==s {print $1"\t"$2"\t"$3; found=1; exit} END {exit !found}' "$1"
}

# index_set_status <index> <task-id> <status> <timestamp>
index_set_status() {
  awk -F'\t' -v OFS='\t' -v id="$2" -v s="$3" -v ts="$4" \
    '$1==id {$4=s; $5=ts} {print}' "$1" > "$1.new" && mv "$1.new" "$1"
}
