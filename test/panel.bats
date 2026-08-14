#!/usr/bin/env bats

load test_helper

TAB="$(printf '\t')"

# A corpus with one live run mid-develop and one archived run whose
# telemetry carries the failures and durations the panel reports.
make_corpus() {
  proot="$BATS_TEST_TMPDIR/proot"
  mkdir -p "$proot/runs/app/tickets/0002/briefings/01-auth/tasks/01-login" \
           "$proot/runs/app/tickets/archive/0001"
  printf '01-01%s01-auth%s01-login%sin_progress%s2026-01-01T00:00:00Z\n' \
    "$TAB" "$TAB" "$TAB" "$TAB" > "$proot/runs/app/tickets/0002/index.tsv"
  cat > "$proot/runs/app/tickets/0002/telemetry.jsonl" <<'T'
{"ts":"2026-01-01T00:00:00Z","event":"ticket.new","script":"bin/routine-ticket-new","ticket":"0002","task":"","exit":0,"ms":1}
{"ts":"2026-01-01T00:01:00Z","event":"gate.preflight","script":"bin/routine-gate","ticket":"0002","task":"","exit":0,"ms":900}
{"ts":"2026-01-01T00:02:00Z","event":"gate.analyst","script":"bin/routine-gate","ticket":"0002","task":"","exit":0,"ms":120}
{"ts":"2026-01-01T00:03:00Z","event":"ticket.approve","script":"bin/routine-approve","ticket":"0002","task":"","exit":0,"ms":2}
{"ts":"2026-01-01T00:04:00Z","event":"ticket.next","script":"bin/routine-next","ticket":"0002","task":"01-01","exit":0,"ms":3}
{"ts":"2026-01-01T00:05:00Z","event":"tdd.red","script":"login rejects a bad password [abc12345]","ticket":"0002","task":"01-01","exit":1,"ms":4200}
T
  cat > "$proot/runs/app/tickets/archive/0001/telemetry.jsonl" <<'T'
{"ts":"2026-01-01T00:00:00Z","event":"ticket.new","script":"bin/routine-ticket-new","ticket":"0001","task":"","exit":0,"ms":1}
{"ts":"2026-01-01T00:01:00Z","event":"gate.developer","script":"bin/routine-gate","ticket":"0001","task":"01-01","exit":1,"ms":8000}
{"ts":"2026-01-01T00:02:00Z","event":"gate.developer","script":"bin/routine-gate","ticket":"0001","task":"01-01","exit":0,"ms":7000}
{"ts":"2026-01-01T00:03:00Z","event":"gate.developer.script","script":"caffeine/ruby/rails.sh","ticket":"0001","task":"01-01","exit":1,"ms":40}
{"ts":"2026-01-01T00:04:00Z","event":"gate.developer.script","script":"caffeine/ruby/rails.sh","ticket":"0001","task":"01-01","exit":0,"ms":38}
{"ts":"2026-01-01T00:05:00Z","event":"gate.developer.script","script":"caffeine/js/express.sh","ticket":"0001","task":"01-01","exit":0,"ms":22}
{"ts":"2026-01-01T00:06:00Z","event":"ticket.block","script":"bin/routine-block","ticket":"0001","task":"01-02","exit":0,"ms":1}
{"ts":"2026-01-01T00:16:00Z","event":"ticket.unblock","script":"bin/routine-unblock","ticket":"0001","task":"01-02","exit":0,"ms":1}
T
  : > "$proot/runs/app/tickets/archive/0001/index.tsv"
}

panel() { run env ROUTINE_ROOT="$proot" "$ROUTINE_REPO_ROOT/bin/routine-panel"; }

@test "the page stands alone and changes nothing" {
  make_corpus
  before="$(cd "$proot" && find . -type f -exec cksum {} \; | sort)"
  panel
  [ "$status" -eq 0 ]
  case "$output" in *"<html"*) ;; *) false ;; esac
  # Self-contained: no external asset of any kind.
  ! printf '%s' "$output" | grep -qE 'src="http|href="http|<script src|<link '
  after="$(cd "$proot" && find . -type f -exec cksum {} \; | sort)"
  [ "$before" = "$after" ]
}

@test "the live run is the headline" {
  make_corpus
  panel
  case "$output" in *0002*) ;; *) false ;; esac
  case "$output" in *develop*) ;; *) false ;; esac
  case "$output" in *01-01*) ;; *) false ;; esac
  case "$output" in *routine-next*) ;; *) false ;; esac
}

@test "latency comes from the recorded durations" {
  make_corpus
  panel
  case "$output" in *8000*) ;; *) false ;; esac
  case "$output" in *gate.developer*) ;; *) false ;; esac
}

@test "failures surface as failures" {
  make_corpus
  panel
  case "$output" in *fail*) ;; *) false ;; esac
}

@test "the caffeine queue is ranked by failure rate" {
  make_corpus
  panel
  rails_at="$(printf '%s' "$output" | grep -n 'ruby/rails' | head -1 | cut -d: -f1)"
  express_at="$(printf '%s' "$output" | grep -n 'js/express' | head -1 | cut -d: -f1)"
  [ -n "$rails_at" ] && [ -n "$express_at" ]
  [ "$rails_at" -lt "$express_at" ]
}

@test "saturation shows the blocked time" {
  make_corpus
  panel
  case "$output" in *600*) ;; *) false ;; esac
}

@test "an empty corpus renders an honest page" {
  proot="$BATS_TEST_TMPDIR/empty"
  mkdir -p "$proot/runs"
  panel
  [ "$status" -eq 0 ]
  case "$output" in *"<html"*) ;; *) false ;; esac
  case "$output" in *othing*) ;; *) false ;; esac
}
