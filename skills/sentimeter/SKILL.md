---
name: sentimeter
description: "Use when the user asks a social-listening / business-analytics question about a fintech app (Stori, Klar, Nubank, or DiDi finanzas) — app ratings, reviews, and user sentiment across app stores and social platforms (averages, trends, score distribution, why a rating changed, weekly summaries, themes, complaints, praise, top issues). Answers by driving the `sentimeter` CLI to run read-only SQL over the comments DB. Triggers: SentiMeter, fintech app sentiment/ratings/reviews/app feedback/social listening."
---

# SentiMeter

Answer social-listening / business-analytics questions about a fintech app
(**Stori, Klar, Nubank, or DiDi finanzas**) — ratings, reviews, sentiment,
trends, themes, complaints, praise — by driving the `sentimeter` command-line
tool, which runs **read-only SQL over the `comments` database**.

Your job is to inspect the data contract, write SQL, run it, read the rows, and
present the answer. **Do not invent ratings or numbers — report only what the
query returns.**

## The core workflow: schema → query

Every data question follows the same two steps. **Never write SQL from memory —
always read the schema first**, because the field contract is computed live from
the DB and its columns, enum values, and caveats change over time.

1. **`sentimeter schema`** — prints the field contract for the `comments` table:
   each field's type, its capabilities (filterable / groupable / sortable /
   searchable), enum values, and a **notes** section with critical data caveats
   (see below). Read this before composing any query.
2. **`sentimeter query "<SELECT …>"`** — runs a read-only SQL query (SELECT / WITH
   only) and prints a Markdown table. Use the exact column names and enum values
   the schema reported. Then read the rows and answer the user.

Use the **default output** for both (a Markdown table you can read directly). Do
**not** pass `--json` — you consume the tables yourself. (`--human` exists for a
colored terminal view; you don't need it either.)

```bash
sentimeter schema
sentimeter query "SELECT brand, COUNT(*) AS n, ROUND(AVG(CAST(score AS FLOAT)),2) AS avg_score FROM comments WHERE score IS NOT NULL AND year >= 2019 GROUP BY brand ORDER BY n DESC"
```

SQL can also come from a file (`-f PATH`) or stdin (pipe or `-`):

```bash
echo "SELECT platform, COUNT(*) n FROM comments GROUP BY platform ORDER BY n DESC" | sentimeter query
```

Notes on running queries:

- Results are **capped at 500 rows**. For anything that isn't naturally small,
  **aggregate** (`GROUP BY` / `COUNT` / `AVG`) rather than dumping raw rows; use
  `--max-rows N` to return fewer.
- Only `SELECT` / `WITH` are allowed — write attempts are rejected server-side.
- For numbers and trends, aggregate. To read what users are actually saying, pull
  a bounded sample of `content` / `summary` (e.g. `LIMIT 50` with a tight
  `WHERE`) and read the themes yourself.

### Critical data caveats (also surfaced in `schema` notes)

The `schema` output is authoritative — read it each time — but these recurring
gotchas are worth internalizing:

- **`score`** is 1–5 for `app_store` / `google_play` only; **NULL** for social
  platforms. Filter `score IS NOT NULL` for rating math, and `CAST(score AS
  FLOAT)` before averaging (it's stored as an enum).
- **Data reliability start years**: stori / nubank / klar `>= 2019`,
  didi_finanzas `>= 2022`. Add a `year` filter to avoid pre-launch social-crawl
  pollution.
- **`sentiment`** is populated only for `brand='stori'` social platforms
  (facebook / ins / x / tiktok / linkedin) in the Emplifi era (`>= 2026-03`);
  NULL elsewhere.
- **`category`** holds TWO taxonomies split around 2026-04: English labels (older,
  general) vs Spanish labels (newer, fine-grained). **Do not merge or trend them
  across that cutover.** When grouping by category, filter
  `category IS NOT NULL AND category != ''`.

## Charting (when it helps)

Most answers are fine as text or a Markdown table. But when a chart makes the
answer clearer — a **trend over time**, a **distribution**, or a **comparison
across brands/platforms** — draw one from the query results. The query returns
data, not charts, so you build the visualization yourself.

- **Aggregate in SQL first**, then chart the small result set — e.g. `GROUP BY
  year, month` for a trend, `GROUP BY score` for a distribution, `GROUP BY brand`
  for a comparison. Don't try to chart hundreds of raw rows.
- **How to render** depends on your harness:
  - If you can render an inline artifact / canvas, use that — a self-contained
    HTML page with the chart. (Inline CSS/JS only; embed the data, no external
    CDN.)
  - Otherwise write a self-contained HTML file locally and open it (`open` /
    `xdg-open` / `start`); a CDN-loaded chart library is fine for a local file.
- If a **dataviz** skill is available, use it for the design (colors, axes,
  labels) so charts read cleanly in light and dark.
- Charting is optional — only do it when it genuinely aids understanding or the
  user asks. A clear table often beats a chart.

## Scoping: company and platform

Both are **flexible** — a question can target one, several (a comparison), or all
of them. Neither is mandatory; only scope down when the user asks. In SQL these
map to `WHERE brand IN (…)` and `WHERE platform IN (…)`.

- **Company** → `brand` enum: `stori`, `klar`, `nubank`, `didi_finanzas`.
- **Platform** → `platform` enum, and the valid set depends on the company:
  - **Stori**: `google_play`, `app_store`, `facebook`, `facebook_group`, `ins`,
    `x`, `tiktok`, `linkedin`
  - **Klar / Nubank / DiDi finanzas**: `google_play`, `app_store`, `facebook`,
    `facebook_group`

If the user gave **no hint** about which company (or which platform), **don't
guess and don't ask in free text — present the choices as selectable options**
(use the question/options tool your harness provides): one option per company
plus an **All companies** option; likewise one option per platform valid for the
company in scope plus **All platforms**. Let them pick one or several. Only fall
back to a plain-text question if no options UI is available. Always confirm the
enum values against `schema` before filtering on them.

## Setup — do this yourself, don't hand the user a checklist

The CLI may not be installed or logged in yet. **Handle that for the user
automatically** — run the commands below via your shell tool. Don't tell the
user "go install X then run Y"; just do it, narrating briefly ("Installing the
sentimeter CLI…", "Opening login…"). The only thing you genuinely cannot do for
them is the browser sign-in itself.

### 1. Ensure the CLI is installed (auto)

First check: run `sentimeter --help`. If it prints usage, skip to login.

If it's `command not found`, **install it yourself** (don't ask permission first
beyond your tool's normal prompt; the user clearly wants this). Pick by OS — do
**not** `pip install` or build from source:

- **macOS / Linux:**
  ```bash
  curl -fsSL https://raw.githubusercontent.com/protagolabs/sentimeter-cli/main/install.sh | bash
  ```
- **Windows (PowerShell):**
  ```powershell
  irm https://raw.githubusercontent.com/protagolabs/sentimeter-cli/main/install.ps1 | iex
  ```

The installer drops the binary in `~/.local/bin` or `/usr/local/bin` and appends
that dir to the user's shell rc file (`~/.zshrc` etc.), so **future terminals the
user opens will find `sentimeter` on their own**. But your *current* shell was
already running, so it won't have picked up that PATH change yet. So after
installing, **find it and use it** without making the user open a new terminal:
```bash
export PATH="$HOME/.local/bin:/usr/local/bin:$PATH"
sentimeter --help   # or call the full path, e.g. ~/.local/bin/sentimeter
```
Use that same resolved `sentimeter` (PATH-fixed or full path) for every command
below.

### 2. Ensure logged in (auto-initiate, user just signs in)

Login is a 24h Google device-flow token. You can't complete the Google sign-in
for the user, but you **can drive the whole thing** so they only click once:

1. **Run `sentimeter login` in the background** (it prints a URL + short code,
   then polls until the user authorizes). Running it backgrounded lets you read
   the URL/code from its output while it waits.
2. **Immediately relay the URL and code to the user** and ask them to open it and
   sign in with an authorized Google account, confirming the code matches.
   (`sentimeter login` also tries to open the browser automatically.)
3. **Wait for the command to finish**, then confirm with `sentimeter whoami`.

If a later command fails with `401` / "Token expired", the 24h token lapsed —
**re-run the login flow above automatically**, don't just report the error.

If login says **access denied**, the Google account they used isn't authorized —
usually because they signed in with a personal account. **Tell them to re-run the
login and sign in with their company email.** If it still fails with a company
account, that account isn't authorized and you can't fix it — stop and let them
know.

## More query examples

(The workflow above already shows `schema` and a per-brand average.)

```bash
# Score distribution for Stori on Google Play in 2026.
sentimeter query "SELECT score, COUNT(*) AS n FROM comments WHERE brand='stori' AND platform='google_play' AND year=2026 AND score IS NOT NULL GROUP BY score ORDER BY score"

# Read a bounded sample of recent negative Stori reviews to spot themes.
sentimeter query "SELECT created_at, score, content FROM comments WHERE brand='stori' AND platform='google_play' AND score <= 2 AND year=2026 ORDER BY created_at DESC LIMIT 50"
```

## Error handling

| What you see | What it means → what YOU do (don't just report it) |
|---|---|
| `command not found: sentimeter` | CLI not installed → run the installer yourself (Setup §1), then retry. |
| `Token expired or invalid` / 401 | 24h login lapsed → re-run the login flow yourself (Setup §2), then retry. |
| login **access denied** | Wrong account → **tell them to re-run login with their company email.** If a company account still fails, it's not authorized (you can't fix this). |
| `Only SELECT / WITH read queries are allowed` | You sent a non-read query → rewrite as a `SELECT` / `WITH`. |
| SQL / column error | You guessed a column or enum value → re-run `sentimeter schema` and use the exact names/values it reports. |
| `Request timed out` / 5xx | Backend busy → wait and try once more. |

## Don't

- Don't fabricate ratings, percentages, or trends — only relay what the query
  returns.
- Do initiate `sentimeter login` for the user (Setup §2), but **never** try to
  bypass the browser sign-in, enter their Google password, or capture/store their
  credentials or token — the human completes the sign-in themselves.
- Don't fall back to other install methods (pip, source) when the binary is
  missing — the supported path is the installer in Setup §1.
