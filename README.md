# Personal agent skills

Demand-driven, evidence-backed personal skills shared across agent harnesses.
Canonical skills live in `skills/`; curated relative symlinks in
`targets/agents/` and `targets/claude/` provide installable views.

When repeated correction or one costly failure suggests reusable guidance,
say `make this a skill`. Admission rules live in `AGENTS.md`.

Trial a candidate in clean Pi sessions:

```sh
pi --no-skills
pi --no-skills --skill ./skills/<name>
```

Lifecycle: observe evidence, propose, get approval, write manual positive and
near-miss cases, compare clean sessions, promote only outcome-changing
instructions, then simplify or delete when redundant. No generated catalog.
