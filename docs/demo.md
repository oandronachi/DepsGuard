# Demo transcript

This transcript shows a direct DepsGuard policy check before a proposed
dependency change is applied.

Scenario:

- Proposed dependency change: `pypi:urllib3@1.26.4`
- Policy: `max_severity="medium"`
- Expected result: advisories are found and DepsGuard returns `BLOCK`
- PR action: attach the rendered dependency risk report and do not apply the
  dependency change

Command:

```powershell
uv run --no-sync --python 3.12 python -c "import asyncio,json; from depsguard.server import evaluate_dependency_policy; print(json.dumps(asyncio.run(evaluate_dependency_policy('pypi','urllib3','1.26.4', max_severity='medium')), indent=2))"
```

Transcript:

```text
HTTP Request: GET https://api.deps.dev/v3/systems/PYPI/packages/urllib3/versions/1.26.4 "HTTP/1.1 200 OK"
HTTP Request: GET https://api.deps.dev/v3/advisories/GHSA-qccp-gfcp-xxvc "HTTP/1.1 200 OK"
HTTP Request: GET https://api.deps.dev/v3/advisories/GHSA-q2q7-5pp4-w6pg "HTTP/1.1 200 OK"
HTTP Request: GET https://api.deps.dev/v3/advisories/GHSA-2xpw-w6gg-jr37 "HTTP/1.1 200 OK"
HTTP Request: GET https://api.deps.dev/v3/advisories/GHSA-38jv-5279-wg99 "HTTP/1.1 200 OK"
HTTP Request: GET https://api.deps.dev/v3/advisories/GHSA-gm62-xv2j-4w53 "HTTP/1.1 200 OK"
HTTP Request: GET https://api.deps.dev/v3/advisories/GHSA-g4mx-q9vg-27p4 "HTTP/1.1 200 OK"
HTTP Request: GET https://api.deps.dev/v3/advisories/GHSA-34jh-p97f-mpxf "HTTP/1.1 200 OK"
HTTP Request: GET https://api.deps.dev/v3/advisories/GHSA-pq67-6m6q-mj2v "HTTP/1.1 200 OK"
HTTP Request: GET https://api.deps.dev/v3/advisories/GHSA-v845-jxx5-vc9f "HTTP/1.1 200 OK"
HTTP Request: GET https://api.deps.dev/v3/advisories/PYSEC-2021-108 "HTTP/1.1 200 OK"
HTTP Request: GET https://api.deps.dev/v3/advisories/PYSEC-2023-192 "HTTP/1.1 200 OK"
HTTP Request: GET https://api.deps.dev/v3/advisories/PYSEC-2023-212 "HTTP/1.1 200 OK"
HTTP Request: GET https://api.deps.dev/v3/advisories/PYSEC-2026-141 "HTTP/1.1 200 OK"
{
  "verdict": "BLOCK",
  "package": "pypi:urllib3@1.26.4",
  "policy_max_severity": "medium",
  "worst_severity": "high",
  "licenses": [
    "MIT"
  ],
  "advisories": [
    {
      "id": "GHSA-2xpw-w6gg-jr37",
      "severity": "unknown",
      "title": "urllib3 streaming API improperly handles highly compressed data",
      "url": "https://osv.dev/vulnerability/GHSA-2xpw-w6gg-jr37"
    },
    {
      "id": "GHSA-34jh-p97f-mpxf",
      "severity": "medium",
      "title": "urllib3's Proxy-Authorization request header isn't stripped during cross-origin redirects",
      "url": "https://osv.dev/vulnerability/GHSA-34jh-p97f-mpxf"
    },
    {
      "id": "GHSA-38jv-5279-wg99",
      "severity": "high",
      "title": "Decompression-bomb safeguards bypassed when following HTTP redirects (streaming API)",
      "url": "https://osv.dev/vulnerability/GHSA-38jv-5279-wg99"
    },
    {
      "id": "GHSA-g4mx-q9vg-27p4",
      "severity": "medium",
      "title": "urllib3's request body not stripped after redirect from 303 status changes request method to GET",
      "url": "https://osv.dev/vulnerability/GHSA-g4mx-q9vg-27p4"
    },
    {
      "id": "GHSA-gm62-xv2j-4w53",
      "severity": "unknown",
      "title": "urllib3 allows an unbounded number of links in the decompression chain",
      "url": "https://osv.dev/vulnerability/GHSA-gm62-xv2j-4w53"
    },
    {
      "id": "GHSA-pq67-6m6q-mj2v",
      "severity": "medium",
      "title": "urllib3 redirects are not disabled when retries are disabled on PoolManager instantiation",
      "url": "https://osv.dev/vulnerability/GHSA-pq67-6m6q-mj2v"
    },
    {
      "id": "GHSA-q2q7-5pp4-w6pg",
      "severity": "high",
      "title": "Catastrophic backtracking in URL authority parser when passed URL containing many @ characters",
      "url": "https://osv.dev/vulnerability/GHSA-q2q7-5pp4-w6pg"
    },
    {
      "id": "GHSA-qccp-gfcp-xxvc",
      "severity": "medium",
      "title": "urllib3: Sensitive headers forwarded across origins in proxied low-level redirects",
      "url": "https://osv.dev/vulnerability/GHSA-qccp-gfcp-xxvc"
    },
    {
      "id": "GHSA-v845-jxx5-vc9f",
      "severity": "medium",
      "title": "`Cookie` HTTP header isn't stripped on cross-origin redirects",
      "url": "https://osv.dev/vulnerability/GHSA-v845-jxx5-vc9f"
    },
    {
      "id": "PYSEC-2021-108",
      "severity": "unknown",
      "title": "PYSEC-2021-108",
      "url": "https://osv.dev/vulnerability/PYSEC-2021-108"
    },
    {
      "id": "PYSEC-2023-192",
      "severity": "high",
      "title": "PYSEC-2023-192",
      "url": "https://osv.dev/vulnerability/PYSEC-2023-192"
    },
    {
      "id": "PYSEC-2023-212",
      "severity": "medium",
      "title": "PYSEC-2023-212",
      "url": "https://osv.dev/vulnerability/PYSEC-2023-212"
    },
    {
      "id": "PYSEC-2026-141",
      "severity": "medium",
      "title": "PYSEC-2026-141",
      "url": "https://osv.dev/vulnerability/PYSEC-2026-141"
    }
  ],
  "reason": "13 advisory(ies); worst severity 'high' exceeds policy max 'medium'."
}
```

PR-style report rendered from the policy result:

```markdown
## Dependency Gate Report

- Package: `pypi:urllib3@1.26.4`
- DepsGuard verdict: `BLOCK`
- Policy max severity: `medium`
- Worst severity: `high`
- Licenses: `MIT`
- Reason: 13 advisory(ies); worst severity 'high' exceeds policy max 'medium'.

### Advisories

| Severity | Advisory | Title | URL |
|---|---|---|---|
| unknown | `GHSA-2xpw-w6gg-jr37` | urllib3 streaming API improperly handles highly compressed data | [link](https://osv.dev/vulnerability/GHSA-2xpw-w6gg-jr37) |
| medium | `GHSA-34jh-p97f-mpxf` | urllib3's Proxy-Authorization request header isn't stripped during cross-origin redirects | [link](https://osv.dev/vulnerability/GHSA-34jh-p97f-mpxf) |
| high | `GHSA-38jv-5279-wg99` | Decompression-bomb safeguards bypassed when following HTTP redirects (streaming API) | [link](https://osv.dev/vulnerability/GHSA-38jv-5279-wg99) |
| medium | `GHSA-g4mx-q9vg-27p4` | urllib3's request body not stripped after redirect from 303 status changes request method to GET | [link](https://osv.dev/vulnerability/GHSA-g4mx-q9vg-27p4) |
| unknown | `GHSA-gm62-xv2j-4w53` | urllib3 allows an unbounded number of links in the decompression chain | [link](https://osv.dev/vulnerability/GHSA-gm62-xv2j-4w53) |
| medium | `GHSA-pq67-6m6q-mj2v` | urllib3 redirects are not disabled when retries are disabled on PoolManager instantiation | [link](https://osv.dev/vulnerability/GHSA-pq67-6m6q-mj2v) |
| high | `GHSA-q2q7-5pp4-w6pg` | Catastrophic backtracking in URL authority parser when passed URL containing many @ characters | [link](https://osv.dev/vulnerability/GHSA-q2q7-5pp4-w6pg) |
| medium | `GHSA-qccp-gfcp-xxvc` | urllib3: Sensitive headers forwarded across origins in proxied low-level redirects | [link](https://osv.dev/vulnerability/GHSA-qccp-gfcp-xxvc) |
| medium | `GHSA-v845-jxx5-vc9f` | `Cookie` HTTP header isn't stripped on cross-origin redirects | [link](https://osv.dev/vulnerability/GHSA-v845-jxx5-vc9f) |
| unknown | `PYSEC-2021-108` | PYSEC-2021-108 | [link](https://osv.dev/vulnerability/PYSEC-2021-108) |
| high | `PYSEC-2023-192` | PYSEC-2023-192 | [link](https://osv.dev/vulnerability/PYSEC-2023-192) |
| medium | `PYSEC-2023-212` | PYSEC-2023-212 | [link](https://osv.dev/vulnerability/PYSEC-2023-212) |
| medium | `PYSEC-2026-141` | PYSEC-2026-141 | [link](https://osv.dev/vulnerability/PYSEC-2026-141) |

### Final Outcome

**Status:** `blocked`
**Final verdict:** `BLOCK`
**Required agent action:** Do not apply the dependency change. Propose a safer version or route to security review.
```
