#!/bin/sh

set -e

export USER=demo
export HOME=/home/rekado/demo-home
cd
unset GUILE_LOAD_PATH
unset GUILE_LOAD_COMPILED_PATH
export PATH=$HOME/.guix-profile/bin:/run/current-system/profile/bin:$HOME/local/bin:/run/setuid-programs
rm -f /var/guix/profiles/per-user/demo/guix-profile*
rm -f ~/.guix-profile
rm -f old-times*
rm -rf ~/hello*
unset LANGUAGE
exec bash
