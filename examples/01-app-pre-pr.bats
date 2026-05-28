#!/usr/bin/env bats

# Copy this file into a consuming repo's test/ directory.

source "$BATS_TEST_DIRNAME/xrt-example-config.bash"

load "$XRT_TOOLS_DIR/test/helpers/bats_setup"

@test "xcode-repo-tools submodule is available" {
  run test -f "$XRT_TOOLS_DIR/lib/simulators.sh"

  assert_success
}

@test "local-only files are not tracked" {
  run git -C "$XRT_APP_ROOT" ls-files -- .DS_Store .xrt-state ':(glob)**/xcuserdata/**'

  assert_success
  assert_output ""
}
