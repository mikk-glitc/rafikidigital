#!/bin/bash
# Afrika-pakke: lastar ned alle programma og pakkane.
# Krev internett. Trygt å køyre fleire gonger: held fram der det stoppa.
cd "$(dirname "$(readlink -f "$0")")" || exit 1
mkdir -p Linux/pakker Windows Android Innhold
FEIL=()

echo "== LocalSend (Linux, Windows, Android) =="
rel=$(curl -fsSL https://api.github.com/repos/localsend/localsend/releases/latest)
for m in 'linux-x86-64\.AppImage' 'linux-x86-64\.deb' 'windows-x86-64\.zip'; do
  url=$(echo "$rel" | grep -o "https://[^\"]*${m}" | head -1)
  case "$m" in *windows*) d=Windows;; *) d=Linux;; esac
  if [ -n "$url" ]; then wget -q --show-progress -c -P "$d" "$url" || FEIL+=("LocalSend $m"); else FEIL+=("LocalSend $m (fann ikkje lenkje)"); fi
done
apks=$(echo "$rel" | grep -o 'https://[^"]*\.apk' | sort -u)
for url in $apks; do wget -q --show-progress -c -P Android "$url" || FEIL+=("LocalSend APK"); done

echo "== Kiwix =="
wget -q --show-progress -c -O Linux/Kiwix.AppImage \
  https://download.kiwix.org/release/kiwix-desktop/kiwix-desktop_x86_64.appimage || FEIL+=("Kiwix")

echo "== Kolibri =="
ls Linux/kolibri*.deb >/dev/null 2>&1 || \
  wget -q --show-progress --content-disposition -P Linux https://learningequality.org/r/kolibri-deb-latest || FEIL+=("Kolibri Linux")
ls Windows/kolibri*.exe >/dev/null 2>&1 || \
  wget -q --show-progress --content-disposition -P Windows https://learningequality.org/r/kolibri-windows-setup-latest || FEIL+=("Kolibri Windows")

echo "== VLC, GCompris, Tux Paint, Klavaro, ClamAV (med alle pakkane dei treng) =="
PROGRAM="vlc gcompris-qt tuxpaint klavaro clamav clamtk"
liste=$(apt-cache depends --recurse --no-recommends --no-suggests --no-conflicts \
  --no-breaks --no-replaces --no-enhances $PROGRAM | grep "^\w" | grep -v ':' | sort -u)
( cd Linux/pakker || exit
  mangel=(); for p in $liste; do ls "${p}"_*.deb >/dev/null 2>&1 || mangel+=("$p"); done
  echo "  ${#mangel[@]} pakkar å laste ned"
  if [ ${#mangel[@]} -gt 0 ] && ! apt-get download -q "${mangel[@]}" 2>/dev/null; then
    for p in "${mangel[@]}"; do ls "${p}"_*.deb >/dev/null 2>&1 || apt-get download -q "$p" >/dev/null 2>&1 || echo "  (hoppa over $p)"; done
  fi )
for p in $PROGRAM; do ls Linux/pakker/"${p}"_*.deb >/dev/null 2>&1 || FEIL+=("pakke $p"); done
# den gamle mappa frå første versjon trengst ikkje lenger
[ -d Linux/vlc-pakker ] && cp -n Linux/vlc-pakker/*.deb Linux/pakker/ 2>/dev/null && rm -rf Linux/vlc-pakker

echo "== Virusdatabase (ClamAV) =="
mkdir -p Linux/clamav-db
if ls /var/lib/clamav/*.c?d >/dev/null 2>&1; then cp -u /var/lib/clamav/*.c?d Linux/clamav-db/
else echo "  Ingen virusdatabase på denne PC-en enno (installer clamav og vent litt)."; fi

echo "== Kiwix-filer (.zim) inn i pakken =="
while IFS= read -r -d '' z; do
  mv -v "$z" Innhold/ && ln -s "$PWD/Innhold/$(basename "$z")" "$z"
done < <(find "$HOME" -name '*.zim' -type f -not -path "$PWD/*" -print0 2>/dev/null)

chmod +x Linux/*.AppImage 2>/dev/null
echo
echo "================ NEDLASTING FERDIG ================"
du -sh Linux Windows Android Innhold 2>/dev/null
if [ ${#FEIL[@]} -gt 0 ]; then printf 'FEIL: %s\n' "${FEIL[@]}"; else echo "Ingen feil."; fi
