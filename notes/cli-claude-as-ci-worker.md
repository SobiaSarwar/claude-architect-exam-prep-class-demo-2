# CLI Notes: Claude Code as a CI Worker

Exam-prep notes covering the GitHub CLI, CI concepts, a live demo, and in-depth configuration of Claude Code (CC) as a CI worker.

## 1. Get the GitHub CLI (`gh`)

- Install: macOS `brew install gh`; Windows `winget install --id GitHub.cli`; Debian/Ubuntu `sudo apt install gh` (after adding GitHub's apt repo). Docs: https://cli.github.com
- Authenticate: `gh auth login` (choose GitHub.com, HTTPS, browser or token). Verify with `gh auth status`.
- Useful commands:
  - `gh repo clone <owner>/<repo>`
  - `gh issue list`, `gh issue view <n>`, `gh issue create`
  - `gh pr create`, `gh pr list`, `gh pr checks`, `gh pr view --comments`
  - `gh run list`, `gh run view <id> --log`, `gh run watch`
  - `gh workflow run <workflow>` to trigger `workflow_dispatch`
  - `gh secret set <NAME>` for Actions secrets
  - `gh api <endpoint>` for anything not covered by a subcommand
- In CI, `gh` is preinstalled on GitHub-hosted runners; authenticate with `GH_TOKEN: ${{ github.token }}`.

## 2. CI Concept Using a GitHub Project

CI (continuous integration) = automatically run checks on every change so problems are caught before merge.

Building blocks in GitHub:

| Concept | GitHub feature |
|---|---|
| Trigger | `on:` events (`push`, `pull_request`, `issues`, `issue_comment`, `schedule`, `workflow_dispatch`) |
| Pipeline | Workflow file in `.github/workflows/*.yml` |
| Unit of work | Job (runs on a runner) made of steps |
| Gate | Required status checks + branch protection on `main` |
| Work tracking | GitHub Project (board) with issues/PRs as items |

Project-board flow (example):

1. Issue is added to a GitHub Project with status `Todo`.
2. Someone comments `@claude ...` or assigns the issue; a workflow starts.
3. The worker creates a branch, commits, and opens a PR linked to the issue.
4. CI checks (e.g. this repo's `Markdown only` check) run on the PR.
5. A human reviews and merges; the Project item moves to `Done` (built-in Project automation).

Key idea: the issue/PR is the interface, the workflow is the executor, branch protection is the safety net.

## 3. Live Demo: Claude as a CI Worker

Demo script (this repo):

1. Install the Claude GitHub app / run `/install-github-app` in Claude Code (creates `claude.yml` and `claude-code-review.yml`, and sets the `CLAUDE_CODE_OAUTH_TOKEN` secret).
2. Create an issue, e.g. "add cli notes for exam prep".
3. Comment `@claude work on this issue and create a PR to main`.
4. Watch the run: `gh run list` then `gh run watch`.
5. Claude posts a progress checklist in a single comment, commits to a `claude/issue-<n>-...` branch, and gives a PR link.
6. Open the PR, check CI results with `gh pr checks`, review, merge.
7. Optional: `claude-code-review.yml` automatically reviews each PR.

What to point out: single updating comment, branch naming, no direct pushes to `main`, markdown-only check gating the PR.

## 4. In-Depth Configuration of CC as a CI Worker

### Workflow (`.github/workflows/claude.yml`)

- Triggers: `issue_comment`, `pull_request_review_comment`, `issues` (opened/assigned), `pull_request_review`.
- Gate with `if:` so it only runs when `@claude` is mentioned.
- Permissions (least privilege): `contents`, `pull-requests`, `issues` and `actions: read` so Claude can read CI results; `id-token: write` for OIDC auth. Grant `write` on contents/PRs/issues only if Claude must push or comment through the token.
- Checkout with `actions/checkout@v4` (`fetch-depth: 1` is fine for most tasks).

### Action inputs (`anthropics/claude-code-action@v1`)

- `claude_code_oauth_token` (subscription) or `anthropic_api_key` (API): always from `secrets`, never inline.
- `prompt`: fixed instruction for automation (e.g. scheduled or PR-opened runs). Omit it in interactive mode so the `@claude` comment is the instruction.
- `claude_args`: pass CLI flags, e.g.
  - `--allowed-tools "Bash(gh pr *),Bash(npm test)"` to whitelist tools
  - `--max-turns 10` to cap runaway loops
  - `--model <model-id>` to choose the model
  - `--append-system-prompt "..."` for extra rules
- `additional_permissions: actions: read` lets Claude read workflow results.
- `trigger_phrase` (default `@claude`), `assignee_trigger`, `label_trigger` customize what starts a run.

### Repo-level guidance

- `CLAUDE.md` at repo root: conventions, build/test commands, and rules (e.g. "markdown only"). Claude reads it every run.
- `.claude/settings.json`: shared permissions/allowed tools for the project.
- MCP servers via `--mcp-config` in `claude_args` when external tools are needed.

### Safety and guardrails

- Branch protection on `main`: require PR, required checks, and human approval; Claude cannot approve PRs.
- Claude cannot modify `.github/workflows/` (GitHub App permission limit).
- Restrict who can trigger it (only users with write access can invoke it by default).
- Keep secrets in Actions secrets; review tool allow-lists; set timeouts (`timeout-minutes`) and `--max-turns`.
- Treat issue/PR text as untrusted input (prompt injection): keep tool permissions minimal.

### Debugging

- `gh run view <id> --log` for the full transcript.
- Check the job summary and the Claude comment's "View job run" link.
- Common failures: missing secret, insufficient permissions, tool not in the allow-list.

## Exam Takeaways

- Claude in CI = GitHub Action + trigger + prompt + scoped tools + repo `CLAUDE.md`.
- Interactive mode (`@claude` mention) vs automation mode (explicit `prompt`).
- Least privilege, allow-lists, turn limits, and human-reviewed PRs are the core safety levers.
