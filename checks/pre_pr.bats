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

@test "branch commit subjects follow release-note convention" {
  local root
  local base_ref
  local bad_subjects
  root="$(repo_root)"
  base_ref="${GITHUB_BASE_REF:-main}"

  if ! git -C "$root" rev-parse --verify "origin/$base_ref" >/dev/null 2>&1; then
    skip "origin/$base_ref is not available"
  fi

  bad_subjects="$(
    git -C "$root" log --format=%s "origin/$base_ref..HEAD" |
      grep -v -E '^(feat|fix|docs|test|refactor|ci|chore)(\([a-z0-9._-]+\))?!?: .{1,72}$' || true
  )"

  run test -z "$bad_subjects"

  assert_success
  assert_output ""
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
