#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

chmod +x .githooks/pre-add-build .githooks/pre-commit scripts/*.sh build.sh package.sh install.sh 2>/dev/null || true

git config core.hooksPath .githooks
git config alias.add "!${ROOT}/.githooks/pre-add-build"

echo "Git hooks installed."
echo "  core.hooksPath = .githooks"
echo "  alias.add      = pre-add-build wrapper (rebuilds .dmg before staging)"
echo ""
echo "Use \\git add to bypass the alias and rely on pre-commit instead."
