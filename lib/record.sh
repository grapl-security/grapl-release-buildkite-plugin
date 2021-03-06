#!/usr/bin/env bash

# shellcheck source-path=SCRIPTDIR
source "$(dirname "${BASH_SOURCE[0]}")/log.sh"
# shellcheck source-path=SCRIPTDIR
source "$(dirname "${BASH_SOURCE[0]}")/util.sh"

# Assuming our pipeline names are of the form of:
#
#     REPOSITORY_NAME/PIPELINE
#
# extracts the PIPELINE portion.
#
#     export BUILDKITE_PIPELINE_NAME=pipeline-infrastructure/merge
#     pipeline_from_env
#     # => merge
#
pipeline_from_env() {
    echo "${BUILDKITE_PIPELINE_NAME##*/}"
}

# The lightweight Git tag we'll use to record which commit was the
# last to successfully make it through the given pipeline. This will
# be updated with every passing pipeline run. As such, it is
# explicitly for internal use, and any dependence on the commit it
# refers to remaining constant is WRONG.
#
#     tag_for_pipeline merge
#     # => internal/last-successful-merge
#
tag_for_pipeline() {
    local -r pipeline="${1}"
    echo "internal/last-successful-${pipeline}"
}

# Update the tag for the given pipeline to the current commit and push
# it to Github.
tag_last_success() {
    local -r pipeline="${1}"
    local -r tag="$(tag_for_pipeline "${pipeline}")"

    echo "--- :github: Re-tagging '${tag}'"
    log_and_run git tag "${tag}" --force

    if is_real_run; then
        echo "--- :github: Pushing new value for '${tag}' tag"
        log_and_run git push origin "${tag}" --force --verbose
    else
        echo -e "--- :no_good: Would have pushed '${tag}' tag to Github"
    fi
}
