;; OS configuration for bayfront, the frontend of the compile farm.

(use-modules (gnu) (sysadmin people))
(use-service-modules base networking admin mcron ssh web)
(use-package-modules admin linux ssh tls vim package-management web wget)

(define %sysadmins
  ;; The sysadmins.
  (list (sysadmin (name "ludo")
                  (full-name "Ludovic Courtès")
                  (lsh-public-key (local-file "keys/lsh/ludo.pub")))
        (sysadmin (name "andreas")
                  (full-name "Andreas Enge")
                  (lsh-public-key (local-file "keys/lsh/andreas.pub")))
        (sysadmin (name "mthl")
                  (full-name "Mathieu Lirzin")
                  (lsh-public-key (local-file "keys/lsh/mthl.pub")))))


(define %gc-job
  ;; The garbage collection mcron job, once per day.
  #~(job '(next-hour '(4))
         (string-append #$guix "/bin/guix gc -F80G")))

(define %guix-daemon-config
  (guix-configuration
   ;; Disable substitutes altogether.
   (use-substitutes? #f)
   (substitute-urls '())
   (authorized-keys '())

   (extra-options '("--max-jobs=4" "--cores=8"    ;we have 32 cores
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
;;; Operating system.
;;;

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

  (packages (cons* certbot wget
                   mdadm vim lm-sensors openssh
                   %base-packages))

  (services (cons* (service sysadmin-service-type %sysadmins)

                   ;; TODO: configure ens9 as 141.255.128.57.
                   ;; TODO: configure ens10 as with:
                   ;;   ip a add dev ens10 2a01:474:0::56/48
                   (static-networking-service
                    "ens10" "141.255.128.56"
                    #:netmask "255.255.255.128"
                    #:gateway "141.255.128.126"
                    #:name-servers '("141.255.128.100" "141.255.129.101"))

                   (lsh-service #:port-number 22)

                   ;; The Web service.
                   (guix-publish-service #:port 3000)
                   (nginx-service #:config-file
                                  (file-append %nginx-config
                                               "/bayfront.conf"))
                   %nginx-mime-types
                   %nginx-cache-activation

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
                             (jobs (list %gc-job))))

                  (modify-services %base-services
                    ;; Disable substitutes altogether.
                    (guix-service-type config => %guix-daemon-config)))))

