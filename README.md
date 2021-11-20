# Grapl Release Buildkite Plugin

Consolidates logic around release creation and tagging for Grapl's pipelines.

This is explicitly tailored for Grapl's needs, and is not intended for
general usage.

## "Library" Plugin

This plugin is currently structured as a ["library
plugin"](https://github.com/buildkite-plugins/library-example-buildkite-plugin). It
provides scripts that are added to the `$PATH` via an `environment`
hook; these scripts can then be used in the job command.

There is no configuration for this plugin; just add it to your
`plugins` list (generally toward the top of that list).

## Usecases

### Record Successful Pipeline Runs

At the end of pipelines, we often record the success by resetting a
lightweight tag; here is how to do that:

```yaml
steps:
  - label: ":writing_hand: Record successful build"
    command:
      - record_successsful_pipeline_run.sh
    plugins:
      - grapl-security/grapl-release#v0.1.0
```

### Diff-based Logic

Often in our `merge` pipelines, we will use the
[chronotc/monorepo-diff](https://github.com/chronotc/monorepo-diff-buildkite-plugin)
plugin to help trigger artifact creation based on whether code has
changed since the last successful `merge` pipeline run. This logic is
based on the aforementioned lightweight tags.

To make this custom diff logic easily available, we use the current
plugin to add the script to the `$PATH`; here is an example of how to
use it:

```yaml
steps:
  - label: ":thinking_face: Build containers?"
    plugins:
      - grapl-security/grapl-release#v0.1.0 # <-- Must come first!
      - chronotc/monorepo-diff#v2.0.4:
          diff: grapl_diff.sh # <-- Comes from this plugin
          watch:
            - path:
                - file1.txt
                - file2.txt
              config:
                label: ":pipeline: Upload pipeline"
                command: "buildkite-agent pipeline upload .buildkite/complicated_pipeline.yml"
```
