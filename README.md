# GitHub Action: Run bundler-audit with reviewdog :dog:

[![Test](https://github.com/kado-ta/bundler-audit-reviewdog/workflows/Test/badge.svg)](https://github.com/kado-ta/bundler-audit-reviewdog/actions?query=workflow%3ATest)
[![reviewdog](https://github.com/kado-ta/bundler-audit-reviewdog/workflows/reviewdog/badge.svg)](https://github.com/kado-ta/bundler-audit-reviewdog/actions?query=workflow%3Areviewdog)
[![depup](https://github.com/kado-ta/bundler-audit-reviewdog/workflows/depup/badge.svg)](https://github.com/kado-ta/bundler-audit-reviewdog/actions?query=workflow%3Adepup)
[![release](https://github.com/kado-ta/bundler-audit-reviewdog/workflows/release/badge.svg)](https://github.com/kado-ta/bundler-audit-reviewdog/actions?query=workflow%3Arelease)
[![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/kado-ta/bundler-audit-reviewdog?logo=github&sort=semver)](https://github.com/kado-ta/bundler-audit-reviewdog/releases)
[![action-bumpr supported](https://img.shields.io/badge/bumpr-supported-ff69b4?logo=github&link=https://github.com/haya14busa/action-bumpr)](https://github.com/haya14busa/action-bumpr)

![Example comment made by the action, with github-pr-review](/.github/images/example-github-pr-review.png)

This action runs [bundler-audit](https://github.com/rubysec/bundler-audit) with
[reviewdog](https://github.com/reviewdog/reviewdog) on pull requests to improve
code review experience.

## Input

### `github_token`

`GITHUB_TOKEN`. Default is `${{ github.token }}`.

For more details about `github.token` context, [click here](https://docs.github.com/ja/actions/writing-workflows/choosing-what-your-workflow-does/accessing-contextual-information-about-workflow-runs#github-context).

### `bundler_audit_version`

Optional. Set bundler-audit version. Possible values:
* empty or omit: install latest version
* `gemfile`: install version from Gemfile (`Gemfile.lock` should be presented, otherwise it will fallback to latest bundler version)
* version (e.g. `1.9.0`): install said version

### `bundler_audit_flags`

Optional. bundler-audit flags. (bundler-audit check --format json `<bundler_audit_flags>`).

### `tool_name`

Optional. Tool name to use for reviewdog reporter. Useful when running multiple
actions with different config.

### `level`

Optional. Report level for reviewdog [`info`, `warning`, `error`].
It's same as `-level` flag of reviewdog.

### `reporter`

Optional. Reporter of reviewdog command [`github-pr-check`, `github-check`, `github-pr-review`].
The default is `github-pr-check`.

### `filter_mode`

Optional. Filtering mode for the reviewdog command [`added`, `diff_context`, `file`, `nofilter`].
Default is `added`.

### `fail_level`

Optional. reviewdog will exit with code 1 with -fail-level=[`any`, `info`, `warning`, `error`] flag 
if it finds at least 1 issue with severity greater than or equal to the given level.
Default is `none`.

### `reviewdog_flags`

Optional. Additional reviewdog flags.

### `workdir`

Optional. The directory from which to look for and run bundler-audit. Default `.`.

## Example usage

```yaml
name: bundler-audit-reviewdog

on: [pull_request]

jobs:
  bundler-audit:
    name: runner / bundler_audit
    runs-on: ubuntu-latest
    steps:
      - name: Check out code
        uses: actions/checkout@v4

      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          bundler-cache: true
          # ruby-version: を指定しない場合、 Ruby のバージョンは .ruby-version から読み取られる。
          # ruby-version: 3.3.5 として指定することも可能。

      - name: Exec bundler-audit
        uses: kado-ta/bundler-audit-reviewdog@v1
        with:
          bundler_audit_version: gemfile
          level: warning
          # Change reviewdog reporter
          # if you need [github-check, github-pr-review, github-pr-check].
          reporter: github-pr-review
```
