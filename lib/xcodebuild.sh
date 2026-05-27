#!/usr/bin/env bash
set -euo pipefail

xrt_xcodebuild_run_ui_tests() {
  local project_path="$1"
  local scheme="$2"
  local simulator_udid="$3"
  local only_testing="${4:-}"
  local execution_mode="${5:-normal}"
  local test_args=(
    test
    -project "$project_path"
    -scheme "$scheme"
    -destination "platform=iOS Simulator,id=$simulator_udid"
  )

  case "$execution_mode" in
    normal)
      ;;
    specific)
      test_args+=(
        "-parallel-testing-enabled"
        "NO"
        "-maximum-concurrent-test-simulator-destinations"
        "1"
      )
      ;;
    *)
      printf 'Unknown xcodebuild execution mode: %s\n' "$execution_mode" >&2
      return 1
      ;;
  esac

  if [[ -n "$only_testing" ]]; then
    test_args+=("-only-testing:$only_testing")
  fi

  xcodebuild "${test_args[@]}"
}
