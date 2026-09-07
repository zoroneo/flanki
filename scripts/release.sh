#!/usr/bin/env bash
# ==============================================================================
# Flanki Automated Release Wrapper
# ==============================================================================
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$DIR"

fvm dart run tool/release.dart "$@"
