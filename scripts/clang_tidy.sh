#!/usr/bin/env bash
# Run clang-tidy on all native C++ sources using the compile_commands.json
# from a prior CMake build.
# Usage: ./scripts/clang_tidy.sh <build-dir>
set -euo pipefail

BUILD_DIR="${1:?Usage: $0 <build-dir>}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
NATIVE_DIR="$ROOT_DIR/native"

CLANG_TIDY="${CLANG_TIDY:-$(command -v clang-tidy-19 2>/dev/null || command -v clang-tidy)}"

if [[ -z "$CLANG_TIDY" ]]; then
    echo "ERROR: clang-tidy not found"
    exit 1
fi

if [[ ! -f "$BUILD_DIR/compile_commands.json" ]]; then
    echo "ERROR: $BUILD_DIR/compile_commands.json not found."
    echo "Build the project first with CMAKE_EXPORT_COMPILE_COMMANDS=ON."
    exit 1
fi

# Collect all C++ sources under native/ (skip third_party and generated).
FILES=()
while IFS= read -r -d '' f; do
    FILES+=("$f")
done < <(find "$NATIVE_DIR" \( -name '*.cpp' -o -name '*.h' \) \
    -not -path '*/third_party/*' -not -path '*/generated/*' -print0)

if [[ ${#FILES[@]} -eq 0 ]]; then
    echo "No source files found."
    exit 0
fi

echo "Running clang-tidy on ${#FILES[@]} files..."
"$CLANG_TIDY" -p "$BUILD_DIR" "${FILES[@]}"
echo "clang-tidy: all checks passed."
