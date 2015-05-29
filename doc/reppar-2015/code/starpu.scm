(define-module (starpu)
  #:use-module (guix)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system cmake)
  #:use-module (guix licenses)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages mpi)
  #:use-module (gnu packages algebra)
  #:use-module (gnu packages maths)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages python)
  #:use-module (ice-9 match)
  #:export (starpu chameleon))

(define starpu
  (package
    (name "starpu")
    (version "1.1.4")
    (source (origin
             (method url-fetch)
             (uri (string-append "http://starpu.gforge.inria.fr/files/"
                                 "starpu-" version ".tar.gz"))
             (sha256
              (base32
               "0zmkwk9gc65jwqldjydq758scb5x7srq4rdcp2ssy59rpl2ycdms"))))
    (build-system gnu-build-system)
    (arguments '(#:tests? #f))                    ;XXX: for another day
    (native-inputs `(("pkg-config" ,pkg-config)))
    (inputs `(("fftw" ,fftw)
              ("hwloc" ,hwloc)))
    (home-page "http://starpu.gforge.inria.fr/")
    (synopsis "Run-time system for heterogeneous computing")
    (description "Blah...")
    (license lgpl2.1+)))

;!begin-starpu-variants
(define starpu-1.2rc           ;release candidate
  (package (inherit starpu)
    (version "1.2.0rc2")
    (source (origin
             (method url-fetch)
             (uri (string-append "http://starpu.gforge.inria.fr/files/"
                                 "starpu-" version ".tar.gz"))
             (sha256
              (base32
               "0qgb6yrh3k745grjj14gc2vl6a99m0ljcsisfzcwyhg89vdpx42v"))))))

(define starpu-with-simgrid
  (package (inherit starpu)
    (name "starpu-with-simgrid") ;name that shows up in the user interface
    (inputs `(("simgrid" ,simgrid)
              ,@(package-inputs starpu)))))
;!end-starpu-variants

(define (override-input original label replacement)
  ;; Return a variant of ORIGINAL where inputs corresponding
  ;; to LABEL are replaced by REPLACEMENT, recursively.
  (package (inherit original)
    (inputs (map (lambda (input)
                   (match input
                     ((input-label package)
                      (if (string=? input-label label)
                          `(,label ,replacement)
                          `(,label
                            ,(override-input package
                                             label replacement))))))
                 (package-inputs original)))))

'(begin                                        ;incomplete code follows
;;!begin-chameleon
   (define (make-chameleon name starpu)
     (package
       (name name)
       (version "0.9")
       ;; [other fields omitted]
       (inputs `(("starpu" ,starpu)
                 ("blas" ,atlas)
                 ("lapack" ,lapack)
                 ("gfortran" ,gfortran-4.8)
                 ("python" ,python-2)))))

   (define chameleon
     (make-chameleon "chameleon" starpu))

   (define chameleon/starpu-simgrid
     (make-chameleon "chameleon-simgrid" starpu-with-simgrid))
;;!end-chameleon
   )



(define real-chameleon
  (package
   (name "chameleon")
   (version "0.9")
   (source (origin
            (method url-fetch)
            (uri (string-append
                  "https://project.inria.fr/chameleon/files/2015/02/"
                  "chameleon-" version ".tar_.gz"))
            (sha256
             (base32
              "0zglkqazx5r5r60w881x3ksws96f304k24d0h3ixml1rrrnxrgl1"))
            (file-name (string-append name "-" version
                                      ".tar.gz"))))
   (build-system cmake-build-system)
   (arguments
    '(#:configure-flags (list "-DMORSE_VERBOSE_FIND_PACKAGE=ON"
                              ;; "-DBLAS_VERBOSE=ON"
                              "-DBLA_VENDOR=ATLAS"
                              "-DLAPACK_VERBOSE=ON"
                              (string-append "-DLAPACK_DIR="
                                             (assoc-ref
                                              %build-inputs
                                              "lapack")))))
   (inputs `(("starpu" ,starpu)
             ("blas" ,atlas)
             ("lapack" ,lapack)))
   (native-inputs `(("gfortran" ,gfortran-4.8)
                    ("python" ,python-2)))
   (home-page "https://project.inria.fr/chameleon/")
   (synopsis "Dense linear algebra solver")
   (description "Blah...")
   (license #f)))
