# =============================================================================
# Dockerfile for async-subagent-server
#
# Build context MUST be the project root (deepagents/):
#   docker build -f examples/async-subagent-server/Dockerfile -t <image> .
#
# The image embeds the local libs/deepagents library so it can be built
# without publishing the package to PyPI.
# =============================================================================

FROM python:3.11-slim

# ── System dependencies ───────────────────────────────────────────────────────
# bash + coreutils (cp/mv/mkdir) are required by the ACS Agent Sandbox runtime.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        bash \
        coreutils \
        curl \
    && rm -rf /var/lib/apt/lists/*

# ── Copy & install local deepagents library ───────────────────────────────────
WORKDIR /opt/deepagents
COPY libs/deepagents /opt/deepagents
RUN pip install --no-cache-dir -e .

# ── Copy & install server ─────────────────────────────────────────────────────
WORKDIR /app
COPY examples/async-subagent-server /app

# Override the local-path source so uv / pip resolves deepagents from the
# already-installed editable package rather than the path reference in
# pyproject.toml (which doesn't exist inside the container).
RUN pip install --no-cache-dir \
        "fastapi>=0.115.0" \
        "uvicorn[standard]>=0.30.0" \
        "langchain-anthropic>=0.3.0" \
        "langgraph>=0.2.0" \
        "langgraph-sdk>=0.1.0" \
        "httpx>=0.28.0" \
        "python-dotenv>=1.0.0"

# ── Startup script ────────────────────────────────────────────────────────────
COPY examples/async-subagent-server/startup.sh /startup.sh
RUN chmod +x /startup.sh

EXPOSE 2024

# Environment defaults (override at runtime or via .env file / E2B env_vars)
ENV PORT=2024
ENV PYTHONUNBUFFERED=1

CMD ["/startup.sh"]
