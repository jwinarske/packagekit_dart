#!/usr/bin/env bash
# Run clang-format on all native C/C++ sources.
# Usage: ./scripts/clang_format.sh [check|fix]
#   check — dry-run, exit 1 on diff (CI mode)
#   fix   — format in-place (default)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
NATIVE_DIR="$ROOT_DIR/native"

CLANG_FORMAT="${CLANG_FORMAT:-$(command -v clang-format-19 2>/dev/null || command -v clang-format)}"

if [[ -z "$CLANG_FORMAT" ]]; then
    echo "ERROR: clang-format not found"
    exit 1
fi

# Collect all C/C++ sources under native/
FILES=()
while IFS= read -r -d '' f; do
    FILES+=("$f")
done < <(find "$NATIVE_DIR" \( -name '*.h' -o -name '*.cpp' -o -name '*.c' \) \
    -not -path '*/third_party/*' -not -path '*/generated/*' -print0)

if [[ ${#FILES[@]} -eq 0 ]]; then
    echo "No source files found — nothing to format."
    exit 0
fi

MODE="${1:-fix}"
case "$MODE" in
    check)
        echo "Checking format (${#FILES[@]} files)..."
        "$CLANG_FORMAT" --dry-run --Werror "${FILES[@]}"
        echo "Format OK."
        ;;
    fix)
        echo "Formatting ${#FILES[@]} files..."
        "$CLANG_FORMAT" -i "${FILES[@]}"
        echo "Done."
        ;;
    *)
        echo "Usage: $0 [check|fix]"
        exit 1
        ;;
esac
