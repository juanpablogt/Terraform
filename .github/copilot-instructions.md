# Copilot Instructions — Terraform Practica

Purpose: give concise context to Copilot Chat for this repository.

Important files:
- `terraform.tf` (root state & config)
- `Practica 2/local_files.tf`, `Practica 2/ramdom.tf`
- `Practica 3/bucket.tf`
- terraform.tfstate files hold local state snapshots

Quick commands:
- Initialize: `terraform init`
- Plan: `terraform plan`
- Apply: `terraform apply -auto-approve`

Interaction guidelines:
- Avoid pasting very large logs or full repo listings into chat. Instead:
  - reference the file path, or
  - paste a focused 10–30 line snippet, or
  - attach the file and say which lines matter.
- After adding large context (logs/diffs), run `/compact` to reduce session tokens.
- For repo scans or long diffs, delegate to a subagent or local script and return a short summary.

Model and cost guidance:
- Use smaller models (e.g. `gpt-4o-mini`) for routine checks and edits; keep `gpt-5.x` for complex syntheses.

If you want, I can expand this into a fuller `AGENTS.md` or apply it as a repo commit.