;; This file can be passed to 'guix package --manifest'.
(use-modules (gnu packages base) (gnu packages gcc)
             (my-openmpi))

(packages->manifest
 (list glibc-utf8-locales gnu-make gcc-toolchain openmpi))
