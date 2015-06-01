(define-module (my-openmpi)
  #:use-module (guix)
  #:use-module (guix build-system gnu)
  #:use-module (guix licenses)
  #:use-module (guix utils)
  #:use-module (gnu packages pkg-config)
  #:use-module ((gnu packages gcc) #:select (gfortran-4.8))
  #:use-module ((gnu packages mpi) #:select (hwloc))
  #:export (openmpi))

(define openmpi
  (package
    (name "openmpi")
    (version "1.8.1")
    (source (origin
              (method url-fetch)
              (uri (string-append
                    "http://www.open-mpi.org/software/ompi/v"
                    (version-major+minor version)
                    "/downloads/openmpi-" version ".tar.bz2"))
              (sha256
               (base32
                "13z1q69f3qwmmhpglarfjminfy2yw4rfqr9jydjk5507q3mjf50p"))))
    (build-system gnu-build-system)           ;!recipe-build-system
    (inputs `(("hwloc" ,hwloc)                ;!recipe-inputs
              ("gfortran" ,gfortran-4.8)
              ("pkg-config" ,pkg-config)))
    (arguments '(#:configure-flags `("--enable-oshmem")))
    (home-page "http://www.open-mpi.org")
    (synopsis "MPI-2 implementation")
    (description "This is an MPI-2 implementation etc.")
    (license bsd-2)))
