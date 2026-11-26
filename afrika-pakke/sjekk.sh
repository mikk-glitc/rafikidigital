#!/bin/bash
# Afrika-pakke: viser kva som er installert og klart.
cd "$(dirname "$(readlink -f "$0")")" || exit 1
echo "================ STATUS ================"
for p in vlc gcompris-qt tuxpaint klavaro clamtk kolibri; do
  dpkg -s "$p" >/dev/null 2>&1 && echo "OK       $p" || echo "MANGLAR  $p"
done
{ dpkg -s localsend >/dev/null 2>&1 || command -v localsend_app >/dev/null; } && echo "OK       localsend" || echo "MANGLAR  localsend"
[ -x "$HOME/Programmer/Kiwix.AppImage" ] && echo "OK       kiwix" || echo "MANGLAR  kiwix"
D=$(xdg-user-dir DESKTOP 2>/dev/null || echo "$HOME/Desktop")
echo "Snarvegar på skrivebordet: $(ls "$D"/*.desktop 2>/dev/null | wc -l)"
echo "Kiwix-filer i pakken:      $(ls Innhold/*.zim 2>/dev/null | wc -l)"
code=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:8080)
case "$code" in 200|302) echo "Kolibri køyrer:            ja";; *) echo "Kolibri køyrer:            NEI (prøv: sudo systemctl start kolibri)";; esac
[ -d "$HOME/.kolibri/content" ] && echo "Kolibri-innhald:           $(du -sh "$HOME/.kolibri/content" 2>/dev/null | cut -f1)"
echo "Pakken totalt:             $(du -sh . 2>/dev/null | cut -f1)"
echo "Nettbrett opnar Kolibri på: http://$(hostname -I | awk '{print $1}'):8080"
echo "========================================"
