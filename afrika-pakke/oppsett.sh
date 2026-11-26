#!/bin/bash
# Afrika-pakke: hentar dei nyaste skripta, lastar ned alt og installerer på denne PC-en.
# Bruk:  wget -qO- https://raw.githubusercontent.com/mikk-glitc/rafikidigital/afrika-pakke/afrika-pakke/oppsett.sh | bash
set -e
KJELDE="https://raw.githubusercontent.com/mikk-glitc/rafikidigital/afrika-pakke/afrika-pakke"
mkdir -p "$HOME/Afrika-pakke" && cd "$HOME/Afrika-pakke"
for f in last-ned.sh installer.sh sjekk.sh; do
  wget -q -O "$f.ny" "$KJELDE/$f" && bash -n "$f.ny" && mv "$f.ny" "$f" && chmod +x "$f"
done
echo "Skripta er oppdaterte i $HOME/Afrika-pakke"
set +e
./last-ned.sh </dev/tty
./installer.sh </dev/tty
