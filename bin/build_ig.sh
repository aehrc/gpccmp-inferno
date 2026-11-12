#!/bin/sh
# Builds the IG from the gpccmp-fhir-ig submodule inside the official IG
# Publisher image — no local Java, SUSHI or Jekyll installation required — and
# moves the resulting archive to lib/gpccmp_test_kit/igs/<version>-ci-build.tgz,
# replacing any archive of that version. The version comes from the package.json
# inside the archive.
#
# The publisher jar is kept in the submodule's git-ignored input-cache/; delete
# it to pick up a newer release. FHIR packages are cached in ~/.fhir, the same
# place a local IG Publisher run keeps them.
#
# Prints one line on stdout: the path of the archive. The build log goes to stderr.
#
# Usage:
#   ./bin/build_ig.sh
set -eu

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
IG_DIR="${ROOT_DIR}/gpccmp-fhir-ig"
IGS_DIR="${ROOT_DIR}/lib/gpccmp_test_kit/igs"
IG_IMAGE="hl7fhir/ig-publisher-base:latest"
PUBLISHER_URL="https://github.com/HL7/fhir-ig-publisher/releases/latest/download/publisher.jar"
FHIR_CACHE="${HOME}/.fhir"

if [ ! -f "${IG_DIR}/sushi-config.yaml" ]; then
  echo "IG sources not found in ${IG_DIR}. Run: git submodule update --init" >&2
  exit 1
fi

# A failed build must not leave the previous archive looking like its result.
rm -f "${IG_DIR}/output/package.tgz"

mkdir -p "${FHIR_CACHE}"

docker run --rm \
  -v "${IG_DIR}:/home/publisher/ig" \
  -v "${FHIR_CACHE}:/home/publisher/.fhir" \
  -e PUBLISHER_URL="${PUBLISHER_URL}" \
  "${IG_IMAGE}" \
  bash -c '
    set -e
    if [ ! -f input-cache/publisher.jar ]; then
      mkdir -p input-cache
      curl -fsSL "$PUBLISHER_URL" -o input-cache/publisher.jar.tmp
      mv input-cache/publisher.jar.tmp input-cache/publisher.jar
    fi
    bash _genonce.sh
  ' >&2

# The publisher drops this into the IG root, which would mark the submodule dirty.
rm -f "${IG_DIR}/Requirements-fromNarrative.json"

ARCHIVE="${IG_DIR}/output/package.tgz"
if [ ! -f "${ARCHIVE}" ]; then
  echo "IG Publisher did not produce ${ARCHIVE}" >&2
  exit 1
fi

PACKAGE_JSON="$(tar -xzOf "${ARCHIVE}" package/package.json)"
VERSION="$(printf '%s\n' "${PACKAGE_JSON}" \
  | sed -nE 's/^[[:space:]]*"version"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/p' \
  | head -n 1)"
if [ -z "${VERSION}" ]; then
  echo "Could not read the IG version from ${ARCHIVE}" >&2
  exit 1
fi

TARGET="${IGS_DIR}/${VERSION}-ci-build.tgz"
mv -f "${ARCHIVE}" "${TARGET}"
echo "${TARGET}"
