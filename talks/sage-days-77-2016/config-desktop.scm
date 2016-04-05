;; This is an operating system configuration template
;; for a "bare bones" setup, with no X11 display server.

(use-modules (gnu) (gnu system nss))
(use-service-modules desktop ssh)
(use-package-modules certs)

(operating-system
  (host-name "bugis")
  (timezone "Europe/Berlin")
  (locale "de_DE.utf8")

  ;; Assuming /dev/sdX is the target hard disk, and "root" is
  ;; the label of the target root file system.
  (bootloader (grub-configuration (device "/dev/sda")))
  (mapped-devices (list (mapped-device
                          (source "/dev/sda2")
                          (target "home")
                          (type luks-device-mapping))))
  (file-systems (cons* (file-system
                         (device "guixsd")
                         (title 'label)
                         (mount-point "/")
                         (type "ext4"))
                       (file-system
                         (device "/dev/mapper/home")
                         (title 'device)
                         (mount-point "/home")
                         (type "ext4"))
                       %base-file-systems))

  ;; This is where user accounts are specified.  The "root"
  ;; account is implicit, and is initially created with the
  ;; empty password.
  (users (cons* (user-account
                 (name "enge")
                 (comment "Enge")
                 (group "users")
                 (supplementary-groups '("audio" "video" "netdev"))
                 (home-directory "/home/enge"))
                %base-user-accounts))

  ;; Globally-installed packages.
  (packages (cons* nss-certs %base-packages))

  (services (cons* (xfce-desktop-service)
                   %desktop-services))

  (name-service-switch %mdns-host-lookup-nss))

