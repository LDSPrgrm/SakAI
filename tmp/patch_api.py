import re
from pathlib import Path
import sys

def patch_api_client(api_root):
    root = Path(api_root)
    model_dir = root / "lib" / "src" / "model"
    if not model_dir.is_dir():
        print(f"Error: missing {model_dir}")
        return

    block = re.compile(
        r"\n/// Optionally, enum_class.*?"
        r"\nabstract class \w+Mixin = Object with _\$\w+Mixin;\n*",
        re.DOTALL,
    )

    for name in ("error_code.dart", "ride_status.dart"):
        path = model_dir / name
        if not path.is_file():
            continue
        text = path.read_text(encoding="utf-8")
        new_text, n = block.subn("\n", text, count=1)
        if n:
            path.write_text(new_text, encoding="utf-8")
            print(f"patched {path.name}")

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
        print("Usage: python patch_api.py <api_client_dir>")
        sys.exit(1)
    patch_api_client(sys.argv[1])
