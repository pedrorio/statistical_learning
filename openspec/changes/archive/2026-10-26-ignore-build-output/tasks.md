# Tasks

## 1. Untrack build output

- [x] 1.1 Run `git rm --cached main.pdf` and verify `git ls-files main.pdf` is empty while the working file remains
- [x] 1.2 Ignore `main.pdf`, `main.tex`, and LaTeX intermediates, and verify `git check-ignore` matches `main.pdf`

## Workflow follow-up

- Archive `ignore-build-output` after the PDF is untracked.
