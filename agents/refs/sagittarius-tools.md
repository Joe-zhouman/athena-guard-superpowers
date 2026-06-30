# sagittarius — Tool call guide (reference)

The concrete "which tool, which args" for each research shape. sagittarius's body carries the *router* (question type → capability needed); this file carries the *tool calls* for the capabilities.

**Read this after PHASE 0 routes the question**, before you start hunting. The toolset grows over time — when a new tool arrives, add it under the capability it serves; don't rewrite the router in body.

---

## Capability → tool mapping (current)

| Capability | Primary tool(s) | Notes |
|------------|-----------------|-------|
| Library docs (version-pinned, authoritative) | `mcp__doc` (= context7) | Try FIRST for any named library. Most precise + citable. |
| Current web search | `mcp__common__vps-searxng_search` (preferred), `WebSearch` (fallback) | searxng is a meta-search, often broader. |
| Read a specific URL into context | `mcp__common__z-webReader` (preferred), `jina_reader` (when added), `WebFetch` (last resort) | **See "URL fetch ordering" below — fetch tools fail often due to regional restrictions.** |
| Read a file inside a GitHub repo | `mcp__common__z-read_file` | No clone needed; good for one file. |
| Map a GitHub repo's structure | `mcp__common__z-get_repo_structure` | Before deciding which files to read. |
| Search a repo's docs/issues/commits | `mcp__common__z-search_doc` | Faster than clone for "does repo X mention Y". |
| Go deep on source (full repo, grep, blame) | `Bash` (`git clone --depth 1`) then `Grep`/`Read`/`git blame` | When you need to trace implementation across files. `gh` is NOT available here (network restriction) — use `git clone` only. |
| Academic search | academic-search MCP if available, else `mcp__common__vps-searxng_search` scoped to arxiv/scholar | Check venue/date/citations. |

**Pending tools (not yet wired — add here when installed):** `jina_reader` (URL read, preferred tier), `zotero` (academic refs), `ima` (knowledge base), 知乎 search. When added, slot into the row above by capability.

---

## URL fetch ordering (important — these fail often)

Tools that fetch a URL and return content are the most failure-prone in this environment, because of regional/network restrictions on some providers. **Do not reach for the first fetch tool you see — use this order:**

1. **`mcp__common__z-webReader`** — preferred. Local SearXNG-side reader, most reliable here.
2. **`jina_reader`** — preferred tier (when added; same reliability class as webReader).
3. **`WebFetch`** — last resort. Higher failure rate; if it errors or returns thin content, fall back to webReader rather than retrying WebFetch.

If a fetch tool returns an error, empty body, or clearly truncated content, **switch tool rather than retry the same one.** Don't burn turns retrying WebFetch — it's usually the network restriction, not a transient blip.

---

## Per-capability call patterns

### Library docs — `mcp__doc` (= context7)

You already know context7's two-step flow (resolve-library-id → query-docs). `mcp__doc` is that gateway. Try it FIRST for any named library — version-pinned and citable. Fall back to searxng only if it has nothing on the library.

### Current web search — `mcp__common__vps-searxng_search`

```
query: "<question>"
num_results: 10   # default; raise for broad topics
```

SearXNG is a meta-search — one call fans out to multiple engines. Use it over `WebSearch` when you want breadth. Reframe the query (don't repeat keywords) when you need different angles.

### Read a specific URL — `mcp__common__z-webReader`

```
url: "<exact URL>"
return_format: "markdown"     # markdown | text
retain_images: false          # true if you need figure context
```

Use after a search surfaces a promising URL. Reads the page and returns LLM-friendly markdown — much better than pasting raw HTML. Remember the fetch ordering above.

### Read a file in a GitHub repo (no clone) — `mcp__common__z-read_file`

```
repo_name: "owner/repo"       # e.g. "obra/superpowers"
file_path: "path/to/file"     # relative path in repo
```

Good for one specific file when you don't need the whole repo. For multiple files or grepping, clone instead.

### Map a repo before reading — `mcp__common__z-get_repo_structure`

```
repo_name: "owner/repo"
dir_path: "/"                 # or a subdir to descend
```

Returns the tree. Use it to decide which files are worth reading before you call z-read_file or clone. Avoids reading the wrong files.

### Search a repo's docs/issues/commits — `mcp__common__z-search_doc`

```
repo_name: "owner/repo"
query: "<question about the repo>"
language: "en" | "zh"
```

Faster than cloning when the question is "does this repo address X" or "what changed about Y". Searches docs, issues, and commits in one call.

### Go deep on source — `Bash` clone

```
git clone --depth 1 https://github.com/owner/repo.git "${TMPDIR:-/tmp}/name"
cd "${TMPDIR:-/tmp}/name"
# then Grep for patterns, Read key files, git blame for history
```

Use when you need to trace an implementation across files, or git blame for "when/why did this change." (`gh` is not available here — network restriction — so always `git clone`, never `gh repo clone`.) Always cite a permalink:
```
https://github.com/<owner>/<repo>/blob/<sha>/<filepath>#L<start>-L<end>
```
Get SHA: `git rev-parse HEAD`

### Academic — search + verify

```
1. mcp__common__vps-searxng_search  query: "<topic> survey OR review OR meta-analysis"
2. scope to arxiv/scholar via search query terms
3. verify: publication date, venue quality, citation count
   flag: preprint? peer-reviewed? retracted?
```

---

## Choosing between overlapping tools

- **z-read_file vs clone:** one file → z-read_file (no clone overhead); multiple files / grep / blame → clone.
- **z-search_doc vs clone:** "does the repo mention X" → z-search_doc (fast); "how is X implemented across files" → clone.
- **z-webReader vs WebFetch:** webReader first (see fetch ordering); WebFetch only as last resort.
- **searxng vs WebSearch:** searxng for breadth (meta-search); WebSearch as fallback if searxng returns nothing.
- **mcp__doc vs searxng for a library:** mcp__doc FIRST (version-pinned, authoritative); searxng only if the gateway has nothing.
