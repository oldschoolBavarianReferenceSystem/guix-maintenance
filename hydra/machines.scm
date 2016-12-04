;;; The /etc/guix/machines.scm file for hydra.gnu.org.  It defines the build
;;; machines that hydra.gnu.org can offload to.

(define gnunet
  (build-machine
   (name "hydra.gnunet.org") ;; "131.159.14.26"
   (user "hydra")
   (system "x86_64-linux")
   (private-key "/home/hydra/.lsh/identity")
   (ssh-options '("-c" "aes256-ctr"))
   (speed 1.7)
   (parallel-builds 4)))

(define gnunet-i686
  (build-machine (inherit gnunet)
    (system "i686-linux")
    (parallel-builds 2)))

(define sjd
  (build-machine
   (name "guix.sjd.se")
   (user "hydra")
   (system "x86_64-linux")
   (private-key "/home/hydra/.lsh/identity")
   (ssh-options '("-c" "aes256-ctr"))
   (speed 1.6)
   (parallel-builds 3)))  ;8 cores

(define sjd-i686
  (build-machine (inherit sjd)
    (system "i686-linux")
    (parallel-builds 2)))

(define chapters
  (build-machine
    (name "chapters.gnu.org")
    (port 9022)
    (user "hydra")
    (system "x86_64-linux")
    (private-key "/home/hydra/.lsh/identity")
    (speed 1.4)
    (parallel-builds 2)))

(define chapters-i686
  (build-machine (inherit chapters)
    (system "i686-linux")))

(define redhill
  (build-machine
    (name "redhill.guixsd.org")
    (port 9023)
    (user "hydra")
    (system "armhf-linux")
    (private-key "/home/hydra/.lsh/identity")
    (ssh-options '("-c" "aes256-ctr"))
    (speed 1.0)
    (parallel-builds 4)))

(define librenote-mips64el
  (build-machine
    (name "librenote.netris.org")
    (port 7272)
    (user "hydra")
    (system "mips64el-linux")
    (private-key "/home/hydra/.lsh/identity")
    (speed 0.6)
    (parallel-builds 2)))

(define hydra-slave0
  (build-machine
    (name "hydra-slave0.gnu.org")
    (port 7272)
    (user "hydra")
    (system "mips64el-linux")
    (private-key "/home/hydra/.lsh/identity")
    (speed 0.6)
    (parallel-builds 2)))

(define hydra-slave1
  (build-machine
    (name "hydra-slave1.netris.org")
    (port 7275)
    (user "hydra")
    (system "armhf-linux")
    (private-key "/home/hydra/.lsh/identity")
    (ssh-options '("-c" "aes256-ctr"))
    (speed 1.0)
    (parallel-builds 2)))

(define hydra-slave2
  (build-machine
    (name "hydra-slave2.netris.org")
    (port 7276)
    (user "hydra")
    (system "armhf-linux")
    (private-key "/home/hydra/.lsh/identity")
    (ssh-options '("-c" "aes256-ctr"))
    (speed 1.0)
    (parallel-builds 2)))


(list gnunet gnunet-i686

      sjd sjd-i686

      chapters chapters-i686

      redhill

      ;; librenote-mips64el    ; dead fan
      hydra-slave0
      hydra-slave1
      hydra-slave2
      )
