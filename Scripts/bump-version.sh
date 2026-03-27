#!/bin/bash
set -euo pipefail

VERSION="${1:-}"

if [[ -z "$VERSION" ]]; then
  echo "Usage: bump-version.sh <version>"
  echo "Example: bump-version.sh 1.2.0"
  exit 1
fi

if [[ ! "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Error: Version must be semver (e.g., 1.2.3), got: $VERSION"
  exit 1
fi

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# Bump podspec version
sed -i '' "s/s\.version[[:space:]]*=[[:space:]]*\"[^\"]*\"/s.version          = \"${VERSION}\"/" \
  "$REPO_ROOT/mParticle-Mixpanel.podspec"

# Bump Version.swift
sed -i '' "s/moduleVersion = \"[^\"]*\"/moduleVersion = \"${VERSION}\"/" \
  "$REPO_ROOT/Sources/mParticle-Mixpanel/MPKitMixpanel+Version.swift"

echo "Version bumped to $VERSION"
grep "s.version" "$REPO_ROOT/mParticle-Mixpanel.podspec" | head -1
grep "moduleVersion" "$REPO_ROOT/Sources/mParticle-Mixpanel/MPKitMixpanel+Version.swift"
