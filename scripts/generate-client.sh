#!/usr/bin/env bash
# Regenerate the Dart (dio) API client from openapi/swagger.yaml.
# Requires Java 11+ for openapi-generator-cli, or Docker.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SPEC="${ROOT}/openapi/swagger.yaml"
OUT="${ROOT}/mobile/shared/lib/api_client"

if [[ ! -f "${SPEC}" ]]; then
  echo "error: missing ${SPEC}" >&2
  exit 1
fi

GEN_FLAGS=(
  generate
  -i "${SPEC}"
  -g dart-dio
  -o "${OUT}"
  --additional-properties=pubName=sakai_api_client,nullableFields=true
)

run_cli() {
  command -v openapi-generator-cli >/dev/null 2>&1 &&
    openapi-generator-cli "${GEN_FLAGS[@]}"
}

run_npx() {
  command -v npx >/dev/null 2>&1 &&
    npx --yes @openapitools/openapi-generator-cli "${GEN_FLAGS[@]}"
}

run_docker() {
  command -v docker >/dev/null 2>&1 &&
    docker run --rm \
      -v "${ROOT}:/local" \
      -w /local \
      openapitools/openapi-generator-cli:v7.10.0 \
      generate \
      -i /local/openapi/swagger.yaml \
      -g dart-dio \
      -o /local/mobile/shared/lib/api_client \
      --additional-properties=pubName=sakai_api_client,nullableFields=true
}

if run_cli; then
  echo "Generated via openapi-generator-cli"
elif run_npx; then
  echo "Generated via npx @openapitools/openapi-generator-cli"
elif run_docker; then
  echo "Generated via Docker openapitools/openapi-generator-cli:v7.10.0"
else
  echo "error: install openapi-generator-cli, or use npx/docker." >&2
  exit 1
fi

echo "Output: ${OUT}"

"${ROOT}/scripts/patch-generated-api-client.sh" "${OUT}"

echo "Running built_value codegen (build_runner)..."
( cd "${ROOT}/mobile/shared/lib/api_client" && dart pub get && dart run build_runner build --delete-conflicting-outputs )

echo "Done. Next: cd mobile/shared && flutter pub get"
