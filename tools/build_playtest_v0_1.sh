#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="0.1.0"
EXPORT_ROOT="$PROJECT_DIR/exports"
WINDOWS_DIR="$EXPORT_ROOT/HoshimiHospital-v0.1-Windows"
WINDOWS_ZIP="$EXPORT_ROOT/HoshimiHospital-v0.1-Windows.zip"
MACOS_ZIP="$EXPORT_ROOT/HoshimiHospital-v0.1-macOS.zip"

if [[ -n "${GODOT_BIN:-}" ]]; then
  GODOT="$GODOT_BIN"
elif [[ -x "/Applications/Godot.app/Contents/MacOS/Godot" ]]; then
  GODOT="/Applications/Godot.app/Contents/MacOS/Godot"
elif command -v godot >/dev/null 2>&1; then
  GODOT="$(command -v godot)"
else
  echo "找不到 Godot。请设置 GODOT_BIN=/path/to/Godot 后重试。" >&2
  exit 1
fi

mkdir -p "$WINDOWS_DIR" "$EXPORT_ROOT"

echo "[1/3] 导出 Windows v$VERSION"
"$GODOT" --headless --path "$PROJECT_DIR" --export-release "Windows Desktop" "$WINDOWS_DIR/HoshimiHospital.exe"

echo "[2/3] 打包 Windows ZIP"
rm -f "$WINDOWS_ZIP"
if command -v ditto >/dev/null 2>&1; then
  ditto -c -k --keepParent "$WINDOWS_DIR" "$WINDOWS_ZIP"
else
  (cd "$EXPORT_ROOT" && zip -qr "$(basename "$WINDOWS_ZIP")" "$(basename "$WINDOWS_DIR")")
fi

echo "[3/3] 导出 macOS v$VERSION"
"$GODOT" --headless --path "$PROJECT_DIR" --export-release "macOS" "$MACOS_ZIP"

echo
echo "完成："
echo "  $WINDOWS_ZIP"
echo "  $MACOS_ZIP"
echo
shasum -a 256 "$WINDOWS_ZIP" "$MACOS_ZIP"
