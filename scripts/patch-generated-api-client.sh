#!/usr/bin/env bash
# Post-process openapi-generator dart-dio output for this monorepo (Dart 3.x).
set -euo pipefail

API_ROOT="${1:?usage: patch-generated-api-client.sh <api_client_dir>}"

PUBSPEC="${API_ROOT}/pubspec.yaml"
if [[ -f "${PUBSPEC}" ]]; then
  if grep -q "sdk: '>=2.18.0 <4.0.0'" "${PUBSPEC}"; then
    perl -i -pe "s/sdk: '>=2.18.0 <4.0.0'/sdk: ^3.10.0/" "${PUBSPEC}"
    echo "patched pubspec.yaml sdk constraint"
  fi
fi

python3 <<PY
import re
from pathlib import Path

root = Path("${API_ROOT}")
model = root / "lib" / "src" / "model"
if not model.is_dir():
    raise SystemExit(f"missing {model}")

block = re.compile(
    r"\n/// Optionally, enum_class.*?"
    r"\nabstract class \w+Mixin = Object with _\$\w+Mixin;\n*",
    re.DOTALL,
)

for name in ("error_code.dart", "ride_status.dart"):
    path = model / name
    if not path.is_file():
        continue
    text = path.read_text()
    new_text, n = block.subn("\n", text, count=1)
    if n:
        path.write_text(new_text)
        print(f"patched {path.name}")
PY
