#!/usr/bin/env bash
# =============================================================================
# LRLayout test runner.
# -----------------------------------------------------------------------------
# 1. Rebuild dist/ from src/ (tests link the real artifact).
# 2. Load each test page in headless Chromium and dump the post-layout DOM.
# 3. Parse the runner's "RESULT: PASS=n FAIL=m" line into an exit code.
#
# Zero dependencies: global `sass` plus whatever Chromium-family browser the
# machine already has. No node, no node_modules, no Puppeteer.
#
# Browser is auto-detected (see pick_browser). Override on any machine with:
#   CHROME_BIN=/path/to/chrome bash test/run.sh
# =============================================================================
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

PAGES=("test/layout.html" "test/primitives.html" "test/modifiers.html")

# --- Browser detection -------------------------------------------------------
# Sets MODE (bin|flatpak) and BROWSER. `bin` covers a real Chrome/Chromium/Edge/
# Brave executable (Linux PATH, macOS app bundle, or $CHROME_BIN). `flatpak`
# covers the sandboxed Chromium, which needs the run/--filesystem wrapper.
pick_browser() {
  local cand
  # 1. Explicit override always wins.
  if [[ -n "${CHROME_BIN:-}" ]]; then MODE=bin; BROWSER="$CHROME_BIN"; return; fi
  # 2. A normal executable on PATH.
  for cand in google-chrome google-chrome-stable chromium chromium-browser \
              chrome microsoft-edge microsoft-edge-stable brave-browser; do
    if command -v "$cand" >/dev/null 2>&1; then MODE=bin; BROWSER="$cand"; return; fi
  done
  # 3. macOS app bundles (no PATH entry by default).
  for cand in \
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
    "/Applications/Chromium.app/Contents/MacOS/Chromium" \
    "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge" \
    "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser"; do
    if [[ -x "$cand" ]]; then MODE=bin; BROWSER="$cand"; return; fi
  done
  # 4. Flatpak Chromium (this repo's original setup).
  if command -v flatpak >/dev/null 2>&1 && \
     flatpak info org.chromium.Chromium >/dev/null 2>&1; then
    MODE=flatpak; BROWSER=org.chromium.Chromium; return
  fi
  echo "ERROR: no Chromium-family browser found. Install Chrome/Chromium, or set" >&2
  echo "       CHROME_BIN=/path/to/chrome before running." >&2
  exit 127
}

# Print the post-layout DOM of a file:// page, browser-launcher abstracted away.
# Common headless flags are identical across every Chromium-family binary.
render_dom() {
  local url="$1"
  local flags=(--headless=new --disable-gpu --no-sandbox \
               --virtual-time-budget=2000 --dump-dom "$url")
  if [[ "$MODE" == flatpak ]]; then
    flatpak run --filesystem="$ROOT" "$BROWSER" "${flags[@]}" 2>/dev/null
  else
    "$BROWSER" "${flags[@]}" 2>/dev/null
  fi
}

pick_browser
echo "browser: $BROWSER ($MODE)"

echo "building dist/lrlayout.css…"
sass src/lrlayout.scss dist/lrlayout.css --no-source-map --style=expanded

fail_total=0
for page in "${PAGES[@]}"; do
  echo "── $page ─────────────────────────────────────────────"
  dom="$(render_dom "file://$ROOT/$page")"

  # Per-case lines (ok/FAIL) and the summary, pulled straight from the dumped DOM.
  echo "$dom" | grep -Eo '(ok  |FAIL): [^<]+' || true
  summary="$(echo "$dom" | grep -Eo 'RESULT: PASS=[0-9]+ FAIL=[0-9]+' | head -n1 || true)"

  if [[ -z "$summary" ]]; then
    echo "ERROR: no RESULT line — page errored before tests ran." >&2
    fail_total=$((fail_total + 1))
    continue
  fi
  echo "$summary"
  fails="$(echo "$summary" | sed -E 's/.*FAIL=([0-9]+).*/\1/')"
  fail_total=$((fail_total + fails))
done

echo "──────────────────────────────────────────────────────"
if [[ "$fail_total" -gt 0 ]]; then
  echo "SUITE FAILED ($fail_total failing)"; exit 1
fi
echo "SUITE PASSED"
