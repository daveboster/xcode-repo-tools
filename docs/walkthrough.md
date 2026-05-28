# UI baseline walkthrough

This walkthrough starts after an app repo has added `xcode-repo-tools` at
`tools/xcode-repo-tools`.

It copies starter Bats files into the app repo, creates a reusable iPhone
baseline simulator, runs UI tests from that baseline, and then cleans up the
baseline image.

## TLDR: run the starter checks

Run the walkthrough driver to copy missing example files, then rerun the copied
checks directly whenever you want:

```bash
# Copy missing walkthrough files and run the starter checks once.
tools/xcode-repo-tools/test/bats/bin/bats tools/xcode-repo-tools/integration/examples_walkthrough.bats

# Run the copied pre-PR check.
tools/xcode-repo-tools/test/bats/bin/bats test/01-pre-pr.bats

# Run the copied integration tests.
tools/xcode-repo-tools/test/bats/bin/bats test/integration

# Run the copied pre-PR check and integration tests together.
tools/xcode-repo-tools/test/bats/bin/bats test/01-pre-pr.bats test/integration
```

The copy step leaves existing files alone so you can rerun the command after
editing the copied examples.

## 1. Add a first pre-PR check

Create the app repo test directory and copy the
[starter pre-PR check](../examples/01-app-pre-pr.bats):

```bash
mkdir -p test
cp tools/xcode-repo-tools/examples/01-app-pre-pr.bats test/01-pre-pr.bats
```

Run it:

```bash
tools/xcode-repo-tools/test/bats/bin/bats test/01-pre-pr.bats
```

## 2. Copy the baseline setup scenario

Copy the [baseline setup scenario](../examples/02-ui-baseline-setup.bats) into
the app repo:

```bash
mkdir -p test/integration
cp tools/xcode-repo-tools/examples/02-ui-baseline-setup.bats test/integration/02-ui-baseline-setup.bats
```

The setup scenario creates or recreates an iPhone simulator named
`Bats App Baseline iPhone`.

It also includes disabled tests for credential-backed setup:

- A commented-out test that checks `TEST_USERNAME` and `TEST_PASSWORD`.
- A commented-out test that calls `xrt_xcodebuild_run_ui_tests` in `specific`
  mode to prime the baseline image with an app-specific iCloud setup test.

Enable those tests only after setting the app project, scheme, and selector
values.

Run the setup:

```bash
tools/xcode-repo-tools/test/bats/bin/bats test/integration/02-ui-baseline-setup.bats
```

## 3. Copy the UI test scenario

Copy the [UI test scenario](../examples/03-ui-tests-from-baseline.bats) into the
app repo:

```bash
cp tools/xcode-repo-tools/examples/03-ui-tests-from-baseline.bats test/integration/03-ui-tests-from-baseline.bats
```

Set your app's Xcode project and UI test scheme, then run the scenario:

```bash
XRT_UI_TEST_PROJECT="YourApp.xcodeproj" \
XRT_UI_TEST_SCHEME="YourAppUITests" \
tools/xcode-repo-tools/test/bats/bin/bats test/integration/03-ui-tests-from-baseline.bats
```

The scenario uses the existing baseline simulator and runs
`UITests/UITestsLaunchTests` in normal mode. Normal mode allows Xcode's
parallel testing behavior to clone and reuse the baseline.

The copied file also includes a disabled test that shows how to call a targeted
test class or method with `xrt_xcodebuild_run_ui_tests`.

## 4. Copy the cleanup scenario

Copy the [cleanup scenario](../examples/04-ui-baseline-cleanup.bats) into the app
repo:

```bash
cp tools/xcode-repo-tools/examples/04-ui-baseline-cleanup.bats test/integration/04-ui-baseline-cleanup.bats
```

Run cleanup when you want to stop and delete the baseline image:

```bash
tools/xcode-repo-tools/test/bats/bin/bats test/integration/04-ui-baseline-cleanup.bats
```

## Copy all walkthrough files

```bash
mkdir -p test/integration
cp tools/xcode-repo-tools/examples/01-app-pre-pr.bats test/01-pre-pr.bats
cp tools/xcode-repo-tools/examples/02-ui-baseline-setup.bats test/integration/02-ui-baseline-setup.bats
cp tools/xcode-repo-tools/examples/03-ui-tests-from-baseline.bats test/integration/03-ui-tests-from-baseline.bats
cp tools/xcode-repo-tools/examples/04-ui-baseline-cleanup.bats test/integration/04-ui-baseline-cleanup.bats
```

## Run setup image

```bash
tools/xcode-repo-tools/test/bats/bin/bats test/integration/02-ui-baseline-setup.bats
```

## Run UI tests

```bash
XRT_UI_TEST_PROJECT="YourApp.xcodeproj" \
XRT_UI_TEST_SCHEME="YourAppUITests" \
tools/xcode-repo-tools/test/bats/bin/bats test/integration/03-ui-tests-from-baseline.bats
```

## Clean up

```bash
tools/xcode-repo-tools/test/bats/bin/bats test/integration/04-ui-baseline-cleanup.bats
```

This repo ignores `test/integration/` so copied walkthrough files do not get
committed by accident. Move or rename them when you are ready to keep them as
part of your app repo's permanent test suite.
