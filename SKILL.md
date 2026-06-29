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

## Prerequisites (check, don't assume)

1. **CLI installed.** The tool is the `sentimeter` binary on PATH. If a call fails
   with `command not found`, the user has not installed it yet — give them the
   **one installer that matches their OS** (don't paste both), and do **not** try
   to `pip install` or build from source:

   - **macOS / Linux:**
     ```bash
     curl -fsSL https://raw.githubusercontent.com/protagolabs/sentimeter-cli/main/install.sh | bash
     ```
   - **Windows (PowerShell):**
     ```powershell
     irm https://raw.githubusercontent.com/protagolabs/sentimeter-cli/main/install.ps1 | iex
     ```

   After installing, **verify it succeeded** by running `sentimeter --help` — it
   should print the usage/help text. If that still says `command not found`, the
   user needs to open a new terminal (PATH not refreshed yet) before continuing.

2. **Logged in.** Login is a 24h token obtained via an interactive Google
   device-flow in the browser. **You cannot do this for the user** — it needs a
   real person to open a URL and sign in with a whitelisted Google account
   (`@storicard.com` / `@protagolabs.com` / `@netmind.ai`). If you hit a login
   wall, tell them to run `sentimeter login` themselves, then continue.

## How to answer a question

**Every question must name both a company and a platform.**

- **Company** — one of: **Stori**, **Klar**, **Nubank**, **DiDi finanzas**
- **Platform** — one of: **Google Play**, **App Store**, **Facebook**

If the user's request leaves either one unclear, **ask them first** (offer the
relevant list) — do not guess or default. Ask only for what's missing: if they
named the company but not the platform, just ask the platform, and vice versa.
Once you know both, make sure they appear in the question string you pass to
`ask` (e.g. rewrite "why did the rating drop?" →
"why did Klar's rating drop on Google Play?").

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

| What you see | What it means → what to tell the user |
|---|---|
| `command not found: sentimeter` | CLI not installed → give the installer command above. |
| `Token expired or invalid` / 401 | 24h login lapsed → user must run `sentimeter login` again (browser). |
| login **access denied** | Their Google account isn't whitelisted (`@storicard.com` / `@protagolabs.com` / `@netmind.ai`). |
| `Request timed out` | Backend busy → wait and try once more. |

## Don't

- Don't fabricate ratings, percentages, or trends — only relay what `ask` returns.
- Don't attempt `sentimeter login` non-interactively or try to capture/store the
  user's Google credentials or token.
- Don't fall back to other install methods (pip, source) when the binary is
  missing — the supported path is the installer above.
