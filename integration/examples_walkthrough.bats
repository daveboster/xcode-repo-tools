#!/usr/bin/env bats

load "../test/helpers/bats_setup"

setup_file() {
  XRT_REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  export XRT_REPO_ROOT
}

setup() {
  XRT_APP_ROOT="$BATS_TEST_TMPDIR/app"
  XRT_MOCK_BIN="$BATS_TEST_TMPDIR/bin"
  XRT_SIMCTL_STATE="$BATS_TEST_TMPDIR/simctl-devices.txt"
  XRT_XCRUN_LOG="$BATS_TEST_TMPDIR/xcrun-commands.log"
  XRT_XCODEBUILD_LOG="$BATS_TEST_TMPDIR/xcodebuild-commands.log"
  export XRT_APP_ROOT XRT_MOCK_BIN XRT_SIMCTL_STATE XRT_XCRUN_LOG XRT_XCODEBUILD_LOG

  mkdir -p "$XRT_APP_ROOT/tools" "$XRT_APP_ROOT/test" "$XRT_APP_ROOT/integration" "$XRT_MOCK_BIN"
  ln -s "$XRT_REPO_ROOT" "$XRT_APP_ROOT/tools/xcode-repo-tools"
  git -C "$XRT_APP_ROOT" init >/dev/null

  cat >"$XRT_SIMCTL_STATE" <<'SIMCTL'
== Devices ==
-- iOS 26.0 --
    iPhone 17 (AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE) (Shutdown)
SIMCTL

  create_mock_xcrun
  create_mock_xcodebuild
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
  cp "$XRT_REPO_ROOT/examples/app-pre-pr.bats" "$XRT_APP_ROOT/test/pre_pr.bats"
  cp "$XRT_REPO_ROOT/examples/ui-baseline-setup.bats" "$XRT_APP_ROOT/integration/ui-baseline-setup.bats"
  cp "$XRT_REPO_ROOT/examples/ui-tests-from-baseline.bats" "$XRT_APP_ROOT/integration/ui-tests-from-baseline.bats"
  cp "$XRT_REPO_ROOT/examples/ui-baseline-cleanup.bats" "$XRT_APP_ROOT/integration/ui-baseline-cleanup.bats"
}

run_app_bats() {
  (
    cd "$XRT_APP_ROOT"
    PATH="$XRT_MOCK_BIN:$PATH" \
      XRT_UI_TEST_PROJECT="ExampleApp.xcodeproj" \
      XRT_UI_TEST_SCHEME="ExampleAppUITests" \
      tools/xcode-repo-tools/test/bats/bin/bats "$@"
  )
}

@test "walkthrough example Bats files run in documented order" {
  copy_walkthrough_examples

  run run_app_bats test/pre_pr.bats
  assert_success

  run run_app_bats integration/ui-baseline-setup.bats
  assert_success
  run test -s "$XRT_APP_ROOT/.xrt-state/baseline-iphone-udid"
  assert_success

  run run_app_bats integration/ui-tests-from-baseline.bats
  assert_success
  run grep -F -- "-only-testing:UITests/UITestsLaunchTests" "$XRT_XCODEBUILD_LOG"
  assert_success

  run run_app_bats integration/ui-baseline-cleanup.bats
  assert_success
  run test ! -e "$XRT_APP_ROOT/.xrt-state/baseline-iphone-udid"
  assert_success

  run grep -F "simctl create Bats App Baseline iPhone iPhone 17" "$XRT_XCRUN_LOG"
  assert_success
  run grep -F "simctl delete CCCCCCCC-DDDD-EEEE-FFFF-000000000000" "$XRT_XCRUN_LOG"
  assert_success
}
