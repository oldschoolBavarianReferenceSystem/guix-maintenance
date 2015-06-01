(define-module (query-package)
  #:use-module (my-openmpi)
  #:use-module (guix)
  #:use-module (ice-9 match))

;;!start
;; Query the direct and indirect inputs of Open MPI.
;; Each input is represented by a label/package tuple.
(map (match-lambda
       ((label package)
        (package-full-name package)))
     (package-transitive-inputs openmpi))
