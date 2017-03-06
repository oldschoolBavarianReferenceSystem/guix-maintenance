;;; The /etc/guix/machines.scm file for hydra.gnu.org.  It defines the build
;;; machines that hydra.gnu.org can offload to.

(define %openssh-private-key
  "/home/hydra/.ssh/id_rsa")

(define gnunet
  (build-machine
   (name "hydra.gnunet.org") ;; "131.159.14.26"
   (user "hydra")
   (system "x86_64-linux")
   (private-key %openssh-private-key)
   (host-key "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDOl8ADHhHcYnRpK5SIZaMHu5NZmpU43I86j5mde+UhL root@hydra")
   ;;(host-key "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC3OPXO9pSx/+m+o4AQoyJphtFKhoQqWjwu9NaVZwmRc1B7QWqoX1OHTzhl1ybSj62sgqp1gPxkrwBCyahZIIhEE0B6pb0ixHj1iuHgdu65gFNLT3zn+43zWS+9YDMXu9C7QmTvhHhqQ3I1/6lDWL81Fr2tqWtqUzLCMGbTKfXr4QbJUk0xmfx1/zhPP4nkeoz+kF+UpQptBCOpbTRqWrSQ7eyZlj74MfiufW7IRkCJ5MJoTiJJOYfVhhZ8kxU+tYcfng0DoPlAOg9qXN6wBbQl/wlqzl878maPSYrXNlJJqezyieK1Zg8/ARq9JuK7ACqjQbGLafLKxFylCG8yObPf root@hydra")
   (speed 1.7)
   (parallel-builds 4)))

(define gnunet-i686
  (build-machine (inherit gnunet)
    (system "i686-linux")
    (parallel-builds 2)))

(define sjd
  (build-machine
   (name "guix.sjd.se")
   (user "hydra")
   (system "x86_64-linux")
   (private-key %openssh-private-key)
   (host-key "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDqac0wX1BQ8BTZbUk7ZgUUROBBLBf0Rs/YqQ0f3dWLj root@guix")
   (speed 1.6)
   (parallel-builds 3)))  ;8 cores

(define sjd-i686
  (build-machine (inherit sjd)
    (system "i686-linux")
    (parallel-builds 2)))

(define chapters
  (build-machine
    (name "chapters.gnu.org")
    (port 9022)
    (user "hydra")
    (system "x86_64-linux")
    (private-key %openssh-private-key)
    (host-key "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDMfqN4Yt7GbAPmI5rPjY7nmChhWUMYZHlopWIcFJVNlTkKUtUYTfb8esQ4zit6qNJot1zvqAvInZWars1OtOqpeedn7kIs2hT/YPqC4dDktaHtViJlAwNp5l8HiVA5pvc1cWDx8r6BlvYeWyCBLWgvKJcCrHXXoYQB3Rrwov2d0McRfnX2YqEjfwbN8kB4bw7he38UFUlq7/n0eSFw7dturFAInGVSSEO/ro6PWacHNnc84pISvz5y1BCAkCO7B798ZlhuWEzP4TZsmXDp24vK4TWtdTsYNTURVdFzBgz66Sxcu0v4B34Y0Cy8Xo7DhUtN1Me45PcDBrw3jawywxTx")
    (speed 1.4)
    (parallel-builds 2)))

(define chapters-i686
  (build-machine (inherit chapters)
    (system "i686-linux")))

(define redhill
  (build-machine
    (name "redhill.guixsd.org")
    (port 9023)
    (user "hydra")
    (system "armhf-linux")
    (private-key %openssh-private-key)
    (host-key "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM+FYr1NUTsXrJgquSTMz0Izkqw3ob7pCU+JPFHgEhHa root@redhill")
    (speed 1.0)
    (parallel-builds 4)))

(define librenote-mips64el                        ;unreachable: dead fan
  (build-machine
    (host-key "FIXME")
    (name "librenote.netris.org")
    (port 7272)
    (user "hydra")
    (system "mips64el-linux")
    (private-key %openssh-private-key)
    (speed 0.6)
    (parallel-builds 2)))

(define hydra-slave0
  (build-machine
    (name "hydra-slave0.gnu.org")
    (port 7272)
    (user "hydra")
    (system "mips64el-linux")
    (private-key %openssh-private-key)
    (host-key "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC9+zyCbJwLr9V/cb3YSQ5SzI3TUvU2QBG6QTuwpJt4lLKsg3jZhIWbY0ZjBd7qEsF7TkWhS5dymt00jwfBmb2JZSdoFaf9MVPLybCKtSvhhpi1Bw9i5ylOLjDP9opG0r26+bZ1e9vNgPj+xi7ZFrPT5B0UBCAYLUOGLoNlG82FS43xeGrRvyJ5VToU+ckyBp1Uei+deE6KMX5lH9p4CKjqop9g9O86W8tGHISo0xu5NI5nzvTpkjYKN6OaQuSuRaP+fpx6pFsJvoVXtHwqF5gDOTfHdmeAgq+WxgUkJcvO/G/YkD9QI58tozrT4Ok2RKKum9VIdNwVGthMnS2fdw0l root@hydra-slave0")
    (speed 0.6)
    (parallel-builds 2)))

(define hydra-slave1
  (build-machine
    (name "hydra-slave1.netris.org")
    (port 7275)
    (user "hydra")
    (system "armhf-linux")
    (private-key %openssh-private-key)
    (host-key "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPDAe9mXufZXFfFlezafA/G2Nng66ssLLi5xPP+9NhGm root@hydra-slave1")
    (speed 1.0)
    (parallel-builds 2)))

(define hydra-slave2
  (build-machine
    (name "hydra-slave2.netris.org")
    (port 7276)
    (user "hydra")
    (system "armhf-linux")
    (private-key %openssh-private-key)
    ;;(host-key "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDbeK7WlnXvG1uzD2Nbh69OYx4IXrRZNMtroCyBrzBfQaRp+c+ByIIP1ZKv9ZPWqZWJHAcujJwCP0OiPSEpzhaYNanQuReWii9hR8awsQm5IkZXisEtc28qLtXJoJAGhEM/o4ad1NY9iPD/l0/TaitAL6DMdjB4CNmqKpy3GScO4JF7szejW2mhXJ0Ho8G0XdBY5NKakxtNCvoHadw5bnx2ai5JVqxlhbhIhldupSFh7q1KeyQLwlda0L7zkk+N8QJi4ta9O1S3QTb4FfyGHmSwZRV+JWx/NSSu+GWwEMZUiBLU8hfnepXFWDP/g+Ii6yz1lTlumGuNm4idkFuE3sYl root@hydra-slave2")
    (host-key "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHzlJZzZfPiEcehmLFtQVYVt3j9w4DHPL6YgSC3EHJK+ root@hydra-slave2")
    (speed 1.0)
    (parallel-builds 2)))


(list gnunet gnunet-i686

      sjd sjd-i686

      chapters chapters-i686

      ;; librenote-mips64el    ; dead fan
      hydra-slave0

      redhill
      hydra-slave1
      hydra-slave2)
