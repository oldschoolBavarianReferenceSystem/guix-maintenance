(use-modules (gnu))
(use-service-modules networking ssh)

(operating-system
  (host-name "schememachine")
  (timezone "Japan")
  (locale "en_US.utf8")
  (bootloader (grub-configuration (device "/dev/sda")))
  (file-systems (cons (file-system
                        (device "my-root")
                        (title 'label)
                        (mount-point "/")
                        (type "ext4"))
                      %base-file-systems))
  (users (cons (user-account
                (name "alice")
                (group "users")
                (home-directory "/home/alice"))
               %base-user-accounts))
  (services (cons* (dhcp-client-service)
                   %base-services)))
