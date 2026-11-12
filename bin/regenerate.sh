#!/usr/bin/env bash
# Regenerates the GPCCMP suite from the gpccmp-fhir-ig submodule: builds the IG
# archive, generates the suite from it and lints the result.
#
# A build whose archive is not in HEAD's lib/gpccmp_test_kit/igs/ is a new
# IG version: it replaces the previous archive and generated suite, and
# config.json, lib/gpccmp_test_kit.rb and the outer groups are pointed at the new
# version. The kit carries one suite, the one for the IG's master branch (the ci-build).
#
# Prints, and writes to $GITHUB_OUTPUT when set:
#   status            new | changed | unchanged
#   version           the IG version the suite was generated for, e.g. 0.1.0-ci-build
#   previous_version  the version config.json named before this run
#   ig_commit         the gpccmp-fhir-ig commit the IG was built from
#   previous_ig_commit the gpccmp-fhir-ig commit recorded in HEAD
# "changed" means the submodule commit or the generated suite differs from HEAD.
# On "unchanged" the rebuilt archive is discarded, so the working tree is clean.
#
# Usage:
#   ./bin/regenerate.sh                 rebuild the pinned IG commit
#   IG_REF=master ./bin/regenerate.sh   move the submodule to a ref first
#   RUNNER=local ./bin/regenerate.sh    generate with local Ruby instead of Docker
# RUNNER and STACK reach `make generate` through the environment; see the Makefile.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "${ROOT_DIR}"

IG_SUBMODULE="gpccmp-fhir-ig"
IGS_DIR="lib/gpccmp_test_kit/igs"
GENERATED_DIR="lib/gpccmp_test_kit/generated"
OUTER_GROUPS_DIR="lib/gpccmp_test_kit/outer_groups"
ENTRY_FILE="lib/gpccmp_test_kit.rb"
CONFIG_FILE="config.json"
IG_REF="${IG_REF:-}"

if [ ! -f "${IG_SUBMODULE}/sushi-config.yaml" ]; then
  echo "IG sources not found in ${IG_SUBMODULE}. Run: git submodule update --init" >&2
  exit 1
fi

if [ -n "${IG_REF}" ]; then
  echo "Moving ${IG_SUBMODULE} to ${IG_REF}"
  git -C "${IG_SUBMODULE}" fetch --quiet origin "${IG_REF}"
  git -C "${IG_SUBMODULE}" checkout --quiet --detach FETCH_HEAD
fi

PREVIOUS_VERSION="$(sed -nE 's/^[[:space:]]*"package_archive_path"[[:space:]]*:[[:space:]]*".*\/([^/"]+)\.tgz".*/\1/p' "${CONFIG_FILE}")"
if [ -z "${PREVIOUS_VERSION}" ]; then
  echo "Could not read ig.package_archive_path from ${CONFIG_FILE}" >&2
  exit 1
fi

ARCHIVE_LINE="$(./bin/build_ig.sh | tee /dev/stderr | tail -n 1)"
VERSION="$(basename "${ARCHIVE_LINE#IG archive: }" .tgz)"
ARCHIVE="${IGS_DIR}/${VERSION}.tgz"
if [ ! -f "${ARCHIVE}" ]; then
  echo "bin/build_ig.sh did not report an archive in ${IGS_DIR} (got: ${ARCHIVE_LINE})" >&2
  exit 1
fi

if ! git cat-file -e "HEAD:${ARCHIVE}" 2>/dev/null && [ "${VERSION}" != "${PREVIOUS_VERSION}" ]; then
  STATUS="new"
  echo "New IG version ${VERSION} replaces ${PREVIOUS_VERSION}"
  rm -f "${IGS_DIR}/${PREVIOUS_VERSION}.tgz"
  rm -rf "${GENERATED_DIR:?}/v${PREVIOUS_VERSION}"
  OLD="${PREVIOUS_VERSION}" NEW="${VERSION}" perl -pi -e 's/\Q$ENV{OLD}\E/$ENV{NEW}/g' "${CONFIG_FILE}" "${ENTRY_FILE}"
  # The generator namespaces a suite by its version (0.1.0-ci-build -> GPCCMPV010_CI_BUILD);
  # the outer groups share that namespace.
  OLD="${PREVIOUS_VERSION}" NEW="${VERSION}" perl -pi -e '
    BEGIN { sub ns { my $v = uc shift; $v =~ s/\.//g; $v =~ s/-/_/g; "GPCCMPV$v" } }
    s/\b\Q@{[ns($ENV{OLD})]}\E\b/@{[ns($ENV{NEW})]}/g' "${OUTER_GROUPS_DIR}"/*.rb
else
  STATUS=""
fi

make --no-print-directory generate

if [ -z "${STATUS}" ]; then
  if ! git diff --quiet --ignore-submodules=dirty HEAD -- "${IG_SUBMODULE}" \
    || [ -n "$(git status --porcelain -- "${GENERATED_DIR}")" ]; then
    STATUS="changed"
  else
    STATUS="unchanged"
    git restore --source=HEAD --worktree -- "${ARCHIVE}"
  fi
fi

IG_COMMIT="$(git -C "${IG_SUBMODULE}" rev-parse --short HEAD)"
PREVIOUS_IG_COMMIT="$(git rev-parse --short "HEAD:${IG_SUBMODULE}")"

{
  echo "status=${STATUS}"
  echo "version=${VERSION}"
  echo "previous_version=${PREVIOUS_VERSION}"
  echo "ig_commit=${IG_COMMIT}"
  echo "previous_ig_commit=${PREVIOUS_IG_COMMIT}"
} | tee -a "${GITHUB_OUTPUT:-/dev/null}"
