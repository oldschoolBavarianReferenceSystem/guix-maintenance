;; OS configuration for bayfront, the frontend of the compile farm.

(use-modules (gnu))
(use-service-modules networking ssh)
(use-package-modules admin linux vim)

(define md0
  (mapped-device
    (source (list "/dev/sda2" "/dev/sdb2"))
      (target "/dev/md0")
      (type raid-device-mapping)))

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

  (users (cons* (user-account
                 (name "andreas")
                 (comment "Andreas Enge")
                 (group "users")
                 (supplementary-groups '("wheel"))
                 (home-directory "/home/andreas"))
                (user-account
                 (name "mthl")
                 (comment "Mathieu Lirzin")
                 (group "users")
                 (supplementary-groups '("wheel"))
                 (home-directory "/home/mthl"))
                (user-account
                 (name "ludo")
                 (comment "Ludovic Courtès")
                 (group "users")
                 (supplementary-groups '("wheel"))
                 (home-directory "/home/ludo"))
                %base-user-accounts))

  ;; grub-install needs mdadm in $PATH.
  (packages (cons* mdadm vim lm-sensors %base-packages))

  (services (cons* (dhcp-client-service)
                   (lsh-service #:port-number 9024)
                   %base-services)))

