#!/usr/bin/env bats

load test_helper

# A minimal probe sidecar built on the shared library.
make_probe() {
  tgt="$BATS_TEST_TMPDIR/app"
  mkdir -p "$tgt/app/models"
  probe="$BATS_TEST_TMPDIR/probe.sh"
  cat > "$probe" <<EOF
#!/usr/bin/env bash
set -u
. "$ROUTINE_REPO_ROOT/lib/sidecar.sh"
sidecar_init x/probe
check P1 "no telescopes" 'telescope' "\$target"
exit "\$fails"
EOF
  chmod +x "$probe"
}

@test "hits carry a parseable bracketed rule id" {
  make_probe
  printf 'a telescope here\n' > "$tgt/app/models/t.rb"
  run env TARGET="$tgt" bash "$probe"
  [ "$status" -eq 1 ]
  case "$output" in *"caffeine/x/probe[P1] no telescopes: "*) ;; *) false ;; esac
}

@test "vendored directories are excluded, vendored content is not" {
  make_probe
  mkdir -p "$tgt/vendor/gems" "$tgt/node_modules/pkg"
  printf 'telescope in vendored dir\n' > "$tgt/vendor/gems/v.rb"
  printf 'telescope in node dir\n' > "$tgt/node_modules/pkg/n.rb"
  run env TARGET="$tgt" bash "$probe"
  [ "$status" -eq 0 ]
  printf 'telescope path is /vendor/x\n' > "$tgt/app/models/real.rb"
  run env TARGET="$tgt" bash "$probe"
  [ "$status" -eq 1 ]
  case "$output" in *"app/models/real.rb"*) ;; *) false ;; esac
}

@test "a broken instrument exits 2, never 0" {
  make_probe
  cat > "$probe" <<EOF
#!/usr/bin/env bash
set -u
. "$ROUTINE_REPO_ROOT/lib/sidecar.sh"
sidecar_init x/probe
check P1 "broken pattern" '(' "\$target"
exit "\$fails"
EOF
  printf 'anything\n' > "$tgt/app/models/t.rb"
  run env TARGET="$tgt" bash "$probe"
  [ "$status" -eq 2 ]
  case "$output" in *"broken instrument"*) ;; *) false ;; esac
}

@test "missing scope directory passes cleanly" {
  make_probe
  run env TARGET="$BATS_TEST_TMPDIR/nonexistent" bash "$probe"
  [ "$status" -eq 0 ]
}
