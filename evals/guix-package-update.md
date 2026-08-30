# guix-package-update manual evaluation

## Positive prompts

- `Update the nym-vpn package in ~/Workspace/trev-guix to the latest commit and refresh its hash.`
- `I pushed this source repo. Update the Guix package that tracks it, but do not commit.`
- `Bump the release-tracking foo package to its newest matching tag.`

## Near-miss negative prompts

- `Why did this Guix build fail?`
- `Add a new package to my Guix channel.`
- `Update every package in the channel.`

## Expected critical behavior

- Find and confirm the intended package before editing.
- Preserve its existing commit, tag, or URL-fetch update model and hash syntax.
- For post-push updates, require the exact commit to exist on the remote.
- Refresh the Guix content hash, build with `-L ~/Workspace/trev-guix/channel`, and report any exact validation limit.
- Avoid unrelated edits, commits, pushes, or multi-package bumps.

## Initial observations

2026-08-30 clean-session check: positive package-update prompt loaded the skill
only when available; generic build-failure prompt did not. Skill-guided output
added Trevor's exact channel path and load path, preserved update boundaries,
and retained explicit commit/push authorization rules absent from baseline.
