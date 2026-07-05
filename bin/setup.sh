#!/bin/sh
# Runs the Inferno suite configuration wizard inside the official Ruby image
# from Docker Hub — no local Ruby or Bundler installation required.
#
# Usage:
#   ./bin/setup.sh            — interactive wizard
#   ./bin/setup.sh --dry-run  — preview changes without writing files
set -e

RUBY_IMAGE="ruby:3.3.6"
GEM_CACHE_VOLUME="inferno-suite-wizard-gems"

exec docker run --rm -it \
  -v "$(pwd):/app" \
  -v "${GEM_CACHE_VOLUME}:/usr/local/bundle" \
  -w /app \
  "${RUBY_IMAGE}" \
  sh -c 'gem install thor --no-document --quiet && ruby bin/wizard "$@"' _ "$@"
