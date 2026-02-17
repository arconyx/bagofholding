#!/usr/bin/env bash

# patch_from_env.sh TARGET_DIR
# Patches files in TARGET_DIR to replace sentinel values
# with values from environment variables. Point at the
# built code.

set -euxo pipefail

BASE_PATH="${BASE_PATGH:-}"

# Patch special values in JS
sed --in-place "s|SUBSTITUTE_BASE_PATH|${BASE_PATH}|g" "$1"/bagofholding.js
sed --in-place "s|SUBSTITUTE_PUBLIC_SUPABASE_URL|${PUBLIC_SUPABASE_URL}|g" "$1/bagofholding.js"
sed --in-place "s|SUBSTITUTE_PUBLIC_SUPABASE_KEY|${PUBLIC_SUPABASE_KEY}|g" "$1/bagofholding.js"

# Patch absolute paths in index.html
# I really wish lustre had an option for this
sed --in-place "s|/bagofholding.css|/${BASE_PATH}/bagofholding.css|" "$1/index.html"
sed --in-place "s|/bagofholding.js|/${BASE_PATH}/bagofholding.js|" "$1/index.html"
