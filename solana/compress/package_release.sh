#!/usr/bin/env bash
set -euo pipefail

# Usage: bash package_release.sh [project_root]
# If no arg, script searches upward from current directory for Cargo.toml.

# find project root by walking up
find_root() {
  dir="${1:-$PWD}"
  while [ "$dir" != "/" ]; do
    if [ -f "$dir/Cargo.toml" ]; then
      printf "%s" "$dir"
      return 0
    fi
    dir="$(dirname "$dir")"
  done
  return 1
}

PROJECT_ARG="${1:-}"
PROJECT_ROOT="$(find_root "$PROJECT_ARG")" || {
  echo "Error: could not find Cargo.toml (pass project root as arg)"
  exit 1
}

echo "Project root: $PROJECT_ROOT"
cd "$PROJECT_ROOT"

echo "Building release..."
cargo build --release

BIN="$PROJECT_ROOT/target/release/compress"
if [ ! -f "$BIN" ]; then
  echo "Error: release binary not found at $BIN"
  exit 1
fi

TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

# layout in temp: bin/ and assets/
mkdir -p "$TMPDIR/bin"
cp "$BIN" "$TMPDIR/bin/"

# copy embedded 7zz if present, prefer executable form
if [ -f "$PROJECT_ROOT/assets/7zz" ]; then
  mkdir -p "$TMPDIR/assets"
  cp "$PROJECT_ROOT/assets/7zz" "$TMPDIR/assets/"
  chmod +x "$TMPDIR/assets/7zz" || true
fi

# also copy other useful assets (skip large archives)
if [ -d "$PROJECT_ROOT/assets" ]; then
  mkdir -p "$TMPDIR/assets"
  rsync -a --exclude='7z*.tar.*' --exclude='*.tar.xz' "$PROJECT_ROOT/assets/" "$TMPDIR/assets/" || true
fi

OUTNAME="$(basename "$PROJECT_ROOT")-release-$(date -u +%Y%m%dT%H%M%SZ).tar.gz"
OUTPATH="$PROJECT_ROOT/$OUTNAME"

echo "Creating package $OUTPATH ..."
tar -C "$TMPDIR" -czf "$OUTPATH" .

echo "Package created: $OUTPATH"
