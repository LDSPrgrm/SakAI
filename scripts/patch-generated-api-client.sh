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
PYTHON_CMD="python"
if python3 --version >/dev/null 2>&1; then
  PYTHON_CMD="python3"
fi
$PYTHON_CMD <<PY
import re
from pathlib import Path

root_str = "${API_ROOT}"
if re.match(r"^/[a-zA-Z]/", root_str):
    root_str = f"{root_str[1]}:{root_str[2:]}"
root = Path(root_str)
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
    text = path.read_text(encoding="utf-8")
    new_text, n = block.subn("\n", text, count=1)
    if n:
        path.write_text(new_text, encoding="utf-8")
        print(f"patched {path.name}")

# Strip bare "//" language version override from first line of all .dart files.
# openapi-generator puts "//\n" on line 1 which Dart interprets as a language
# version override (null), causing mismatch with build_runner-generated .g.dart.
fixed = 0
for p in root.rglob("*.dart"):
    if p.name.endswith(".g.dart"):
        continue
    text = p.read_text(encoding="utf-8")
    if text.startswith("//\r\n"):
        p.write_text(text[4:], encoding="utf-8")
        fixed += 1
    elif text.startswith("//\n"):
        p.write_text(text[3:], encoding="utf-8")
        fixed += 1
if fixed:
    print(f"stripped bare '// ' from {fixed} .dart files")

# Fix missing FullType element type for BuiltList<NearbyDriver> in getNearbyDriversAllTypes.
# The openapi generator emits FullType(BuiltList) without the NearbyDriver parameter,
# causing built_value to throw "Unknown type on deserialization" at runtime.
driver_api = root / "lib" / "src" / "api" / "driver_api.dart"
if driver_api.is_file():
    old = "FullType(BuiltMap, [FullType(String), FullType(BuiltList)])"
    new = "FullType(BuiltMap, [FullType(String), FullType(BuiltList, [FullType(NearbyDriver)])])"
    text = driver_api.read_text(encoding="utf-8")
    if old in text:
        driver_api.write_text(text.replace(old, new), encoding="utf-8")
        print("patched driver_api.dart: BuiltList FullType(NearbyDriver)")

# Fix the serializers.dart builder factory for BuiltMap<String, BuiltList>.
# The codegen registers a raw MapBuilder<String, BuiltList> factory which matches
# ANY BuiltMap<String, BuiltList<X>> lookup and produces BuiltList<dynamic>,
# causing a runtime type cast failure. Replace it with the fully-typed factory
# and add the companion BuiltList<NearbyDriver> factory.
serializers = root / "lib" / "src" / "serializers.dart"
if serializers.is_file():
    text = serializers.read_text(encoding="utf-8")
    old_factory = (
        "      ..addBuilderFactory(\n"
        "        const FullType(BuiltMap, [FullType(String), FullType(BuiltList)]),\n"
        "        () => MapBuilder<String, BuiltList>(),\n"
        "      )"
    )
    new_factory = (
        "      ..addBuilderFactory(\n"
        "        const FullType(BuiltMap, [FullType(String), FullType(BuiltList, [FullType(NearbyDriver)])]),\n"
        "        () => MapBuilder<String, BuiltList<NearbyDriver>>(),\n"
        "      )\n"
        "      ..addBuilderFactory(\n"
        "        const FullType(BuiltList, [FullType(NearbyDriver)]),\n"
        "        () => ListBuilder<NearbyDriver>(),\n"
        "      )"
    )
    if old_factory in text:
        serializers.write_text(text.replace(old_factory, new_factory), encoding="utf-8")
        print("patched serializers.dart: BuiltMap<String, BuiltList<NearbyDriver>> factory")
PY
