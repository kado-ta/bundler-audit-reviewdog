#!/bin/sh
set -e

if [ -n "${GITHUB_WORKSPACE}" ]; then
  cd "${GITHUB_WORKSPACE}/${INPUT_WORKDIR}" || exit
fi

REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"
export REVIEWDOG_GITHUB_API_TOKEN

echo '::group:: Installing bundler-audit with extensions ... https://github.com/rubysec/bundler-audit'
# if 'gemfile' bundler-audit version selected
if [ "$INPUT_BUNDLER_AUDIT_VERSION" = "gemfile" ]; then
  # if Gemfile.lock is here
  if [ -f 'Gemfile.lock' ]; then
    # grep for bundler-audit version
    BUNDLER_AUDIT_GEMFILE_VERSION=$(ruby -ne 'print $& if /^\s{4}bundler-audit\s\(\K.*(?=\))/' Gemfile.lock)

    # if bundler-audit version found, then pass it to the gem install
    # left it empty otherwise, so no version will be passed
    if [ -n "$BUNDLER_AUDIT_GEMFILE_VERSION" ]; then
      BUNDLER_AUDIT_VERSION=$BUNDLER_AUDIT_GEMFILE_VERSION
      else
        printf "Cannot get the bundler-audit's version from Gemfile.lock. The latest version will be installed."
    fi
    else
      printf 'Gemfile.lock not found. The latest version will be installed.'
  fi
  else
    # set desired bundler-audit version
    BUNDLER_AUDIT_VERSION=$INPUT_BUNDLER_AUDIT_VERSION
fi

gem install -N bundler-audit --version "${BUNDLER_AUDIT_VERSION}"
echo '::endgroup::'

echo '::group:: Running bundler-audit with reviewdog 🐶 ...'
bundler-audit update

# NOTE: ${INPUT_BUNDLER_AUDIT_FLAGS} の書き方では SC2086 違反を指摘されるが、
# 複数のオプションを文法違反なしに適切に展開する方法が見つからないので SC2086 は無視する。
# shellcheck disable=SC2086
set -- $INPUT_BUNDLER_AUDIT_FLAGS
# shellcheck disable=SC2086
bundler-audit check "$@" --format json |
  tail -n 1 |
  ruby "${GITHUB_ACTION_PATH}"/rdjson_formatter.rb |
  reviewdog -f=rdjson \
    -name="${INPUT_TOOL_NAME}" \
    -reporter="${INPUT_REPORTER}" \
    -filter-mode="${INPUT_FILTER_MODE}" \
    -fail-level="${INPUT_FAIL_LEVEL}" \
    -level="${INPUT_LEVEL}" \
    ${INPUT_REVIEWDOG_FLAGS}

exit_code=$?
echo '::endgroup::'

exit $exit_code
