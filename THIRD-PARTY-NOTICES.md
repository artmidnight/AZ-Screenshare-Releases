# Third-party notices

The AZ Screenshare installer includes the programs below. Each keeps its own license. The AZ Screenshare app itself (its interface, name and logo) is © 2026 Art Midnight, all rights reserved; it starts these programs as separate processes.

## UxPlay 1.73.7 (GPL-3.0)

- Project: https://github.com/FDH2/UxPlay (tag `v1.73.7`)
- License: GNU General Public License v3.0, https://www.gnu.org/licenses/gpl-3.0.html (a copy ships in the install folder as `resources/uxplay/UXPLAY-LICENSE.txt`)
- Changes made by AZ Screenshare: [third-party/uxplay/uxplay-1.73.7-azscreenshare.patch](third-party/uxplay/uxplay-1.73.7-azscreenshare.patch) (the connection count is logged at info level, so the app can show when an iPhone connects and disconnects; once a second an "AZSTATS" line reports frames per second, data rate, phone-to-PC delay, codec and picture size for the app's live stats; "AZAUDIO" lines report sound packets, level and gaps; and a sound fix: "no data" audio packets are marked as received, and a lost audio packet is awaited for about 0.26 s instead of a full 256-packet buffer, which used to silence the first ~2.8 s of every new video). It is built as a Windows GUI program (`-mwindows`).
- How the included `uxplay.exe` is built, step by step: [third-party/uxplay/README.md](third-party/uxplay/README.md). Together with UxPlay's source at the tag above, this is the complete corresponding source of the included UxPlay program.

## GStreamer (LGPL-2.1)

- Project: https://gstreamer.freedesktop.org
- License: GNU Lesser General Public License v2.1
- The installer includes unmodified GStreamer 1.28 libraries and plugins (and the FFmpeg libraries the libav plugin uses, LGPL) as packaged by MSYS2 (https://packages.msys2.org, UCRT64). They are separate DLL files in `resources/uxplay`, so they can be replaced.

## scrcpy 5.0.1 (Apache-2.0)

- Project: https://github.com/Genymobile/scrcpy, copyright Genymobile and Romain Vimont
- License: Apache License 2.0, https://www.apache.org/licenses/LICENSE-2.0 (a copy ships as `resources/scrcpy/LICENSE.txt`)
- Change made by AZ Screenshare: `scrcpy.exe` is marked as a Windows GUI program (one field in the program header), so it starts without a console window. No other change.
- Includes Android's `adb` (Android SDK Platform-Tools, Apache-2.0) and SDL3, FFmpeg and libusb libraries as shipped in the official scrcpy Windows release.

## Apple Bonjour

Not included in the installer. If it is missing, the installer offers to install Apple's own package from the Windows package store (winget `Apple.Bonjour`). For building UxPlay, the `dns_sd.h` header comes from Apple's open source mDNSResponder (https://github.com/apple-oss-distributions/mDNSResponder, Apache-2.0).

## Trademarks

Apple, AirPlay, iPhone, iPad and Bonjour are trademarks of Apple Inc., registered in the U.S. and other countries. Android is a trademark of Google LLC. Other names are trademarks of their owners. AZ Screenshare is an independent app, not made, sponsored or approved by Apple Inc. or Google LLC.
