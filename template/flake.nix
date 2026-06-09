{
  description = "A basic Emacs configuration built with twist.nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
    twist.url = "github:emacs-twist/twist.nix";

    # Package registries. These are plain Git trees / archives rather than
    # flakes, so they are declared with `flake = false`. twist reads MELPA
    # recipes, ELPA package definitions and archive contents from them.
    melpa = {
      url = "github:melpa/melpa";
      flake = false;
    };
    gnu-elpa = {
      url = "github:elpa-mirrors/elpa";
      flake = false;
    };
    nongnu = {
      url = "github:elpa-mirrors/nongnu";
      flake = false;
    };
    epkgs = {
      url = "github:emacsmirror/epkgs";
      flake = false;
    };
    gnu-elpa-archive = {
      url = "file+https://raw.githubusercontent.com/d12frosted/elpa-mirror/master/gnu/archive-contents";
      flake = false;
    };
  };

  outputs =
    {
      nixpkgs,
      systems,
      twist,
      ...
    }@inputs:
    let
      eachSystem =
        f:
        nixpkgs.lib.genAttrs (import systems) (
          system: f (import nixpkgs { inherit system; })
        );

      inherit (twist.lib) makeEnv;

      emacsConfig =
        pkgs:
        makeEnv {
          inherit pkgs;
          # Use the Emacs from nixpkgs. Override this with another package
          # (e.g. pkgs.emacs-pgtk) if you want a different build.
          emacsPackage = pkgs.emacs;

          # Files that declare which packages to install via `use-package`.
          initFiles = [ ./init.el ];

          # Directory that holds the generated lock files (flake.lock,
          # archive.lock). See README.md for how to bootstrap it.
          lockDir = ./lock;

          registries = [
            {
              type = "elpa";
              path = inputs.gnu-elpa.outPath + "/elpa-packages";
              core-src = pkgs.emacs.src;
              auto-sync-only = true;
            }
            {
              name = "melpa";
              type = "melpa";
              path = inputs.melpa.outPath + "/recipes";
            }
            {
              type = "elpa";
              path = inputs.nongnu.outPath + "/elpa-packages";
            }
            {
              name = "gnu";
              type = "archive-contents";
              path = inputs.gnu-elpa-archive.outPath;
              base-url = "https://raw.githubusercontent.com/d12frosted/elpa-mirror/master/gnu/";
            }
            {
              name = "emacsmirror";
              type = "gitmodules";
              path = inputs.epkgs.outPath + "/.gitmodules";
            }
          ];
        };
    in
    {
      packages = eachSystem (pkgs: rec {
        emacs = emacsConfig pkgs;
        default = emacs;
      });

      # `nix run .#lock` (re)generates lock/flake.nix and lock/archive.lock,
      # `nix run .#update` refreshes the package archives.
      apps = eachSystem (
        pkgs: (emacsConfig pkgs).makeApps { lockDirName = "lock"; }
      );
    };
}
