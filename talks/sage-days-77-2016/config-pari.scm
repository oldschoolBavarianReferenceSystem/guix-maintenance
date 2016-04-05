;; This is an operating system configuration template
;; for a "bare bones" setup, with no X11 display server.

(use-modules (gnu) (gnu system nss))
(use-service-modules desktop ssh xorg)
(use-package-modules algebra xfce certs)

(operating-system
  (host-name "bugis")
  (timezone "Europe/Berlin")
  (locale "en_US.utf8")

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
  (packages (cons* pari-gp nss-certs %base-packages))

  (services
   (cons* (xfce-desktop-service)
    (modify-services %desktop-services
      (slim-service-type config =>
                         (slim-configuration
                          (inherit config)
                          (auto-login? #t)
                         (default-user "enge")
                         (auto-login-session #~(string-append #$xfce4-session "/bin/startxfce4")))))))

  (name-service-switch %mdns-host-lookup-nss))

