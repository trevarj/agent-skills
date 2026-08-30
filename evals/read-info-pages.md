# read-info-pages manual evaluation

## Positive prompts

- `Use the installed coreutils Info manual to explain cp --reflink and cite the node.`
- `Check Guix Info docs for how --fallback changes substitute behavior.`
- `Read this local .info.gz file and summarize its installation node.`

## Near-miss negative prompts

- `What changed in the latest upstream Emacs release?`
- `Search the web for a tutorial on Texinfo.`
- `Fix this Scheme stack trace.`

## Expected critical behavior

- Prefer a targeted local manual node or index entry and identify its source with `info --where`.
- Use `guix shell PACKAGE texinfo --` when the reader or package manual is absent.
- Cite manual and node, summarize rather than dump, and distinguish installed docs from current upstream behavior.
- State missing or mismatched local documentation instead of substituting memory silently.

## Initial observations

2026-08-30 clean-session check: installed-manual prompt loaded the skill only
when available; upstream-release prompt did not. Skill-guided output explicitly
scoped its answer to locally installed documentation and preserved manual/node
citation, while baseline did not distinguish installed from upstream behavior.
