#!/usr/bin/env bash
set -euo pipefail

# Simple Debian package builder for `compress`.
# Usage: bash package_deb.sh [project_root]

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

PKGDIR="$TMPDIR/package"
mkdir -p "$PKGDIR/DEBIAN" "$PKGDIR/usr/local/bin" "$PKGDIR/usr/local/share/compress/assets"

cp "$BIN" "$PKGDIR/usr/local/bin/compress"
chmod 755 "$PKGDIR/usr/local/bin/compress"

# copy embedded assets (prefer rsync, fallback to cp)
if [ -d "$PROJECT_ROOT/assets" ]; then
  if command -v rsync >/dev/null 2>&1; then
    rsync -a --exclude='*.tar.*' --exclude='*.tar.xz' "$PROJECT_ROOT/assets/" "$PKGDIR/usr/local/share/compress/assets/" || true
  else
    cp -a "$PROJECT_ROOT/assets/." "$PKGDIR/usr/local/share/compress/assets/" || true
  fi
fi

# derive version from Cargo.toml
VERSION="$(awk -F'=' '/^version/ {gsub(/ /,""); gsub(/\"/,""); print $2; exit}' Cargo.toml || true)"
if [ -z "$VERSION" ]; then
  VERSION="0.0.0-$(date -u +%Y%m%dT%H%M%SZ)"
fi

# determine architecture
ARCH="$(dpkg --print-architecture 2>/dev/null || echo "amd64")"

MAINT="$(whoami)@$(hostname)"

cat > "$PKGDIR/DEBIAN/control" <<EOF
Package: compress
Version: $VERSION
Section: utils
Priority: optional
Architecture: $ARCH
Maintainer: $MAINT
Description: compress - encrypted file packer using embedded 7z
 A small tool that bundles an embedded 7-Zip binary and provides
 simple encrypt/compress and decrypt/extract commands.
EOF

chmod 644 "$PKGDIR/DEBIAN/control"

OUTDEB="$PROJECT_ROOT/compress_${VERSION}_${ARCH}.deb"

echo "Building .deb -> $OUTDEB"
if ! command -v dpkg-deb >/dev/null 2>&1; then
  echo "Error: dpkg-deb not found. Install dpkg-deb (Debian/Ubuntu) or run on a system with dpkg-deb available."
  exit 2
fi

dpkg-deb --build "$PKGDIR" "$OUTDEB"

echo "Package created: $OUTDEB"
