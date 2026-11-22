#!/usr/bin/env bash
# Builds UxPlay and copies it with only the GStreamer parts it needs into app/runtime,
# so the installed app runs on PCs without MSYS2. Run from the MSYS2 UCRT64 shell.
set -euo pipefail
export PATH=/ucrt64/bin:$PATH
HERE="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$HERE/../UxPlay"
OUT="$HERE/runtime"

export BONJOUR_SDK_HOME="${BONJOUR_SDK_HOME:-$HERE/../bonjour-sdk}"
mkdir -p "$SRC/build"
# -mwindows = Windows GUI program: no black console window, so the app can start it without "hide window"
# (that flag also hid the video window). Its output still reaches the app through the pipes.
(cd "$SRC/build" && cmake -G Ninja -DCMAKE_EXE_LINKER_FLAGS=-mwindows .. >/dev/null && ninja >/dev/null)

rm -rf "$OUT"
mkdir -p "$OUT/bin" "$OUT/lib/gstreamer-1.0" "$OUT/libexec/gstreamer-1.0"
cp "$SRC/build/uxplay.exe" /ucrt64/bin/gst-device-monitor-1.0.exe /ucrt64/bin/gst-inspect-1.0.exe "$OUT/bin/"
cp /ucrt64/libexec/gstreamer-1.0/gst-plugin-scanner.exe "$OUT/libexec/gstreamer-1.0/"

# Every element UxPlay builds (renderers/*.c), plus the Windows decoders, sinks and the helpers decodebin needs.
PLUGINS="coreelements app playback typefindfunctions audioconvert audioresample volume videoconvertscale
  pango audioparsers videofilter autodetect directsound videoparsersbad d3d11 d3d12 wasapi wasapi2 libav
  nvcodec qsv level imagefreeze jpeg"
for p in $PLUGINS; do
  cp "/ucrt64/lib/gstreamer-1.0/libgst$p.dll" "$OUT/lib/gstreamer-1.0/"
done

# Copy every DLL these files load from MSYS2 (Windows' own DLLs are left out), repeating until nothing new appears.
while :; do
  new=0
  for f in "$OUT"/bin/*.exe "$OUT"/bin/*.dll "$OUT"/lib/gstreamer-1.0/*.dll "$OUT"/libexec/gstreamer-1.0/*.exe; do
    [ -e "$f" ] || continue
    for dep in $(ldd "$f" | awk '$3 ~ /^\/ucrt64\// {print $3}'); do
      if [ ! -e "$OUT/bin/$(basename "$dep")" ]; then cp "$dep" "$OUT/bin/"; new=1; fi
    done
  done
  [ $new = 0 ] && break
done

# Licences travel with the program (UxPlay is GPL-3; GStreamer is LGPL).
cp "$SRC/LICENSE" "$OUT/UXPLAY-LICENSE.txt"
echo "UxPlay $("$OUT/bin/uxplay.exe" -v 2>&1 | grep -oE "[0-9]+\.[0-9.]+" | head -1) source: https://github.com/FDH2/UxPlay (patched: connection count logged at info level)" > "$OUT/SOURCE.txt"
echo "GStreamer (LGPL-2.1) libraries from MSYS2, unmodified: https://gstreamer.freedesktop.org" >> "$OUT/SOURCE.txt"
du -sh "$OUT"

# Self-check: start the packed receiver with no MSYS2 on PATH; any missing GStreamer piece shows as "no element".
check="$(mktemp)"
( cd "$OUT/bin" && env -i SYSTEMROOT='C:\Windows' PATH=/c/Windows/System32 GST_REGISTRY_1_0="$(mktemp -u)" \
    ./uxplay.exe -n "AZ Pack Check" -nh -h265 -vs d3d11videosink -as wasapi2sink -p 7300 > "$check" 2>&1 & echo $! > "$check.pid" )
sleep 6
# stop only this test copy (by its folder), never a receiver the user has running
powershell -NoProfile -Command 'Get-Process uxplay -ErrorAction SilentlyContinue | Where-Object Path -like "*\runtime\bin\uxplay.exe" | Stop-Process -Force' > /dev/null 2>&1 || true
if grep -q "no element\|ERROR \*\*" "$check" || ! grep -q "Initialized server socket" "$check"; then
  cat "$check"; echo "PACK CHECK FAILED"; exit 1
fi
echo "pack check ok"
