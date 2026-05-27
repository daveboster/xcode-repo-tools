#!/usr/bin/env bats

load "helpers/bats_setup"

setup() {
  source "$BATS_TEST_DIRNAME/../lib/simulators.sh"
  export PATH="$BATS_TEST_TMPDIR/bin:$PATH"
  mkdir -p "$BATS_TEST_TMPDIR/bin"
}

@test "xrt_sims_list_available prints available simulator name udid and state" {
  cat >"$BATS_TEST_TMPDIR/bin/xcrun" <<'EOF'
#!/usr/bin/env bash
if [[ "$*" != "simctl list devices available" ]]; then
  echo "unexpected xcrun args: $*" >&2
  exit 64
fi

cat <<'SIMCTL'
== Devices ==
-- iOS 26.0 --
    iPhone 17 (AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE) (Shutdown) 
    iPhone 17 Pro (11111111-2222-3333-4444-555555555555) (Booted) 
SIMCTL
EOF
  chmod +x "$BATS_TEST_TMPDIR/bin/xcrun"

  run xrt_sims_list_available

  assert_success
  assert_line $'iPhone 17\tAAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE\tShutdown'
  assert_line $'iPhone 17 Pro\t11111111-2222-3333-4444-555555555555\tBooted'
}
