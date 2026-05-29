# DepsGuard 🛡️

**An MCP server that gives AI coding assistants the context to make safe dependency decisions** — and a policy guardrail that returns an `ALLOW / WARN / BLOCK` verdict an agent or CI step can act on.

Built for an **AI-native SDLC**: when Claude Code, Cursor, or Copilot is about to add or upgrade a dependency, DepsGuard feeds it decision-grade data from [Google's deps.dev](https://deps.dev) — licenses, source, and the OSV/GHSA security advisories affecting that exact version. Ships with an **agent skill**, an **evaluation harness**, a **Dockerfile**, and **CI**.

Covers 7 ecosystems including the ones automotive/systems software ships in — **Cargo (Rust)** and **Maven (Java/Kotlin)** — plus npm, PyPI, Go, NuGet, RubyGems. **No API key. No account. Free.**

![Python](https://img.shields.io/badge/python-3.10+-blue)
![MCP](https://img.shields.io/badge/MCP-server-7c3aed)
![License](https://img.shields.io/badge/license-MIT-green)

---

## Why this matters for AI-native SDLC

AI coding assistants can add or upgrade dependencies faster than humans can review their security and licensing implications. DepsGuard gives the assistant a structured tool interface and a policy verdict before code is changed.

This project demonstrates:
- MCP tool integration for AI coding assistants
- Context engineering for dependency decisions
- Guardrail-based ALLOW / WARN / BLOCK policy
- Evaluation harness for tool correctness and drift detection
- CI and containerized execution
- Human-readable agent instructions via SKILL.md

## Demo

No demo asset is checked in yet. To exercise the flow manually, connect the
server to an MCP client and ask:

> *"Is urllib3 1.26.4 safe to use? What CVEs affect it?"*

The expected flow is: call `get_version_details`, inspect the advisory IDs, then
call `get_advisory_details` for CVEs and severity.

## What it does

Ask Claude *"is it safe to upgrade to this version?"* and it answers with real advisory data — then gives a verdict it can act on.

| Tool | What it returns |
|------|-----------------|
| `get_package_info(ecosystem, name)` | Version list, latest/default version, publish dates, deprecation flags |
| `get_version_details(ecosystem, name, version)` | Licenses, source repo, and **security advisory IDs** affecting that exact version |
| `get_advisory_details(advisory_id)` | Title, **CVSS severity**, CVE aliases, and a link for an OSV/GHSA advisory |
| `evaluate_dependency_policy(ecosystem, name, version, max_severity)` | **Guardrail:** composes the above into an `ALLOW / WARN / BLOCK` verdict for a dependency add/upgrade |

The intended flow: look up a version → get its advisory IDs → expand severity → or just call the guardrail for a one-shot decision. The bundled [`SKILL.md`](SKILL.md) teaches an agent exactly when and how to chain them.

## Install & run

Requires [`uv`](https://docs.astral.sh/uv/) (recommended) or pip + Python 3.10+.

```bash
git clone https://github.com/oandronachi/DepsGuard.git
cd DepsGuard
uv sync --extra dev     # or: pip install -e ".[dev]"
uv run depsguard        # starts the server on stdio
```

Verify it works without a client:

```bash
uv run pytest -q                          # offline unit tests
uv run python -m evals.run_evals          # live eval suite: scores the tools against real packages
npx @modelcontextprotocol/inspector uv run depsguard   # interactive tool explorer
```

Or run it containerised:

The Dockerfile installs from `uv.lock` with `uv sync --locked`, so container
dependencies match the checked-in lockfile. By default the image installs only
the MCP server runtime. Add `INSTALL_EXAMPLES=true` to include optional example
dependencies such as LangGraph.

```bash
docker build -t depsguard .
docker run -i --rm depsguard              # -i is required: MCP speaks over stdio

docker build --build-arg INSTALL_EXAMPLES=true -t depsguard:examples .
docker run --rm --entrypoint /app/.venv/bin/python depsguard:examples \
  examples/langgraph_dependency_gate.py pypi urllib3 1.26.4 --transport mock --auto-approve-warn
```

## Connect to Claude

**Claude Desktop** — Settings → Developer → Edit Config, then add (use the **absolute path** to `uv`; find it with `which uv`):

```json
{
  "mcpServers": {
    "depsguard": {
      "command": "/absolute/path/to/uv",
      "args": ["--directory", "/absolute/path/to/DepsGuard", "run", "depsguard"]
    }
  }
}
```

Fully quit and reopen Claude Desktop. (Restarting is required after editing the config; Desktop also launches with a minimal `PATH`, which is why the absolute path matters.)

**Claude Code** — one command:

```bash
claude mcp add depsguard -- uv --directory /absolute/path/to/DepsGuard run depsguard
```

## Try these prompts

- *"Is `urllib3` 1.26.4 safe? What CVEs affect it?"*
- *"What license does `requests` use, and what's the latest version?"*
- *"Compare the advisories in `lodash` 4.17.11 vs 4.17.21."* (npm)
- *"Tell me about advisory GHSA-2qrg-x229-3v8q."*
- *"Is the Maven package `org.apache.logging.log4j:log4j-core` 2.14.1 vulnerable?"*

## How it works

Each tool is a thin, typed wrapper over a single deps.dev v3 REST endpoint, returning compact structured data (not raw API dumps) so it stays friendly to an agent's context window. The guardrail composes them into a decision. Built with the official [MCP Python SDK](https://github.com/modelcontextprotocol/python-sdk) (FastMCP). The server is **read-only** and makes no destructive or authenticated calls.

## Evals & CI

- [`evals/run_evals.py`](evals/run_evals.py) scores the tool surface on a labelled set of real packages — correctness on known-vulnerable versions, cross-ecosystem coverage (Cargo + Maven), and a guardrail consistency invariant — printing aggregate metrics and exiting non-zero on failure.
- [`.github/workflows/ci.yml`](.github/workflows/ci.yml) runs the unit tests on every push/PR; [`.github/workflows/evals.yml`](.github/workflows/evals.yml) runs the live eval suite on demand and weekly, as a feedback loop that catches upstream data/API drift.

## LangGraph dependency gate example

[`examples/langgraph_dependency_gate.py`](examples/langgraph_dependency_gate.py) demonstrates how DepsGuard can be used inside an agentic SDLC workflow:

1. A proposed dependency add/upgrade enters a LangGraph workflow.
2. The workflow calls DepsGuard through MCP.
3. DepsGuard returns `ALLOW`, `WARN`, or `BLOCK`.
4. `BLOCK` stops the change.
5. `WARN` triggers a human approval step.
6. The workflow emits a PR-style dependency risk report.

Run:

```bash
# Install the optional example dependencies declared by DepsGuard.
uv sync --extra examples

# Default path: call DepsGuard through MCP stdio and block on medium+ advisories.
uv run python examples/langgraph_dependency_gate.py pypi urllib3 1.26.4 --max-severity medium

# Local debugging path: call the DepsGuard policy function directly, without MCP stdio.
uv run python examples/langgraph_dependency_gate.py pypi urllib3 1.26.4 --transport direct

# Non-interactive approval demo: approve WARN outcomes automatically.
uv run python examples/langgraph_dependency_gate.py pypi urllib3 1.26.4 --transport mock --auto-approve-warn

# Non-interactive rejection demo: reject WARN outcomes automatically.
uv run python examples/langgraph_dependency_gate.py pypi urllib3 1.26.4 --transport mock --reject-warn
```

## Limitations & notes

- Advisories reflect those affecting the selected version **directly** — not vulnerabilities inherited from transitive dependencies. Extending the guardrail across a full resolved dependency graph (deps.dev exposes one) and adding OpenSSF Scorecard signals are natural next features; this build scopes to the highest-signal tools.
- License information is advisory context, not legal advice.
- The guardrail is intentionally conservative and should be adapted per organization.
- deps.dev has **no fixed public rate limit**; the server reports HTTP 429 with a clear retry-later error.
- Live evals depend on upstream deps.dev/OSV data and may detect data drift.
- deps.dev data is provided by Google under [CC-BY 4.0](https://creativecommons.org/licenses/by/4.0/).

## License

This project is released under the MIT licence.  See the [LICENSE](LICENSE) file for details.
