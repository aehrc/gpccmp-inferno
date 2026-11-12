#!/usr/bin/env bash
# Points the kit at a new IG version. Run from the kit root, after the new version's
# archive is in lib/gpccmp_test_kit/igs/ and before the suite is generated.
#
# The IG version is written down in three files, which are rewritten here:
#   config.json                                ig.version, ig.package_archive_path, suite.rewrite_igs
#   lib/gpccmp_test_kit.rb                      the require of the generated suite
#   resources/init-bundles/gpccmp-package.json  the package Aidbox installs (STACK=aidbox)
# Everything else follows from config.json: the generator names the suite, its namespace
# and its directory after ig.version. The generator would add the new require to
# lib/gpccmp_test_kit.rb by itself, but it would leave the previous one in place.
# The previous version's archive and generated suite are removed.
#
# Usage:
#   ./bin/switch_ig_version.sh <previous-version> <new-version>
set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <previous-version> <new-version>" >&2
  exit 1
fi

OLD="$1"
NEW="$2"
CONFIG_FILE="config.json"
ENTRY_FILE="lib/gpccmp_test_kit.rb"
AIDBOX_BUNDLE="resources/init-bundles/gpccmp-package.json"
IGS_DIR="lib/gpccmp_test_kit/igs"
GENERATED_DIR="lib/gpccmp_test_kit/generated"

if ! grep -qF "\"${OLD}\"" "${CONFIG_FILE}" || ! grep -qF "/${OLD}.tgz" "${CONFIG_FILE}"; then
  echo "${CONFIG_FILE} does not name IG version ${OLD}" >&2
  exit 1
fi

# Only the version field and archive file names: the bare version string can occur in
# unrelated places, such as the version of a ValueSet in the bundle.
OLD="${OLD}" NEW="${NEW}" perl -pi -e '
  s/("version"\s*:\s*")\Q$ENV{OLD}\E"/$1$ENV{NEW}"/;
  s/\/\Q$ENV{OLD}\E\.tgz/\/$ENV{NEW}.tgz/g' "${CONFIG_FILE}"
OLD="${OLD}" NEW="${NEW}" perl -pi -e 's/\/\Q$ENV{OLD}\E\.tgz/\/$ENV{NEW}.tgz/g' "${AIDBOX_BUNDLE}"

OLD="${OLD}" NEW="${NEW}" perl -pi -e 's/\/v\Q$ENV{OLD}\E\//\/v$ENV{NEW}\//g' "${ENTRY_FILE}"

rm -f "${IGS_DIR}/${OLD}.tgz"
rm -rf "${GENERATED_DIR:?}/v${OLD}"
