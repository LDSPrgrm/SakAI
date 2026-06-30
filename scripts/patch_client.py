import re
from pathlib import Path
import sys

def patch_pubspec(root):
    pubspec = root / "pubspec.yaml"
    if pubspec.exists():
        text = pubspec.read_text()
        new_text = text.replace("sdk: '>=2.18.0 <4.0.0'", "sdk: ^3.10.0")
        if new_text != text:
            pubspec.write_text(new_text)
            print("patched pubspec.yaml sdk constraint")

def patch_models(root):
    model = root / "lib" / "src" / "model"
    if not model.is_dir():
        print(f"warning: missing {model}")
        return

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

def strip_version_override(root):
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

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("usage: python patch_client.py <api_client_dir>")
        sys.exit(1)
    
    root_dir = Path(sys.argv[1])
    patch_pubspec(root_dir)
    patch_models(root_dir)
    strip_version_override(root_dir)
