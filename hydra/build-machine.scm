;; GuixSD configuration file for the build machines.
;; Copyright © 2016 Ludovic Courtès <ludo@gnu.org>
;; Released under the GNU GPLv3 or any later version.

(use-modules (sysadmin people)
             (sysadmin build-machines)
             (guix))

(define %sysadmins
  ;; The fine folks!
  (list (sysadmin (name "ludo")
                  (full-name "Ludovic Courtès")
                  (lsh-public-key (local-file "keys/lsh/ludo.pub")))
        (sysadmin (name "hydra")                  ;fake sysadmin
                  (full-name "Hydra User")
                  (restricted? #t)
                  (lsh-public-key
                   (local-file "keys/lsh/hydra.gnu.org.pub")))))

(define %authorized-guix-keys
  ;; List of authorized 'guix archive' keys.
  (list (local-file "keys/guix/hydra.gnu.org-export.pub")))

;; The actual machine.
(build-machine-os "chapters" %sysadmins
                  #:authorized-guix-keys %authorized-guix-keys)
