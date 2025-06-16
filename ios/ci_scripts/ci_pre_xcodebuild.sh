#!/bin/sh

# Fail this script if any subcommand fails.
set -e

# Ensure Flutter is in PATH (should have been set up by ci_post_clone.sh)
export PATH="$PATH:$HOME/flutter/bin"

# Run build_runner
dart run build_runner build --delete-conflicting-outputs