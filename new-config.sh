#!/bin/bash
git pull
cp *.nix /etc/nixos/
nixos-rebuild boot
