#!/usr/bin/env bash

XRT_TEST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

load "$XRT_TEST_ROOT/test_helper/bats-support/load"
load "$XRT_TEST_ROOT/test_helper/bats-assert/load"
