#!/usr/bin/env bash
set -euo pipefail

# WCAG audit driver: serves _site/, runs axe-core (light + dark) and contrast pairs,
# then tears the server down. Run from the project root.

PORT="${PORT:-8080}"
SITE="${SITE:-_site}"

cd "$(dirname "$0")"

if [[ ! -d "../${SITE}" ]]; then
	echo "Error: ${SITE} not found at project root. Run 'quarto render' first." >&2
	exit 1
fi

if [[ ! -d node_modules ]]; then
	echo "Installing audit dependencies..."
	npm install --no-save --silent puppeteer @axe-core/puppeteer axe-core wcag-contrast http-server
fi

echo "Starting static server on :${PORT}..."
npx --yes http-server "../${SITE}" -p "${PORT}" --silent &
SERVER_PID=$!
trap 'kill "${SERVER_PID}" 2>/dev/null || true' EXIT

# Wait for server.
for _ in {1..10}; do
	if curl -fs -o /dev/null "http://localhost:${PORT}/index.html"; then
		break
	fi
	sleep 1
done

echo "Running axe (light)..."
node audit.mjs light

echo "Running axe (dark)..."
node audit.mjs dark

echo "Computing contrast pairs..."
node contrast.mjs >contrast.tsv

echo "Building summary..."
node summarise.mjs >audit-summary.txt

echo
echo "Done. Outputs:"
echo "  audit/audit-light.json"
echo "  audit/audit-dark.json"
echo "  audit/contrast.tsv"
echo "  audit/audit-summary.txt"
