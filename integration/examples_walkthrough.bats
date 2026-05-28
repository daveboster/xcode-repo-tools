#!/usr/bin/env bats

load "../test/helpers/bats_setup"

setup_file() {
  XRT_REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  XRT_APP_ROOT="$XRT_REPO_ROOT"
  XRT_MOCK_BIN="$BATS_FILE_TMPDIR/bin"
  XRT_SIMCTL_STATE="$BATS_FILE_TMPDIR/simctl-devices.txt"
  XRT_XCRUN_LOG="$BATS_FILE_TMPDIR/xcrun-commands.log"
  XRT_XCODEBUILD_LOG="$BATS_FILE_TMPDIR/xcodebuild-commands.log"
  export XRT_REPO_ROOT XRT_APP_ROOT XRT_MOCK_BIN XRT_SIMCTL_STATE XRT_XCRUN_LOG XRT_XCODEBUILD_LOG

  mkdir -p "$XRT_MOCK_BIN"

  cat >"$XRT_SIMCTL_STATE" <<'SIMCTL'
== Devices ==
-- iOS 26.0 --
    iPhone 17 (AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE) (Shutdown)
SIMCTL

  create_mock_xcrun
  create_mock_xcodebuild
}

teardown_file() {
  rm -f \
    "$XRT_REPO_ROOT/test/01-pre-pr.bats" \
    "$XRT_REPO_ROOT/test/integration/02-ui-baseline-setup.bats" \
    "$XRT_REPO_ROOT/test/integration/03-ui-tests-from-baseline.bats" \
    "$XRT_REPO_ROOT/test/integration/04-ui-baseline-cleanup.bats"
  rmdir "$XRT_REPO_ROOT/test/integration" 2>/dev/null || true
}

setup() {
  export XRT_APP_ROOT XRT_MOCK_BIN XRT_SIMCTL_STATE XRT_XCRUN_LOG XRT_XCODEBUILD_LOG
}

create_mock_xcrun() {
  cat >"$XRT_MOCK_BIN/xcrun" <<EOF
#!/usr/bin/env bash
set -euo pipefail

state_file="$XRT_SIMCTL_STATE"
command_log_file="$XRT_XCRUN_LOG"
created_udid="CCCCCCCC-DDDD-EEEE-FFFF-000000000000"

printf '%s\n' "\$*" >>"\$command_log_file"

case "\$*" in
  "simctl list devices available")
    cat "\$state_file"
    ;;
  simctl\ create\ *)
    simulator_name="\$3"
    printf '    %s (%s) (Shutdown)\n' "\$simulator_name" "\$created_udid" >>"\$state_file"
    printf '%s\n' "\$created_udid"
    ;;
  simctl\ boot\ *)
    udid="\$3"
    awk -v udid="\$udid" '
      index(\$0, "(" udid ")") { sub(/\\([^)]*\\)[[:space:]]*$/, "(Booted)") }
      { print }
    ' "\$state_file" >"\$state_file.tmp"
    mv "\$state_file.tmp" "\$state_file"
    ;;
  simctl\ bootstatus\ *\ -b)
    exit 0
    ;;
  simctl\ shutdown\ *)
    udid="\$3"
    awk -v udid="\$udid" '
      index(\$0, "(" udid ")") { sub(/\\([^)]*\\)[[:space:]]*$/, "(Shutdown)") }
      { print }
    ' "\$state_file" >"\$state_file.tmp"
    mv "\$state_file.tmp" "\$state_file"
    ;;
  simctl\ delete\ *)
    udid="\$3"
    grep -v "(\$udid)" "\$state_file" >"\$state_file.tmp"
    mv "\$state_file.tmp" "\$state_file"
    ;;
  *)
    printf 'unexpected xcrun args: %s\n' "\$*" >&2
    exit 64
    ;;
esac
EOF

  chmod +x "$XRT_MOCK_BIN/xcrun"
}

create_mock_xcodebuild() {
  cat >"$XRT_MOCK_BIN/xcodebuild" <<EOF
#!/usr/bin/env bash
set -euo pipefail

printf '%s\n' "\$*" >>"$XRT_XCODEBUILD_LOG"
EOF

  chmod +x "$XRT_MOCK_BIN/xcodebuild"
}

copy_walkthrough_examples() {
  mkdir -p "$XRT_REPO_ROOT/test/integration"

  cp "$XRT_REPO_ROOT/examples/01-app-pre-pr.bats" "$XRT_REPO_ROOT/test/01-pre-pr.bats"
  cp "$XRT_REPO_ROOT/examples/02-ui-baseline-setup.bats" "$XRT_REPO_ROOT/test/integration/02-ui-baseline-setup.bats"
  cp "$XRT_REPO_ROOT/examples/03-ui-tests-from-baseline.bats" "$XRT_REPO_ROOT/test/integration/03-ui-tests-from-baseline.bats"
  cp "$XRT_REPO_ROOT/examples/04-ui-baseline-cleanup.bats" "$XRT_REPO_ROOT/test/integration/04-ui-baseline-cleanup.bats"
}

run_repo_bats() {
  (
    cd "$XRT_REPO_ROOT"
    PATH="$XRT_MOCK_BIN:$PATH" \
      XRT_TOOLS_DIR="$XRT_REPO_ROOT" \
      XRT_UI_TEST_PROJECT="ExampleApp.xcodeproj" \
      XRT_UI_TEST_SCHEME="ExampleAppUITests" \
      test/bats/bin/bats "$@"
  )
}

@test "01 copy walkthrough example files" {
  copy_walkthrough_examples

  run test -f "$XRT_REPO_ROOT/test/01-pre-pr.bats"
  assert_success
  run test -f "$XRT_REPO_ROOT/test/integration/02-ui-baseline-setup.bats"
  assert_success
  run test -f "$XRT_REPO_ROOT/test/integration/03-ui-tests-from-baseline.bats"
  assert_success
  run test -f "$XRT_REPO_ROOT/test/integration/04-ui-baseline-cleanup.bats"
  assert_success
}

@test "02 run copied pre-PR check" {
  run run_repo_bats test/01-pre-pr.bats

  assert_success
}

@test "03 run copied baseline setup" {
  run run_repo_bats test/integration/02-ui-baseline-setup.bats

  assert_success
  run test -s "$XRT_REPO_ROOT/.xrt-state/baseline-iphone-udid"
  assert_success
  run grep -F "simctl create Bats App Baseline iPhone iPhone 17" "$XRT_XCRUN_LOG"
  assert_success
}

@test "04 run copied UI tests from baseline" {
  run run_repo_bats test/integration/03-ui-tests-from-baseline.bats

  assert_success
  run grep -F -- "-only-testing:UITests/UITestsLaunchTests" "$XRT_XCODEBUILD_LOG"
  assert_success
}

@test "05 run copied cleanup" {
  run run_repo_bats test/integration/04-ui-baseline-cleanup.bats

  assert_success
  run test ! -e "$XRT_REPO_ROOT/.xrt-state/baseline-iphone-udid"
  assert_success
  run grep -F "simctl delete CCCCCCCC-DDDD-EEEE-FFFF-000000000000" "$XRT_XCRUN_LOG"
  assert_success
}
