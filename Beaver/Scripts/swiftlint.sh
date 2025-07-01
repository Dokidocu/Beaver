#!/bin/bash

# SwiftLint Integration Script for Beaver Framework
# This script ensures SwiftLint runs properly during Xcode builds

set -e

# Check if SwiftLint is installed
if ! command -v swiftlint &> /dev/null; then
    echo "warning: SwiftLint not installed. Install with: brew install swiftlint"
    exit 0
fi

# Change to source root directory
cd "${SRCROOT:-$(pwd)}"

# Create a basic SwiftLint config if it doesn't exist
if [ ! -f ".swiftlint.yml" ]; then
    echo "warning: .swiftlint.yml not found, using default configuration"
fi

# Run SwiftLint with error handling
echo "Running SwiftLint..."
if swiftlint lint --quiet 2>/dev/null; then
    echo "✅ SwiftLint: No violations found"
else
    # If strict mode fails, try without it and show warnings
    echo "⚠️  SwiftLint found violations"
    swiftlint lint --quiet || true
fi

echo "SwiftLint check completed"
