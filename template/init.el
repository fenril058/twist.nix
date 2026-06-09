;;; init.el --- Example twist configuration  -*- lexical-binding: t; -*-

;; twist discovers packages by parsing the `use-package' forms in this file.
;; Add a `use-package' form with `:ensure t' for every package you want twist
;; to build, then run `nix run .#lock` to update the lock files.

(require 'use-package)

;; Disable the actual installation logic of `:ensure'. Packages are provided by
;; Nix, so package.el must not try to download anything.
(setq use-package-ensure-function #'ignore)

;; A MELPA package.
(use-package magit
  :ensure t)

;; A GNU ELPA package. `:pin' selects the registry to take the package from.
(use-package vertico
  :pin gnu
  :ensure t)

(provide 'init)
;;; init.el ends here
