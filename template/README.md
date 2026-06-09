# Emacs configuration with twist.nix

A starting point for building an Emacs configuration with
[twist.nix](https://github.com/emacs-twist/twist.nix) and `use-package`.

## Layout

| Path            | Purpose                                                       |
|-----------------|---------------------------------------------------------------|
| `flake.nix`     | Inputs, package registries and the twist configuration.       |
| `init.el`       | Your configuration. `use-package` forms here drive twist.     |
| `early-init.el` | Loaded before `init.el`; disables `package.el`.               |
| `lock/`         | Generated lock files (`flake.nix`, `flake.lock`, `archive.lock`). |

## Getting started

1. Initialize a new project from this template:

   ```sh
   nix flake init -t github:emacs-twist/twist.nix
   ```

2. Edit `init.el` and add a `use-package` form (with `:ensure t`) for each
   package you want.

3. Make the project a Git repository. The lock command stages the generated
   files with `git add`, so it must run inside a Git work tree:

   ```sh
   git init && git add .
   ```

4. Generate the lock files. This writes `lock/flake.nix` and `lock/archive.lock`
   and then runs `nix flake lock` for you. The `archive-contents` registry is
   fetched over the network, so the first run needs `--impure`:

   ```sh
   nix run .#lock --impure
   ```

5. Build the configuration:

   ```sh
   nix build .#emacs
   ./result/bin/emacs
   ```

## Updating packages

Refresh the ELPA archive snapshot (`archive.lock`) and regenerate the lock
files:

```sh
nix run .#update --impure
nix run .#lock
```

To update packages built from Git sources, bump their pinned revisions in
`lock/flake.lock`:

```sh
nix flake update --flake ./lock
```

## Home Manager

twist also ships a Home Manager module (`twist.homeModules.emacs-twist`) that
installs the wrapper, a desktop entry and (optionally) `emacsclient`. See the
[twist.nix documentation](https://github.com/emacs-twist/twist.nix) for details.
