# AGENTS.md

## Branches

- Treat `master` as a read-only mirror of `upstream/master`, and update it only by fast-forwarding from upstream.
- Make day-to-day changes on the `local` integration branch, and rebase it onto `master` when upstream advances.
- Create each `fix/...` or `feat/...` topic branch from `master`, limit it to one change intended for an upstream pull request, and merge it into `local`.
- Avoid repository-wide reformatting on `local` because it creates conflicts when rebasing onto `master`.

## Durable knowledge

- Store findings that must outlive a topic branch in the separate GitHub Wiki at `ssh://git@github.com/fenril058/twist.nix.wiki.git`, not in per-branch files.
- Resolve the wiki clone path with `ghq list --exact --full-path fenril058/twist.nix.wiki`.

## Verification

- Run pure-evaluation unit tests with `bash -O globstar -O nullglob -o pipefail -c 'nix-instantiate --strict --eval --json pkgs/build-support/**/test*.nix | jq'`.
- Run integration and smoke tests from `test/` with `nix develop -c just local-update-flake`, followed by `nix develop -c just test`.

## Formatting

- Match the surrounding Nix style and do not reformat unrelated code.
