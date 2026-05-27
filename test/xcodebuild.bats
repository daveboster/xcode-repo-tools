#!/usr/bin/env bats

load "helpers/bats_setup"
load "helpers/mock_xcodebuild"

setup() {
  source "$BATS_TEST_DIRNAME/../lib/xcodebuild.sh"
  export PATH="$BATS_TEST_TMPDIR/bin:$PATH"
  mkdir -p "$BATS_TEST_TMPDIR/bin"
}

assert_xcodebuild_command_logged() {
  local expected_command="$1"

  grep -Fx "$expected_command" "$BATS_TEST_TMPDIR/xcodebuild-commands.log"
}

@test "xrt_xcodebuild_run_ui_tests runs UI tests for simulator destination" {
  xrt_mock_xcodebuild \
    "$BATS_TEST_TMPDIR/bin" \
    "$BATS_TEST_TMPDIR/xcodebuild-commands.log"

  run xrt_xcodebuild_run_ui_tests \
    "src/UITests/UITests.xcodeproj" \
    "UITests" \
    "AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE"

  assert_success
  assert_xcodebuild_command_logged \
    "test -project src/UITests/UITests.xcodeproj -scheme UITests -destination platform=iOS Simulator,id=AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE"
}
