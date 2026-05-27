# xcode-repo-tools

Reusable Bash automation helpers for Xcode and iOS repositories.

`xcode-repo-tools` provides shell libraries, executable wrappers, Bats tests,
and example integration scenarios for simulator management, `xcodebuild` UI
test execution, repo checks, markdown checks, and logging.

## Who this is for

The tool helps you write and run Xcode UI integration tests and manage
simulator images for your project.

- Bats/bash framework tests help organize test suites and can be run from the
  terminal for simple, clean results.
- Set up and reuse base simulator images to improve UI testing times.
- Includes an Xcode UI test for setting up Apple ID with sandbox credentials,
  useful for testing CloudKit schema smoke tests.
- Write your own readable
  [Bats](https://bats-core.readthedocs.io/en/stable/tutorial.html) files for
  pre-PR and GitHub Actions checks.

## Architecture

The project has two layers:

- **Layer 1:** reusable Bash helpers in this repo.
- **Layer 2:** consuming app repositories that load these helpers from Bats
  scenarios and app-specific check files.

In this repo, Bats is used for TDD and unit testing Bash helpers. In consuming
repos, Bats is used as a readable orchestration layer for pre-PR and CI checks.

## Quick start

Add this repo to an app repo as a submodule:

```bash
git submodule add https://github.com/daveboster/xcode-repo-tools.git tools/xcode-repo-tools
git submodule update --init --recursive
```

Load helpers from your app repo Bats files:

```bash
load "tools/xcode-repo-tools/test/helpers/bats_setup"

setup() {
  source "tools/xcode-repo-tools/lib/simulators.sh"
  source "tools/xcode-repo-tools/lib/xcodebuild.sh"
}
```

For a starter UI baseline scenario, copy
`tools/xcode-repo-tools/examples/starter-ui-baseline.bats` into your app repo's
`integration/` directory and update the project, scheme, simulator, and test
selector variables.

## Documentation

- [Getting started](docs/getting-started.md): add this repo as a submodule and
  load helpers from an app repo.
- [Project architecture](docs/architecture.md): understand the two-layer
  design and why Bats is used differently in each layer.
- [Testing](docs/testing.md): run unit tests, integration tests, VS Code tasks,
  and local UI test credentials.
- [XTDD workflow](docs/xtdd.md): use integration-first Extreme TDD for helper
  behavior.
- [Release and commit conventions](docs/release-and-commits.md): write commits
  and release notes that work with the repo checks.
- [Roadmap](docs/roadmap.md): track current and planned helper work.
- [Contributing](CONTRIBUTING.md): file issues, submit pull requests, and follow
  the project contribution expectations.

## Local PR checks

Before opening a pull request:

```bash
git submodule update --init --recursive
test/bats/bin/bats test
bash -n lib/*.sh test/helpers/*.bash test/*.bats integration/*.bats checks/*.bats bin/*
test/bats/bin/bats checks/pre_pr.bats
```

Run integration scenarios on a prepared local machine when the changed behavior
uses real simulators or Xcode:

```bash
test/bats/bin/bats integration
```

## Status

Simulator helpers and the UI test baseline workflow are partially implemented.
See [Roadmap](docs/roadmap.md) for the detailed progress checklist.
