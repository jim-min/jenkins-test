#!/bin/sh
set -eu

REPORT_DIR="${REPORT_DIR:-test-reports}"
BUILD_LOG="${BUILD_LOG:-build.log}"
TEST_LOG="${TEST_LOG:-${REPORT_DIR}/test-output.txt}"
ANALYSIS_FILE="${ANALYSIS_FILE:-failure-analysis.txt}"

mkdir -p "${REPORT_DIR}"

{
    echo "Build Failure Analysis"
    echo "======================"
    echo "Job: ${JOB_NAME:-unknown}"
    echo "Build Number: ${BUILD_NUMBER:-unknown}"
    echo "Build URL: ${BUILD_URL:-unknown}"
    echo "Workspace: ${WORKSPACE:-$(pwd)}"
    echo ""

    echo "Detected Cause"
    echo "--------------"

    if [ -f "${BUILD_LOG}" ] && grep -E "error: package org\.junit|package org\.junit.*does not exist" "${BUILD_LOG}" >/dev/null 2>&1; then
        echo "JUnit dependency was not found during compilation."
        echo "Fix: check that lib/junit.jar exists and javac uses -cp lib/junit.jar."
    elif [ -f "${BUILD_LOG}" ] && grep -E "cannot find symbol" "${BUILD_LOG}" >/dev/null 2>&1; then
        echo "Java compilation failed because a class, method, or variable name could not be found."
        echo "Fix: compare the name in the error line with StudentManager.java and StudentManagerTest.java."
    elif [ -f "${BUILD_LOG}" ] && grep -E "class .* is public, should be declared in a file named" "${BUILD_LOG}" >/dev/null 2>&1; then
        echo "A public Java class name does not match its file name."
        echo "Fix: rename the file or rename the public class so both names match."
    elif [ -f "${BUILD_LOG}" ] && grep -E "error:" "${BUILD_LOG}" >/dev/null 2>&1; then
        echo "Java compilation failed."
        echo "Fix: read the first javac error below, then edit the referenced .java file and line."
    elif [ -f "${TEST_LOG}" ] && grep -E "AssertionFailedError|expected:|but was:" "${TEST_LOG}" >/dev/null 2>&1; then
        echo "A JUnit assertion failed."
        echo "Fix: check whether StudentManager behavior or the expected test value is wrong."
    elif [ -f "${TEST_LOG}" ] && grep -E "AssertionFailedError|TestExecutionException|FAILED|\\[ERROR\\]|\\[FAILURE\\]" "${TEST_LOG}" >/dev/null 2>&1; then
        echo "Tests ran, but at least one test failed or threw an exception."
        echo "Fix: inspect the failed test name and stack trace below."
    elif [ -f "${TEST_LOG}" ] && grep -E "0 tests found|0 tests started" "${TEST_LOG}" >/dev/null 2>&1; then
        echo "JUnit did not discover any tests."
        echo "Fix: make sure test classes use @Test and class names end with Test."
    else
        echo "The exact failure type was not recognized automatically."
        echo "Fix: inspect the build and test log excerpts below."
    fi

    echo ""
    echo "Suggested Next Edits"
    echo "--------------------"
    echo "1. If compilation failed, fix the first error shown in build.log first. Later errors may be side effects."
    echo "2. If tests failed, open StudentManagerTest.java and find the failed test method name."
    echo "3. If Jenkins cannot send email, configure Jenkins SMTP settings, then rebuild."
    echo ""

    if [ -f "${BUILD_LOG}" ]; then
        echo "Build Log Tail"
        echo "--------------"
        tail -n 80 "${BUILD_LOG}"
        echo ""
    fi

    if [ -f "${TEST_LOG}" ]; then
        echo "Test Log Tail"
        echo "-------------"
        tail -n 120 "${TEST_LOG}"
        echo ""
    fi
} > "${ANALYSIS_FILE}"

cat "${ANALYSIS_FILE}"
