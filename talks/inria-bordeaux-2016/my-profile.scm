(use-modules (gnu packages))

(packages->manifest
 (map specification->package
      '("hwloc" "emacs")))
