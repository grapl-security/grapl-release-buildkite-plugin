#!/usr/bin/env bash

# Simple git binary mock that just records its invocations
git() {
    echo "${FUNCNAME[0]} $*" >> "${ALL_COMMANDS}"
}

recorded_commands() {
    if [ -f "${ALL_COMMANDS}" ]; then
        cat "${ALL_COMMANDS}"
    fi
}

oneTimeSetUp() {
    export ALL_COMMANDS="${SHUNIT_TMPDIR}/all_commands"
    # shellcheck source-path=SCRIPTDIR
    source "$(dirname "${BASH_SOURCE[0]}")/record.sh"
}

setUp() {
    # Ensure any recorded commands from the last test are removed so
    # we start with a clean slate.
    rm -f "${ALL_COMMANDS}"
}

test_pipeline_from_env() {
    actual="$(BUILDKITE_PIPELINE_NAME=pipeline-infrastructure/merge pipeline_from_env)"

    assertEquals "Failed to extract a pipeline key from BUILDKITE_PIPELINE_NAME" \
        "merge" \
        "${actual}"
}

test_tag_for_pipeline() {
    assertEquals "internal/last-successful-merge" "$(tag_for_pipeline merge)"
    assertEquals "internal/last-successful-provision" "$(tag_for_pipeline provision)"
}

test_tag_last_success() {

    BUILDKITE_SOURCE=webhook tag_last_success "merge"

    expected=$(
        cat << EOF
git tag internal/last-successful-merge --force
git push origin internal/last-successful-merge --force --verbose
EOF
    )

    assertEquals "The expected git commands were not run" \
        "${expected}" \
        "$(recorded_commands)"
}

test_tag_last_success_with_fake_build() {

    BUILDKITE_SOURCE=ui tag_last_success "provision"

    expected=$(
        cat << EOF
git tag internal/last-successful-provision --force
EOF
    )

    assertEquals "The expected git commands were not run" \
        "${expected}" \
        "$(recorded_commands)"
}

test_tag_last_success_with_fake_build_and_escape_hatch() {

    BREAK_GLASS_IN_CASE_OF_EMERGENCY=1 BUILDKITE_SOURCE=ui tag_last_success "provision"

    expected=$(
        cat << EOF
git tag internal/last-successful-provision --force
git push origin internal/last-successful-provision --force --verbose
EOF
    )

    assertEquals "The expected git commands were not run" \
        "${expected}" \
        "$(recorded_commands)"
}
