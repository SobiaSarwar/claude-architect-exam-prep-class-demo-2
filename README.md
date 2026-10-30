# Claude Architect Exam Prep (Repo 2)

Study notes and preparation material for the Claude Architect exam.

## Contents

This repo holds Markdown files only for now. Notes will be added by topic as study progresses.

## Planned Structure

- `notes/` – topic-by-topic study notes
- `practice/` – practice questions and answers
- `cheatsheets/` – quick-reference summaries

## Status

Work in progress.

## Markdown-only rule

Only `.md` files are accepted in this repo (plus `.gitignore`, `.gitattributes`, `LICENSE`, `.githooks/`, and `.github/workflows/*.yml`). It is enforced three ways:

1. `.gitignore` ignores everything except markdown and the allowed files.
2. A shared pre-commit hook. Enable it once after cloning: `git config core.hooksPath .githooks`
3. A GitHub Actions check (`Markdown only`) that fails on any other file type.
