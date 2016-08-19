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

(define-module (sysadmin people)
  #:use-module (guix gexp)
  #:use-module (guix records)
  #:use-module (gnu services)
  #:use-module (gnu system shadow)
  #:use-module (gnu packages ssh)
  #:use-module (gnu packages base)
  #:use-module (ice-9 match)
  #:export (sysadmin?
            sysadmin
            sysadmin-service-type))

;;; Commentary:
;;;
;;; Declaration of system administrator user accounts.
;;;
;;; Code:

(define-record-type* <sysadmin> sysadmin make-sysadmin
  sysadmin?
  (name            sysadmin-name)
  (full-name       sysadmin-full-name)
  (lsh-public-key  sysadmin-lsh-public-key)
  (restricted?     sysadmin-restricted? (default #f)))

(define (sysadmin->account sysadmin)
  "Return the user account for SYSADMIN."
  (match sysadmin
    (($ <sysadmin> name comment _ restricted?)
     (user-account
      (name name)
      (comment comment)
      (group "users")
      (supplementary-groups (if restricted?
                                '()
                                '("wheel" "kvm"))) ;sudoer
      (home-directory (string-append "/home/" name))))))

(define (sysadmin-lsh-authorization sysadmin)
  "Return a gexp that invokes 'lsh-authorize' for SYSADMIN."
  (match sysadmin
    (($ <sysadmin> name _ public-key)
     #~(begin
         (match (primitive-fork)
           (0
            (dynamic-wind
              (const #t)
              (lambda ()
                (let* ((pw   (getpw #$name))
                       (uid  (passwd:uid pw))
                       (gid  (passwd:gid pw))
                       (home (passwd:dir pw)))
                  (setgroups #())
                  (setgid gid)
                  (setuid uid)

                  ;; 'lsh-authorize' is a shell script so set up a couple of
                  ;; environment variables.
                  (setenv "HOME" home)
                  (setenv "PATH" (string-append #$coreutils "/bin"))

                  (format #t "registering lsh key for '~a' (UID ~a)...~%"
                          #$name (getuid))
                  (system* (string-append #$lsh "/bin/lsh-authorize")
                           #$public-key)))
              (lambda ()
                (primitive-exit 0))))
           (pid
            (waitpid pid)))))))

(define sysadmin-service-type
  ;; The service that initializes sysadmin accounts.
  (service-type
   (name 'sysadmin)
   (extensions (list (service-extension account-service-type
                                        (lambda (lst)
                                          (map sysadmin->account lst)))
                     (service-extension activation-service-type
                                        (lambda (lst)
                                          #~(begin
                                              (use-modules (ice-9 match))
                                              #$@(map sysadmin-lsh-authorization
                                                      lst))))))))

;;; people.scm ends here
