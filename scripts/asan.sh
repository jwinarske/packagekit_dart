#!/usr/bin/env bash
# Build and test with AddressSanitizer + UndefinedBehaviorSanitizer.
# Usage: ./scripts/asan.sh [build-dir]
set -euo pipefail

BUILD_DIR="${1:-build-asan}"

cmake -B "$BUILD_DIR" native/ -GNinja \
    -DCMAKE_BUILD_TYPE=Debug \
    -DCMAKE_CXX_COMPILER=clang++-19 \
    -DCMAKE_C_COMPILER=clang-19 \
    -DENABLE_ASAN=ON \
    -DENABLE_UBSAN=ON \
    -DBUILD_TESTING=ON

cmake --build "$BUILD_DIR" --parallel

echo "Running tests under ASAN + UBSan..."
ctest --test-dir "$BUILD_DIR/test" --output-on-failure -j4
echo "ASAN + UBSan: all tests passed."
