#!/bin/bash
# Afrika-pakke: installerer alt på ein Linux Mint 22-PC. Treng IKKJE internett.
# Køyr frå mappa: ./installer.sh
cd "$(dirname "$(readlink -f "$0")")/Linux" || { echo "Fann ikkje Linux-mappa"; exit 1; }
sudo -v || exit 1

echo "== Program (VLC, GCompris, Tux Paint, Klavaro, ClamAV) =="
nye=()
for f in pakker/*.deb vlc-pakker/*.deb; do
  [ -e "$f" ] || continue
  p=$(dpkg-deb -f "$f" Package 2>/dev/null) || continue
  dpkg -s "$p" >/dev/null 2>&1 || nye+=("./$f")
done
if [ ${#nye[@]} -gt 0 ]; then
  sudo apt-get install -y --no-download "${nye[@]}" 2>/dev/null || { sudo dpkg -i "${nye[@]}"; sudo apt-get -f install -y; }
else
  echo "Alt var allereie installert."
fi

echo "== Virusdatabase =="
if ls clamav-db/*.c?d >/dev/null 2>&1 && [ -d /var/lib/clamav ]; then
  sudo cp -u clamav-db/*.c?d /var/lib/clamav/ && sudo chown clamav:clamav /var/lib/clamav/*.c?d 2>/dev/null
  echo "Lagt inn."
fi

echo "== LocalSend =="
if ! { dpkg -s localsend >/dev/null 2>&1 || command -v localsend_app >/dev/null; } && ls LocalSend*.deb >/dev/null 2>&1; then
  sudo apt-get install -y ./LocalSend*.deb
fi
command -v ufw >/dev/null && sudo ufw allow 53317 >/dev/null && echo "Brannmur opna for LocalSend."

echo "== Kolibri =="
if ! dpkg -s kolibri >/dev/null 2>&1 && ls kolibri*.deb >/dev/null 2>&1; then
  sudo apt-get install -y ./kolibri*.deb
fi

echo "== Kiwix =="
mkdir -p "$HOME/Programmer" && cp -u Kiwix.AppImage "$HOME/Programmer/" && chmod +x "$HOME/Programmer/Kiwix.AppImage"

echo "== Snarvegar på skrivebordet =="
D=$(xdg-user-dir DESKTOP 2>/dev/null || echo "$HOME/Desktop"); mkdir -p "$D"
for n in vlc localsend gcompris tuxpaint klavaro clamtk libreoffice-startcenter libreoffice-writer libreoffice-calc; do
  f=$(ls /usr/share/applications/*"${n}"*.desktop 2>/dev/null | head -1)
  [ -z "$f" ] && f=$(grep -l -i "^Exec=.*${n}" /usr/share/applications/*.desktop 2>/dev/null | head -1)
  [ -n "$f" ] && cp "$f" "$D/"
done
printf '[Desktop Entry]\nType=Application\nName=Kiwix (Wikipedia utan nett)\nExec=%s/Programmer/Kiwix.AppImage\nIcon=accessories-dictionary\nTerminal=false\n' "$HOME" > "$D/Kiwix.desktop"
printf '[Desktop Entry]\nType=Link\nName=Kolibri (læring)\nIcon=applications-science\nURL=http://127.0.0.1:8080\n' > "$D/Kolibri.desktop"
for f in "$D"/*.desktop; do chmod +x "$f"; gio set "$f" metadata::trusted true 2>/dev/null; done

echo
"$(dirname "$PWD")/sjekk.sh"
