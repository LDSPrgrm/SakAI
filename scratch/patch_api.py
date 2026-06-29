import re
from pathlib import Path

api_root = Path("mobile/shared/lib/api_client")

# 1. Patch pubspec.yaml
pubspec = api_root / "pubspec.yaml"
if pubspec.exists():
    text = pubspec.read_text()
    new_text = text.replace("sdk: '>=2.18.0 <4.0.0'", "sdk: ^3.10.0")
    if new_text != text:
        pubspec.write_text(new_text)
        print("patched pubspec.yaml sdk constraint")

# 2. Patch models
model_dir = api_root / "lib" / "src" / "model"
if model_dir.is_dir():
    block = re.compile(
        r"\n/// Optionally, enum_class.*?"
        r"\nabstract class \w+Mixin = Object with _\$\w+Mixin;\n*",
        re.DOTALL,
    )

    for name in ("error_code.dart", "ride_status.dart"):
        path = model_dir / name
        if not path.is_file():
            continue
        text = path.read_text()
        new_text, n = block.subn("\n", text, count=1)
        if n:
            path.write_text(new_text)
            print(f"patched {path.name}")

# 3. Strip bare //
fixed = 0
for p in api_root.rglob("*.dart"):
    if p.name.endswith(".g.dart"):
        continue
    text = p.read_text()
    if text.startswith("//\r\n"):
        p.write_text(text[4:], encoding="utf-8")
        fixed += 1
    elif text.startswith("//\n"):
        p.write_text(text[3:], encoding="utf-8")
        fixed += 1
if fixed:
    print(f"stripped bare '//' from {fixed} .dart files")
