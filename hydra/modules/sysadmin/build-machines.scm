;;; GNU Guix system administration tools.
;;;
;;; Copyright © 2016 Ludovic Courtès <ludo@gnu.org>
;;;
;;; This program is free software: you can redistribute it and/or modify
;;; it under the terms of the GNU General Public License as published by
;;; the Free Software Foundation, either version 3 of the License, or
;;; (at your option) any later version.
;;;
;;; This program is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

(define-module (sysadmin build-machines)
  #:use-module (gnu)
  #:use-module (gnu services base)
  #:use-module (gnu services ssh)
  #:use-module (gnu services mcron)
  #:use-module (gnu services networking)
  #:use-module (guix gexp)
  #:use-module (sysadmin people)
  #:export (build-machine-os))

;;; Commentary:
;;;
;;; Configuration of build machines.
;;;
;;; Code:

(define* (build-machine-os host-name sysadmins
                           #:key (authorized-guix-keys '()))
  "Return the <operating-system> declaration for a build machine called
HOST-NAME and accessibly by SYSADMINS, with the given AUTHORIZED-GUIX-KEYS."
  (define gc-job
    ;; Run 'guix gc' at 3AM every day.
    #~(job '(next-hour '(3))
           "guix gc -F 40G"))

  (operating-system
    (host-name host-name)
    (timezone "Europe/Paris")
    (locale "en_US.UTF-8")

    (bootloader (grub-configuration (device "/dev/sdX")))
    (file-systems (cons (file-system
                          (device "my-root")
                          (title 'label)
                          (mount-point "/")
                          (type "ext4"))
                        %base-file-systems))

    (services (cons* (service sysadmin-service-type sysadmins)
                     (lsh-service)
                     (dhcp-client-service)
                     (mcron-service (list gc-job))
                     (modify-services %base-services
                       (guix-service-type config =>
                                          (guix-configuration
                                           (inherit config)
                                           (use-substitutes? #f)
                                           (authorized-keys
                                            authorized-guix-keys))))))))

;;; build-machines.scm end here
