import re
from pathlib import Path
import os

api_root = Path(r"e:\Projects\SakAI\mobile\shared\lib\api_client")
pubspec = api_root / "pubspec.yaml"

if pubspec.exists():
    text = pubspec.read_text()
    if "sdk: '>=2.18.0 <4.0.0'" in text:
        text = text.replace("sdk: '>=2.18.0 <4.0.0'", "sdk: ^3.10.0")
        pubspec.write_text(text)
        print("patched pubspec.yaml sdk constraint")

model_dir = api_root / "lib" / "src" / "model"
if not model_dir.is_dir():
    print(f"Error: missing {model_dir}")
else:
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

    fixed = 0
    for p in api_root.rglob("*.dart"):
        if p.name.endswith(".g.dart"):
            continue
        try:
            text = p.read_text(encoding="utf-8")
            if text.startswith("//\r\n"):
                p.write_text(text[4:], encoding="utf-8")
                fixed += 1
            elif text.startswith("//\n"):
                p.write_text(text[3:], encoding="utf-8")
                fixed += 1
        except Exception as e:
            print(f"Error reading {p}: {e}")

    if fixed:
        print(f"stripped bare '// ' from {fixed} .dart files")
