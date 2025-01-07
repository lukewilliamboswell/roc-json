#!/usr/bin/env bash

# https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -euxo pipefail

if [ -z "${ROC:-}" ]; then
  echo "INFO: The ROC environment variable is not set."
  export ROC=$(which roc)
fi

EXAMPLES_DIR='./examples'
PACKAGE_DIR='./package'

# roc check
for ROC_FILE in $EXAMPLES_DIR/*.roc; do
    $ROC check $ROC_FILE
done

# roc build
for ROC_FILE in $EXAMPLES_DIR/*.roc; do
    $ROC build $ROC_FILE --linker=legacy
done

# prep for next step
cd ci/rust_http_server
cargo build --release
cd ../..

# check output
for ROC_FILE in $EXAMPLES_DIR/*.roc; do
    ROC_FILE_ONLY="$(basename "$ROC_FILE")"
    NO_EXT_NAME=${ROC_FILE_ONLY%.*}
    EXAMPLES_DIR="$EXAMPLES_DIR" expect ci/expect_scripts/$NO_EXT_NAME.exp
done

# `roc test` every roc file if it contains a test, skip roc_nightly folder
find . -type d -name "roc_nightly" -prune -o -type f -name "*.roc" -print | while read file; do
    if grep -qE '^\s*expect(\s+|$)' "$file"; then

        # don't exit script if test_command fails
        set +e
        test_command=$($ROC test "$file")
        test_exit_code=$?
        set -e

        if [[ $test_exit_code -ne 0 && $test_exit_code -ne 2 ]]; then
            exit $test_exit_code
        fi
    fi

done

# test building docs website
$ROC docs $PACKAGE_DIR/main.roc
