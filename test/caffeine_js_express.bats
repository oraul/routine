#!/usr/bin/env bats

load test_helper

sidecar="caffeine/js/express.sh"

make_clean_target() {
  tgt="$BATS_TEST_TMPDIR/app"
  mkdir -p "$tgt/src/routes"
  printf '%s\n' "const router = express.Router()" \
    "router.get('/orders', async (req, res, next) => {" \
    "  const orders = await orderStore.list()" \
    "  res.json(orders)" \
    "})" > "$tgt/src/routes/orders.js"
}

@test "clean express code passes" {
  make_clean_target
  run env TARGET="$tgt" bash "$ROUTINE_REPO_ROOT/$sidecar"
  [ "$status" -eq 0 ]
}

@test "sync fs call in request code is caught" {
  make_clean_target
  printf 'const data = readFileSync(path)\n' > "$tgt/src/routes/f.js"
  run env TARGET="$tgt" bash "$ROUTINE_REPO_ROOT/$sidecar"
  [ "$status" -ne 0 ]
  case "$output" in *readFileSync*) ;; *) false ;; esac
}

@test "console.log is caught, console.error passes" {
  make_clean_target
  printf 'console.log(order)\n' > "$tgt/src/routes/l.js"
  run env TARGET="$tgt" bash "$ROUTINE_REPO_ROOT/$sidecar"
  [ "$status" -ne 0 ]
  rm "$tgt/src/routes/l.js"
  printf "console.error('boom', err)\n" > "$tgt/src/routes/ok.js"
  run env TARGET="$tgt" bash "$ROUTINE_REPO_ROOT/$sidecar"
  [ "$status" -eq 0 ]
}

@test "debugger statement is caught" {
  make_clean_target
  printf 'function x() { debugger; }\n' > "$tgt/src/routes/d.js"
  run env TARGET="$tgt" bash "$ROUTINE_REPO_ROOT/$sidecar"
  [ "$status" -ne 0 ]
}

@test "wildcard CORS is caught, scoped origin passes" {
  make_clean_target
  printf "app.use(cors())\n" > "$tgt/src/app.js"
  run env TARGET="$tgt" bash "$ROUTINE_REPO_ROOT/$sidecar"
  [ "$status" -ne 0 ]
  printf "app.use(cors({ origin: 'https://shop.example' }))\n" > "$tgt/src/app.js"
  run env TARGET="$tgt" bash "$ROUTINE_REPO_ROOT/$sidecar"
  [ "$status" -eq 0 ]
}
