#!/usr/bin/env bats

load "../test/helpers/bats_setup"

repo_root() {
  git rev-parse --show-toplevel
}

bats_bin() {
  local root
  root="$(repo_root)"

  if [[ -x "$root/test/bats/bin/bats" ]]; then
    printf '%s\n' "$root/test/bats/bin/bats"
    return
  fi

  command -v bats
}

@test "unit Bats suite passes" {
  run "$(bats_bin)" "$(repo_root)/test"

  assert_success
}

@test "tracked files do not contain common secret patterns" {
  local root
  root="$(repo_root)"

  run git -C "$root" grep -n -I -E \
    'BEGIN (RSA|OPENSSH|PRIVATE)|AKIA[0-9A-Z]{16}|ghp_[A-Za-z0-9_]{20,}|github_pat_[A-Za-z0-9_]{20,}|xox[baprs]-' \
    -- \
    . \
    ':!test/bats' \
    ':!test/test_helper/bats-assert' \
    ':!test/test_helper/bats-support'

  assert_failure 1
  assert_output ""
}

@test "UI test credential template keeps placeholders" {
  local root
  local template
  root="$(repo_root)"
  template="$root/src/UITests/UITests/UITestCredentials.swift"

  run grep -F 'static let username = "TEST_USERNAME"' "$template"
  assert_success

  run grep -F 'static let password = "TEST_PASSWORD"' "$template"
  assert_success
}

@test "ignored local-only files are not tracked" {
  local root
  root="$(repo_root)"

  run git -C "$root" ls-files -- .DS_Store .xrt-state ':(glob)**/xcuserdata/**'

  assert_success
  assert_output ""
}
