---
name: guix-package-update
description: "Update existing packages in Trevor's personal Guix channel to newer commits or releases with matching content hashes. Use when asked to bump a package by name or after pushing a source repository tracked by the channel."
license: MIT
compatibility: "Requires Git and Guix on Trevor's NixOS workstation."
---

# Guix Package Update

Update a package in Trevor's personal Guix channel to its latest commit or
release and refresh the content hash. Make precise Scheme edits; preserve the
package's existing style and update model.

## Channel location

- Personal channel root: `~/Workspace/trev-guix`.
- The `.guix-channel` declares `(directory "channel")`, so the module load path
  is `~/Workspace/trev-guix/channel` and package modules live under
  `~/Workspace/trev-guix/channel/trev-guix/packages/*.scm`
  (modules named `(trev-guix packages <file>)`).
- Build and lint with that load path:
  `guix build -L ~/Workspace/trev-guix/channel <package-name>`.

## Workflow

1. Determine the task mode.
   - **In the channel repo** with a package name: update that package.
   - **In a source repo** that was just committed and pushed: find the channel
     package that tracks this repo, then bump it to the pushed commit.

2. Find the package definition.
   - By name: search the channel for `(define-public <name>` and
     `(name "<name>")`.
     `rg -n '\(define-public <name>|\(name "<name>"' ~/Workspace/trev-guix/channel`
   - From a source repo: take `git remote -v`, normalize the URL (handle
     `git@host:owner/repo.git`, `ssh://git@host/owner/repo.git`, and
     `https://host/owner/repo(.git)`), and search the channel for that URL or
     repository name; confirm the surrounding `origin` is the intended package.
   - Read enough of the package to see `source`, `origin`, fetch `method`,
     `version`, commit or tag, and hash field.

3. Determine the target reference. Preserve the existing update model; do not
   switch commit to tag, change the source URL, or rename the package unless
   asked.
   - `git-fetch` tracking a branch commit: resolve the upstream default branch
     and its HEAD with `git ls-remote --symref <url> HEAD`.
   - `git-fetch` tracking a tag or release: find the newest matching tag with
     `git ls-remote --tags <url>`.
   - `url-fetch` release tarball or binary: find the newest release version and
     rebuild the URI from the existing `version` template.
   - After a push in a source repo: use the pushed `HEAD`; confirm the remote
     has it with `git ls-remote <url> <ref>`.

4. Edit the version and commit.
   - `git-fetch`: replace `(commit ...)` with the new full hash, or the tag
     string for a release-tracking package.
   - `(git-version base revision commit)`: update the `commit` binding; keep the
     existing `revision` unless channel convention says otherwise.
   - If `version` embeds a short commit hash, replace that suffix using the same
     length already present. Do not add a short-hash suffix to a version that
     lacks one.
   - `url-fetch`: bump `version`; the URI usually rebuilds from it.

5. Refresh the hash. Keep the existing syntax (`(base32 "...")` or
   `(content-hash ... sha256 ...)`) unless nearby packages migrated to a newer
   style.
   - Easiest reliable method: edit the commit or version, run
     `guix build -L ~/Workspace/trev-guix/channel <name>`, and copy the
     `sha256 hash mismatch ... expected ... got <base32>` value into the hash
     field, then rebuild.
   - For a `git-fetch` source, compute it directly if useful:
     ```sh
     guix shell git -- git clone --depth 1 --branch <ref> <url> /tmp/pkgsrc
     rm -rf /tmp/pkgsrc/.git
     guix hash -S nar -H sha256 /tmp/pkgsrc
     ```
   - For a `url-fetch` source, `guix download <uri>` prints the base32 hash.

6. Verify.
   - `guix build -L ~/Workspace/trev-guix/channel <package-name>` must succeed.
   - If the build needs unavailable network access or substitutes, at least
     confirm the Scheme parses with `guix build -n` or by loading the module,
     then report the exact limitation.

## Safety checks

- Source URL and target ref must belong to the same repository.
- A post-push update must use a commit visible on the remote, not only locally.
- Preserve unrelated fields and formatting; edit only the source ref and hash,
  plus version when appropriate.
- Do not move multiple packages unless they share the same source bump and
  Trevor expects it.
- Do not commit or push channel changes unless Trevor explicitly asks. When
  asked, follow current repository commit rules.
