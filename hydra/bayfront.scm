;; OS configuration for bayfront, the frontend of the compile farm.

(use-modules (gnu) (sysadmin people))
(use-service-modules networking admin mcron ssh)
(use-package-modules admin linux vim package-management)

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


(define md0
  (mapped-device
    (source (list "/dev/sda2" "/dev/sdb2"))
      (target "/dev/md0")
      (type raid-device-mapping)))

(define %gc-job
  ;; The garbage collection mcron job, once per day.
  #~(job '(next-hour '(4))
         (string-append #$guix "/bin/guix gc -F80G")))

(operating-system
  (host-name "bayfront")
  (timezone "Europe/Paris")
  (locale "en_US.UTF-8")

  (bootloader (grub-configuration (device "/dev/sda")))

  (mapped-devices (list md0))
  (file-systems (cons (file-system
                        (title 'device)
                        (device "/dev/md0")
                        (dependencies (list md0))
                        (mount-point "/")
                        (type "ext4"))
                      %base-file-systems))

  ;; Add a kernel module for RAID-10.
  (initrd (lambda (file-systems . rest)
            (apply base-initrd file-systems
                   #:extra-modules '("raid10")
                                   rest)))

  ;; grub-install needs mdadm in $PATH.
  (packages (cons* mdadm vim lm-sensors %base-packages))

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
                   (guix-publish-service #:port 9080)

                   (service rottlog-service-type (rottlog-configuration))
                   (service mcron-service-type
                            (mcron-configuration
                             (jobs (list %gc-job))))

;;                   (modify-services %base-services
;;                     ;; Disable substitutes altogether.
;;                     (guix-service-type config =>
;;                                        (guix-configuration
;;                                         (inherit config)
;;                                         (authorized-keys '())
;;                                         (use-substitutes? #f))))
                   %base-services)))

