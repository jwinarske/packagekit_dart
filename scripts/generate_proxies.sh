#!/usr/bin/env bash
# Regenerate sdbus-cpp proxy headers from PackageKit D-Bus XML files.
# Mirrors jwinarske/sdbus-cpp-examples generate.sh pattern.
set -euo pipefail

# Use sdbus-c++-xml2cpp built from the submodule.
# Build once first: cmake --build build --target sdbus-c++-xml2cpp
TOOLS="${SDBUS_XML2CPP:-./build/third_party/sdbus-cpp/tools/sdbus-c++-xml2cpp}"
OUT="native/generated"
XML="interfaces"

which "$TOOLS" &>/dev/null || {
    echo "ERROR: $TOOLS not found. Build the project once first, or set SDBUS_XML2CPP."
    exit 1
}

mkdir -p "$OUT"

echo "Generating PackageKit manager proxy..."
"$TOOLS" "$XML/org.freedesktop.PackageKit.xml" \
    --proxy="$OUT/pk_manager_proxy.h"

echo "Generating PackageKit transaction proxy..."
"$TOOLS" "$XML/org.freedesktop.PackageKit.Transaction.xml" \
    --proxy="$OUT/pk_transaction_proxy.h"

echo "Generating PackageKit offline proxy..."
"$TOOLS" "$XML/org.freedesktop.PackageKit.Offline.xml" \
    --proxy="$OUT/pk_offline_proxy.h"

echo "Done → $OUT/"
echo ""
echo "If you changed sdbus-cpp version, check for API differences in the"
echo "generated headers and update pk_manager.cpp / pk_transaction.cpp."
