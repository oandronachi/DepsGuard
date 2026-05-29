# Containerised DepsGuard MCP server.
# Build:  docker build -t depsguard .
# Build with examples: docker build --build-arg INSTALL_EXAMPLES=true -t depsguard:examples .
# Run  :  docker run -i --rm depsguard      (-i is required: MCP speaks over stdio)
FROM python:3.12.13-slim

COPY --from=ghcr.io/astral-sh/uv:0.11.17 /uv /uvx /bin/

WORKDIR /app
ARG INSTALL_EXAMPLES=false
ENV UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy

COPY pyproject.toml uv.lock README.md .python-version SKILL.md ./
COPY depsguard ./depsguard
COPY evals ./evals
COPY examples ./examples
RUN if [ "$INSTALL_EXAMPLES" = "true" ]; then \
        uv sync --locked --no-dev --no-editable --python 3.12 --extra examples; \
    else \
        uv sync --locked --no-dev --no-editable --python 3.12; \
    fi

# Drop root for runtime: the server only needs to read its (world-readable) venv,
# so an unprivileged user suffices (defense-in-depth for a security-facing tool).
RUN useradd --uid 10001 app
USER app

# stdio transport — the MCP client attaches to this process's stdin/stdout.
ENTRYPOINT ["/app/.venv/bin/depsguard"]
