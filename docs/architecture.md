# Project architecture

`xcode-repo-tools` is a reusable Bash automation library for Xcode and iOS
repositories.

## Two-layer design

### Layer 1: reusable helper repo

This repo owns generic Bash helper code. Helpers live under `lib/`, executable
wrappers live under `bin/`, and tests live under `test/` and `integration/`.

Keep helpers generic enough to reuse from multiple app repositories. Avoid
embedding app-specific paths, schemes, simulator names, credentials, or
release-process assumptions in the library layer.

### Layer 2: consuming app repos

App repositories add this repo as a submodule and write their own Bats files
that call the shared helpers.

Those app-level Bats files should read like pre-PR or GitHub Actions check
specifications for that app. They can decide which simulator to create, which
scheme to run, and which app-specific checks matter.

## Why Bats is used differently in each layer

In this repo, Bats is the TDD and unit testing tool for Bash helper behavior.
Implementation work starts with failing tests, then adds the minimum Bash
helper behavior needed to pass.

In consuming repos, Bats is primarily an orchestration and specification layer.
App-specific tests can describe readable pre-PR and GitHub Actions checks while
delegating reusable behavior to this repo.
