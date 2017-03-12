#!/bin/sh
exec guile -e '(@@ (machine-status) machine-status)' -s "$0" "$@"
!#
;;; GNU Guix --- Functional package management for GNU
;;; Copyright © 2016, 2017 Ludovic Courtès <ludo@gnu.org>
;;;
;;; This file is part of GNU Guix.
;;;
;;; GNU Guix is free software; you can redistribute it and/or modify it
;;; under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 3 of the License, or (at
;;; your option) any later version.
;;;
;;; GNU Guix is distributed in the hope that it will be useful, but
;;; WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with GNU Guix.  If not, see <http://www.gnu.org/licenses/>.

(define-module (machine-status)
  #:use-module (ssh auth)
  #:use-module (ssh dist)
  #:use-module (ssh session)
  #:use-module (ssh channel)
  #:use-module (ssh dist node)
  #:use-module (guix records)
  #:use-module (srfi srfi-1)
  #:use-module (ice-9 match)
  #:use-module (ice-9 rdelim)
  #:export (machine-status))

;;; Commentary:
;;;
;;; Report the status (CPU load, etc.) of each build farm machine.
;;;
;;; Code:

(define (read-records port)
  "Read as many recutils-formatted records from PORT as possible and return
them as alists."
  (let loop ((result '()))
    (match (recutils->alist port)
      (()
       (reverse result))
      ((alist ...)
       (loop (cons alist result))))))

(define %machines
  ;; The build farm's machines.
  (map (lambda (alist)
         (list (assoc-ref alist "Hostname")
               (or (and=> (assoc-ref alist "Port") string->number)
                   22)))
       (call-with-input-file "machines.rec"
         read-records)))

(define (machine-session host port)
  "Return an SSH session for HOST at PORT, or #f."
  (format #t "connecting to ~a:~a...~%" host port)
  (let ((session (make-session #:host host #:port port #:user "hydra"
                               #:timeout 5)))
    (match (connect! session)
      ('ok
       (match (userauth-public-key/auto! session)
         ('success
          session)
         (status
          (format #t "  authentication failed: ~a~%" status)
          #f)))
      (_
       (format #t "  failed to connect to ~a:~a: ~a~%"
               host port (get-error session))
       #f))))

(define (machine-load session)
  "Return the load on the machine behind SESSION."
  (let ((channel (make-channel session)))
    (channel-open-session channel)
    (channel-request-exec channel "cat /proc/loadavg")
    (match (string-tokenize (read-line channel))
      ((current-load _ ...)
       (channel-request-send-exit-status channel 0)
       current-load))))

(define (report-machine-status host load uts)
  (format #t "~a~%  kernel: ~a ~a~%  architecture: ~a~%\
  host name: ~a~%  load: ~a~%"
          host
          (utsname:sysname uts) (utsname:release uts)
          (utsname:machine uts)
          (utsname:nodename uts)
          load))


;;;
;;; Entry point.
;;;

(define (machine-status . args)
  (let* ((hosts+sessions
          (filter-map (match-lambda
                        ((host port)
                         (match (machine-session host port)
                           ((? session? session)
                            (list host session))
                           (_
                            #f))))
                      %machines))
         (hosts    (match hosts+sessions
                     (((hosts sessions) ...)
                      hosts)))
         (sessions (match hosts+sessions
                     (((hosts sessions) ...)
                      sessions)))
         (nodes    (map make-node sessions))
         (loads    (map machine-load sessions))
         (uts      (map (lambda (node)
                          (node-eval node '(uname)))
                        nodes)))
    (for-each report-machine-status hosts loads uts)
    (for-each disconnect! sessions)))
