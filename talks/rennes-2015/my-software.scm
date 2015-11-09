(use-package-modules base gcc)

(packages->manifest
 (list gcc-5 glibc binutils
       coreutils findutils sed grep
       gnu-make))
