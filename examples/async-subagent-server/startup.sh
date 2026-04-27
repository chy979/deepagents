#!/bin/bash
# =============================================================================
# startup.sh — container entrypoint for async-subagent-server
#
# 1. If the ACS Agent Sandbox has injected the envd runtime (via the
#    agent-runtime init container), start it in the background so that
#    the E2B files / commands APIs remain functional.
# 2. Start the FastAPI server with uvicorn on PORT (default 2024).
# =============================================================================

set -euo pipefail

ENVD_SCRIPT="/mnt/envd/envd-run.sh"
PORT="${PORT:-2024}"

# ── Start ACS envd runtime if available ──────────────────────────────────────
if [ -f "${ENVD_SCRIPT}" ]; then
    echo "[startup] ACS agent-runtime detected — starting envd..."
    /bin/bash "${ENVD_SCRIPT}" &
    # Give envd a moment to bind its socket before the main process starts.
    sleep 2
    echo "[startup] envd started (PID $!)"
else
    echo "[startup] No ACS agent-runtime found — skipping envd (standalone mode)."
fi

# ── Start the FastAPI server ──────────────────────────────────────────────────
echo "[startup] Starting async-subagent-server on 0.0.0.0:${PORT} ..."
exec uvicorn server:app \
    --host 0.0.0.0 \
    --port "${PORT}" \
    --log-level info
