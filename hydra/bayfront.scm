;; OS configuration for bayfront, the frontend of the compile farm.

(use-modules (gnu) (guix) (sysadmin people))
(use-service-modules base networking admin mcron ssh web cuirass)
(use-package-modules admin linux ssh tls vim package-management web wget ci)

(define %sysadmins
  ;; The sysadmins.
  (list (sysadmin (name "ludo")
                  (full-name "Ludovic Courtès")
                  (lsh-public-key (local-file "keys/lsh/ludo.pub")))
        (sysadmin (name "andreas")
                  (full-name "Andreas Enge")
                  (lsh-public-key (local-file "keys/lsh/andreas.pub")))
        (sysadmin (name "rekado")
                  (full-name "Ricardo Wurmus")
                  (lsh-public-key (local-file "keys/lsh/rekado.pub")))))


(define %gc-job
  ;; The garbage collection mcron job, once per day.
  #~(job '(next-hour '(4))
         (string-append #$guix "/bin/guix gc -F80G")))

(define %certbot-job
  ;; Attempt to renew the Let's Encrypt certificate twice a week.
  #~(job (lambda (now)
           (next-day-from (next-hour-from now '(3))
                          '(2 5)))
         (string-append #$certbot "/bin/certbot renew")))

(define %guix-daemon-config
  (guix-configuration
   ;; Disable substitutes altogether.
   (use-substitutes? #f)
   (substitute-urls '())
   (authorized-keys '())

   (extra-options '(;; "--max-jobs=4" "--cores=8"    ;we have 32 cores
                    "--max-jobs=2" "--cores=4"    ;XXX: workaround to reduce
                                                  ;load until RAM is replaced
                    "--cache-failures"
                    "--gc-keep-outputs" "--gc-keep-derivations"))))


;;;
;;; NGINX.
;;;

(define %nginx-config
  ;; Our nginx configuration directory.  It expects 'guix publish' to be
  ;; running on port 3000.
  (computed-file "nginx-config"
                 (with-imported-modules '((guix build utils))
                   #~(begin
                       (use-modules (guix build utils))

                       (mkdir #$output)
                       (chdir #$output)
                       (symlink #$(local-file "nginx/bayfront.conf")
                                "bayfront.conf")
                       (copy-file #$(local-file
                                     "nginx/bayfront-locations.conf")
                                  "bayfront-locations.conf")
                       (substitute* "bayfront-locations.conf"
                         (("@WWWROOT@")
                          #$(local-file "nginx/html" #:recursive? #t)))))))

(define %nginx-mime-types
  ;; Provide /etc/nginx/mime.types (and a bunch of other files.)
  (simple-service 'nginx-mime.types
                  etc-service-type
                  `(("nginx" ,(file-append nginx "/share/nginx/conf")))))

(define %nginx-cache-activation
  ;; Make sure /var/cache/nginx exists on the first run.
  (simple-service 'nginx-/var/cache/nginx
                  activation-service-type
                  (with-imported-modules '((guix build utils))
                    #~(begin
                        (use-modules (guix build utils))
                        (mkdir-p "/var/cache/nginx")))))


;;;
;;; Cuirass.
;;;

(define %cuirass-specs
  ;; Cuirass specifications to build Guix.
  #~(list `((#:name . "guix")
            (#:url . "git://git.savannah.gnu.org/guix.git")
            (#:load-path . ".")

            ;; FIXME: Currently this must be an absolute file name because
            ;; the 'evaluate' command of Cuirass loads it with
            ;; 'primitive-load'.
            ;; Use our own variant of Cuirass' 'examples/gnu-system.scm'.
            (#:file . #$(local-file "cuirass-jobs.scm"))
            (#:no-compile? #t)             ;don't try to run ./bootstrap etc.

            (#:proc . hydra-jobs)
            (#:arguments (subset . "all"))
            (#:branch . "master"))))


;;;
;;; Operating system.
;;;

(define %motd
  ;; Message of the day!  Libcaca's img2txt gives something that's not so
  ;; great.
  (plain-file "motd"
              "\
 :                               .
 S:                            S
  : 8  . . :8         t . . .  ;
     %888.   ;       :   SX8@
          t 8       %  .
           .8 8     .
           .88     t  :     Welcome to bayfront!
            .  t   .8
             .  % .  8
             8   8 8
              .  X  8
              8 8@8

Best practices:

  1. Store everything in guix-maintenance.git.
  2. Use the Git checkouts of Guix and guix-maintenance in ~root.
  3. Notify guix-sysadmin@gnu.org when reconfiguring.
  4. Notify guix-sysadmin@gnu.org when something goes wrong.

Happy hacking!\n"))

(operating-system
  (host-name "bayfront")
  (timezone "Europe/Paris")
  (locale "en_US.UTF-8")

  (bootloader (grub-configuration (device "/dev/sda")))

  (mapped-devices (list (mapped-device
                         (source (list "/dev/sda2" "/dev/sdb2"))
                         (target "/dev/md0")
                         (type raid-device-mapping))))
  (file-systems (cons (file-system
                        (title 'device)
                        (device "/dev/md0")
                        (mount-point "/")
                        (type "ext4")
                        (dependencies mapped-devices))
                      %base-file-systems))

  ;; Add a kernel module for RAID-10.
  (initrd (lambda (file-systems . rest)
            (apply base-initrd file-systems
                   #:extra-modules '("raid10")
                                   rest)))

  (packages (cons* certbot wget iptables jnettop
                   mdadm vim lm-sensors openssh
                   %base-packages))

  (services (cons* (service sysadmin-service-type %sysadmins)

                   ;; TODO: create a bonding interface over ens9 + ens10
                   ;; TODO: configure ens10 as with:
                   ;;   ip a add dev ens10 2a01:474:0::56/48
                   ;;   ip -6 route add default via 2a01:474:0::126
                   (static-networking-service
                    "ens10" "141.255.128.56"
                    #:netmask "255.255.255.128"
                    #:gateway "141.255.128.126"
                    #:name-servers '("141.255.128.100" "141.255.129.101"))

                   ;; Alternate interface.
                   (static-networking-service
                    "ens9" "141.255.128.57"
                    #:netmask "255.255.255.128"
                    ;; Don't repeat #:gateway and #:name-servers.
                    )

                   (lsh-service #:port-number 22)

                   ;; The Web service.
                   (service guix-publish-service-type
                            (guix-publish-configuration
                             (port 3000)
                             (cache "/var/cache/guix/publish")
                             (ttl (* 45 24 3600))
                             (workers 3)))        ;XXX: to reduce load

                   (nginx-service #:config-file
                                  (file-append %nginx-config
                                               "/bayfront.conf"))
                   %nginx-mime-types
                   %nginx-cache-activation

                   (service cuirass-service-type
                            (cuirass-configuration
                             (interval (* 5 60))
                             (specifications %cuirass-specs)))


                   ;; Make SSH and HTTP/HTTPS available over Tor.
                   (tor-hidden-service "http"
                                       '((22 "127.0.0.1:22")
                                         (80 "127.0.0.1:80")
                                         (443 "127.0.0.1:443")))
                   (tor-service)

                   ;; Cron and log rotation.
                   (service rottlog-service-type (rottlog-configuration))
                   (service mcron-service-type
                            (mcron-configuration
                             (jobs (list %gc-job %certbot-job))))

                  (modify-services %base-services
                    ;; Disable substitutes altogether.
                    (guix-service-type config => %guix-daemon-config)
                    (login-service-type
                     config => (login-configuration
                                (inherit config)
                                (motd %motd)))))))
