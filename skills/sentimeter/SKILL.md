---
name: sentimeter
description: "Use when the user asks about app ratings, reviews, or user sentiment for a fintech app (Stori, Klar, Nubank, or DiDi finanzas). Handles two kinds of questions: (1) STATS — numbers and trends like rating averages, review counts, score distribution, 'why did the rating drop', 'weekly summary', 'rating trend'; and (2) SEMANTIC questions about app review content — themes, complaints, praise, 'what are users saying/complaining about', 'top issues this week'. Answers by driving the `sentimeter` CLI, which queries the SentiMeter agent. Triggers: SentiMeter, fintech app sentiment/ratings/reviews/app feedback/review stats."
---

# SentiMeter

Answer questions about app ratings, reviews, and user sentiment for a fintech app
(**Stori, Klar, Nubank, or DiDi finanzas**) by calling the `sentimeter`
command-line tool. Two kinds of questions are in scope:

- **Stats** — numbers and trends: rating averages, review counts, score
  distribution, "why did the rating drop", weekly summaries, rating trend.
- **Semantic (about review content)** — themes, complaints, praise: "what are
  users saying / complaining about", "top issues this week".

The CLI talks to the SentiMeter agent backend; your job is to run it, read its
output, and present the answer. **Do not invent ratings or numbers — report only
what the CLI returns.**

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

If a later `ask` fails with `401` / "Token expired", the 24h token lapsed —
**re-run the login flow above automatically**, don't just report the error.

If login says **access denied**, the Google account they used isn't authorized —
usually because they signed in with a personal account. **Tell them to re-run the
login and sign in with their company email.** If it still fails with a company
account, that account isn't authorized and you can't fix it — stop and let them
know.

## How to answer a question

Both the company and the platform are **flexible** — a question can target one,
several (a comparison), or all of them. Neither is mandatory; only scope down
when the user actually asks you to.

- **Company** — any of: **Stori**, **Klar**, **Nubank**, **DiDi finanzas**. The
  user may want one, a comparison of several, or all of them. Use whatever they
  indicated. If they gave no hint at all, **don't ask in free text — present the
  choices as selectable options** (use the question/options tool your harness
  provides): one option per company (**Stori**, **Klar**, **Nubank**,
  **DiDi finanzas**) plus an **All companies** option, and let them pick one or
  several. Only fall back to a plain-text question if no options UI is available.
- **Platform** — depends on the company:
  - **Stori**: **Google Play**, **App Store**, **Facebook**, **Facebook Groups**,
    **Instagram**, **X**, **TikTok**, **LinkedIn**
  - **Klar / Nubank / DiDi finanzas**: **Google Play**, **App Store**,
    **Facebook**, **Facebook Groups**

  Like company, platform is flexible — one, several, or all. If the user didn't
  specify one, **don't guess and don't ask in free text — present the choices as
  selectable options** (same question/options tool): one option per platform
  available for the company in scope, plus an **All platforms** option, and let
  them pick one or several. Show only the platforms valid for that company (Stori
  has the full list above; the others have just the four). Only scope to a
  specific platform when the user names it or picks it.

Whatever company/platform scope you land on, make it explicit in the question
string you pass to `ask` (e.g. "why did Klar's rating drop on Google Play?", or
"compare Stori vs Nubank ratings across all platforms"). When the scope is all
companies or all platforms, say so — e.g. "across all platforms" — so the answer
covers every one.

**Always run with `--json`** so you get a parseable response:

```bash
sentimeter ask "<the user's question, naming the company and platform>" --json
```

- Match the user's language with `--lang`: `English` | `Español` | `简体中文`.
  Default is English; pass `--lang 简体中文` when the user writes in Chinese, etc.
- **A call legitimately takes tens of seconds** (the agent runs up to ~15
  tool-using turns). This is normal — do not retry or assume it hung.

### Reading the output

`--json` prints a single JSON object:

```json
{ "answer": "…the agent's full answer…", "chart_data": { /* Plotly JSON */ } }
```

- **`answer`** — the text answer. Summarize or relay this to the user.
- **`chart_data`** — present only when the answer has a chart; otherwise `null`.
  It is a **Plotly figure JSON** (typically `{ "data": [...], "layout": {...} }`).

### Rendering the chart (do this whenever `chart_data` is present)

If `chart_data` is not null, **render it for the user — don't just say "there's a
chart."** The portable way (no Python needed) is to write a self-contained HTML
file that loads Plotly from its CDN and embeds the figure, then open it in the
browser:

1. Get the figure JSON. Either take `chart_data` from the `--json` output, or
   re-run with `--save-chart chart.json` to write it to a file.
2. Write an HTML file (e.g. `chart.html`) like this, pasting the figure JSON in
   place of `FIGURE_JSON`:
   ```html
   <!doctype html><meta charset="utf-8">
   <div id="chart" style="width:100%;height:90vh"></div>
   <script src="https://cdn.plot.ly/plotly-2.35.2.min.js"></script>
   <script>
     const fig = FIGURE_JSON;            // ← the chart_data object
     Plotly.newPlot("chart", fig.data || fig, fig.layout || {}, {responsive:true});
   </script>
   ```
3. Open it: `open chart.html` (macOS), `xdg-open chart.html` (Linux), or
   `start chart.html` (Windows PowerShell).

Tell the user where the file is. If you're in an environment that can render
HTML inline (e.g. an artifact/canvas), use that instead of opening a browser.

## Examples

```bash
sentimeter ask "Why did Stori's App Store rating drop last week?" --json
sentimeter ask "Klar 在 Google Play 的本周用户情绪总结" --lang 简体中文 --json
sentimeter ask "Nubank rating trend on Facebook over the last 30 days" --json --save-chart /tmp/trend.json
```

Account check (which user is signed in):

```bash
sentimeter whoami
```

## Error handling

| What you see | What it means → what YOU do (don't just report it) |
|---|---|
| `command not found: sentimeter` | CLI not installed → run the installer yourself (Setup §1), then retry. |
| `Token expired or invalid` / 401 | 24h login lapsed → re-run the login flow yourself (Setup §2), then retry. |
| login **access denied** | Wrong account → **tell them to re-run login with their company email.** If a company account still fails, it's not authorized (you can't fix this). |
| `Request timed out` | Backend busy → wait and try once more. |

## Don't

- Don't fabricate ratings, percentages, or trends — only relay what `ask` returns.
- Do initiate `sentimeter login` for the user (Setup §2), but **never** try to
  bypass the browser sign-in, enter their Google password, or capture/store their
  credentials or token — the human completes the sign-in themselves.
- Don't fall back to other install methods (pip, source) when the binary is
  missing — the supported path is the installer in Setup §1.
