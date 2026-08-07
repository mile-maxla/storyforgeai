#!/usr/bin/env bash
# Linux/macOS equivalent of run-storyforge-ai.bat.
set -u

cd "$(dirname "$0")" || { echo "Unable to open the launcher directory."; exit 1; }

if [ ! -f "package.json" ]; then
  echo "package.json was not found in \"$PWD\"."
  exit 1
fi

if ! command -v npm >/dev/null 2>&1; then
  echo "npm was not found. Install Node.js 20 or newer and try again."
  exit 1
fi

# package.json requires Node >=20.9.0; distro-packaged Node is often older.
node_ok() {
  command -v node >/dev/null 2>&1 &&
    node -e 'const [a,b]=process.versions.node.split(".").map(Number); process.exit(a>20||(a===20&&b>=9)?0:1)'
}

if ! node_ok && [ -s "$HOME/.nvm/nvm.sh" ]; then
  # shellcheck disable=SC1091
  . "$HOME/.nvm/nvm.sh"
  nvm use default >/dev/null 2>&1 || nvm use --lts >/dev/null 2>&1
fi

if ! node_ok; then
  echo "Node.js $(node --version 2>/dev/null || echo "(none)") is too old. Install Node.js 20.9 or newer and try again."
  exit 1
fi

if [ "${1:-}" = "--check" ]; then
  echo "StoryForgeAI launcher prerequisites are available."
  exit 0
fi

if [ ! -d "node_modules" ]; then
  echo "Installing dependencies..."
  npm ci || { echo; echo "The application could not be started. Review the error above."; exit 1; }
fi

echo "Building StoryForgeAI..."
npm run build || { echo; echo "The build failed. Review the error above."; exit 1; }

echo
echo "Starting StoryForgeAI..."
echo "Local URL: http://127.0.0.1:3200"
echo
echo "StoryForgeAI runs in demo mode unless .env.local enables the integrations"
echo "(WANGP_MCP_ENABLED for generation, AI_PLANNING_ENABLED for the agents)."
echo "Press Ctrl+C to stop the application."
echo
npm start
# Ctrl+C returns a non-zero code here, so this is a stop rather than a failure.
echo
echo "StoryForgeAI has stopped. If that was unexpected, review the output above."
exit 0
