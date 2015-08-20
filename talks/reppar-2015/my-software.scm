(use-package-modules base gcc)

(packages->manifest
 (list gcc-5 glibc binutils
       coreutils
       gnu-make
       findutils
       sed grep))
