# CLAUDE.md

## What this is

`twist.nix` builds Emacs Lisp packages from upstream Git repositories (MELPA recipes, GNU/NonGNU ELPA, EmacsMirror) rather than from pre-built archives, tracking versions in `flake.lock`.
It is the build layer of [emacs-twist](https://github.com/emacs-twist) (the counterpart to package-build).

The public entry points live in `flake.nix` under `lib` (notably `lib.makeEnv`, `lib.buildElispPackage`, `lib.parseUsePackages`).
The `overlays` and overlay-based `emacsTwist` API are deprecated.

## Fork / branch model

This is a fork of `emacs-twist/twist.nix`.

- **`master`** — a pure mirror of `upstream/master`.
  Do **not** commit here; only fast-forward it from upstream.
- **`local`** — personal integration branch carrying all local changes.
  Day to day work and builds use this.
  Rebase it onto `master` when upstream moves.
- **topic branches** (`fix/...`, `feat/...`) — branched off `master`, one change each, kept PR-ready for upstream.
  They are merged into `local`.

`upstream` remote: `https://github.com/emacs-twist/twist.nix`.

Consequence: avoid repo-wide reformatting on `local`.
A mass diff would conflict on every rebase against `master`.

## Knowledge base (wiki)

Durable, cross-branch notes for this fork live in a separate GitHub Wiki, `ssh://git@github.com/fenril058/twist.nix.wiki.git`, cloned under ghq (find the local path with `ghq list --full-path twist.nix.wiki`).
It tracks the bugfix backlog, the upstream PR/issue plan, build gotchas, and audit false positives — things that outlive any one topic branch.
When a finding or a decision is worth keeping beyond the current branch, record it there (and `git -C … commit && push`), not in per-branch files.
Key pages: `Upstream-PR-Plan.md`, `Bugfix-Cycle-2026-06.md`, `Build-Notes-and-Gotchas.md`, `Fork-and-Branch-Model.md`.

## Layout

| Path                     | Contents                                              |
|--------------------------|-------------------------------------------------------|
| `lib/`                   | Unstable public API surface (`makeEnv`, parsers).     |
| `pkgs/emacs/`            | Configuration builder: `default.nix`, `wrapper.nix`.  |
| `pkgs/emacs/data/`       | Package enumeration from registries (ELPA/MELPA/etc). |
| `pkgs/emacs/build/`      | Single elisp package build + native compilation.      |
| `pkgs/emacs/lock/`       | Lock-file (`flake.nix`/`archive.lock`) generation.    |
| `pkgs/build-support/`    | Pure-Nix helpers + unit tests (`test*.nix`).          |
| `modules/home-manager.nix` | Home Manager module (`programs.emacs-twist`).       |
| `template/`              | `templates.default`, the `nix flake init -t` scaffold.|
| `test/`                  | Integration / smoke test flake driven by `just`.      |
| `doc/`                   | Texinfo manual (`emacs-twist.info`).                  |

## Commands

Unit tests (pure evaluation, no build):

```sh
shopt -s globstar nullglob
nix-instantiate --strict --eval --json pkgs/build-support/**/test*.nix | jq
```

Integration / smoke test (see `test/justfile`):

```sh
cd test
nix develop -c just local-update-flake
nix develop -c just test
```

## Conventions

- Most `pkgs/**` files follow `nixfmt-rfc-style`; `modules/home-manager.nix` uses an older aligned style.
  Match the surrounding file rather than reformatting it.
- The `registries` argument schema (entries with `type = "elpa" | "melpa" | "archive-contents" | "gitmodules"`) is documented by example in `test/twist.nix`.
- Lock generation is exposed per-config via `makeApps { lockDirName = ...; }` (`nix run .#lock` / `.#update`).
