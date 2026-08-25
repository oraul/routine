# shellcheck shell=bash
# The approve fingerprint: one implementation for the recorder
# (routine-approve) and the judge (routine-audit) — two implementations
# of one hash would disagree with nothing to catch it. Hashes exactly
# what the skill shows the operator at the checkpoint, in sorted path
# order (briefings/*/briefing.md, then grounding.md, then
# requirement.md — b < g < r), through the same cksum %08x derivation
# routine-tdd records. Files a ticket does not carry are skipped, so a
# sparse fixture or an archived ticket still fingerprints. bash 3.2.

# approve_fingerprint <ticket-dir>
approve_fingerprint() {
  _a_ticket="$1"
  {
    for _a_f in "$_a_ticket"/briefings/*/briefing.md \
      "$_a_ticket/grounding.md" "$_a_ticket/requirement.md"; do
      [ -f "$_a_f" ] && cat "$_a_f"
    done
    :
  } | cksum | awk '{printf "%08x", $1}'
}
