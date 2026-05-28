#!/usr/bin/env bats

# Copy this file into a consuming repo's test/integration/ directory, then update
# XRT_TOOLS_DIR if the submodule is installed somewhere else.

XRT_APP_ROOT="${XRT_APP_ROOT:-$BATS_TEST_DIRNAME/../..}"
if [[ -z "${XRT_TOOLS_DIR:-}" ]]; then
  if [[ -d "$XRT_APP_ROOT/tools/xcode-repo-tools" ]]; then
    XRT_TOOLS_DIR="$XRT_APP_ROOT/tools/xcode-repo-tools"
  else
    XRT_TOOLS_DIR="$XRT_APP_ROOT"
  fi
fi
XRT_BASELINE_SIM_NAME="${XRT_BASELINE_SIM_NAME:-Bats App Baseline iPhone}"
XRT_UI_TEST_PROJECT="${XRT_UI_TEST_PROJECT:-src/UITests/UITests.xcodeproj}"
XRT_UI_TEST_SCHEME="${XRT_UI_TEST_SCHEME:-UITests}"
XRT_UI_TEST_LOGIN_SELECTOR="${XRT_UI_TEST_LOGIN_SELECTOR:-UITests/UITests/test_Login_With_Apple_Id}"
XRT_UI_TEST_SMOKE_SELECTOR="${XRT_UI_TEST_SMOKE_SELECTOR:-UITests/UITestsLaunchTests}"

load "$XRT_TOOLS_DIR/test/helpers/bats_setup"

setup_file() {
  source "$XRT_TOOLS_DIR/lib/simulators.sh"
  source "$XRT_TOOLS_DIR/lib/xcodebuild.sh"

  if [[ -z "${TEST_USERNAME:-}" || -z "${TEST_PASSWORD:-}" ]]; then
    printf 'TEST_USERNAME and TEST_PASSWORD must be set before running UI tests.\n' >&2
    return 1
  fi

  local baseline_row
  local baseline_udid
  local template_row
  local template_name

  if baseline_row="$(xrt_sims_find_by_name "$XRT_BASELINE_SIM_NAME" 2>/dev/null)"; then
    baseline_udid="$(printf '%s\n' "$baseline_row" | awk -F '\t' '{ print $2 }')"
    printf '%s\n' "$baseline_udid" >"$BATS_FILE_TMPDIR/baseline-udid"
    printf '%s\n' "existing" >"$BATS_FILE_TMPDIR/baseline-origin"
    return 0
  fi

  template_row="$(xrt_sims_list_available | awk -F '\t' '$1 ~ /^iPhone / && !found { print; found = 1 }')"
  template_name="$(printf '%s\n' "$template_row" | awk -F '\t' '{ print $1 }')"

  [[ -n "$template_name" ]]

  xrt_sims_create "$XRT_BASELINE_SIM_NAME" "$template_name" >/dev/null
  baseline_row="$(xrt_sims_find_by_name "$XRT_BASELINE_SIM_NAME")"
  baseline_udid="$(printf '%s\n' "$baseline_row" | awk -F '\t' '{ print $2 }')"

  printf '%s\n' "$baseline_udid" >"$BATS_FILE_TMPDIR/baseline-udid"
  printf '%s\n' "created" >"$BATS_FILE_TMPDIR/baseline-origin"
}

setup() {
  source "$XRT_TOOLS_DIR/lib/simulators.sh"
  source "$XRT_TOOLS_DIR/lib/xcodebuild.sh"
}

teardown_file() {
  source "$XRT_TOOLS_DIR/lib/simulators.sh"

  if [[ ! -f "$BATS_FILE_TMPDIR/baseline-udid" ]]; then
    return 0
  fi

  xrt_sims_stop "$(cat "$BATS_FILE_TMPDIR/baseline-udid")" >/dev/null 2>&1 || true
}

baseline_udid() {
  cat "$BATS_FILE_TMPDIR/baseline-udid"
}

baseline_origin() {
  cat "$BATS_FILE_TMPDIR/baseline-origin"
}

@test "baseline simulator exists" {
  run xrt_sims_find_by_name "$XRT_BASELINE_SIM_NAME"

  assert_success
}

@test "baseline simulator is booted" {
  run xrt_sims_wait_until_booted "$(baseline_udid)"

  assert_success
}

@test "baseline simulator is primed when newly created" {
  if [[ "$(baseline_origin)" == "existing" ]]; then
    skip "Baseline already exists; smoke test validates it can be reused."
  fi

  run xrt_xcodebuild_run_ui_tests \
    "$XRT_UI_TEST_PROJECT" \
    "$XRT_UI_TEST_SCHEME" \
    "$(baseline_udid)" \
    "$XRT_UI_TEST_LOGIN_SELECTOR" \
    "specific"

  assert_success
}

@test "baseline simulator supports parallel UI test smoke run" {
  run xrt_xcodebuild_run_ui_tests \
    "$XRT_UI_TEST_PROJECT" \
    "$XRT_UI_TEST_SCHEME" \
    "$(baseline_udid)" \
    "$XRT_UI_TEST_SMOKE_SELECTOR" \
    "normal"

  assert_success
}
