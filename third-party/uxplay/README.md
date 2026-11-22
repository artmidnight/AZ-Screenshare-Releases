# Building the UxPlay included in AZ Screenshare

These steps rebuild the exact `uxplay.exe` (and the GStreamer parts next to it) that the AZ Screenshare installer ships in `resources/uxplay`.

## 1. Tools (free)

1. Install MSYS2 from https://www.msys2.org (default folder `C:\msys64`).
2. Open the **MSYS2 UCRT64** terminal and run:

   ```bash
   pacman -Syu
   pacman -S --needed git mingw-w64-ucrt-x86_64-cmake mingw-w64-ucrt-x86_64-gcc mingw-w64-ucrt-x86_64-ninja \
     mingw-w64-ucrt-x86_64-tools-git mingw-w64-ucrt-x86_64-libplist mingw-w64-ucrt-x86_64-openssl mingw-w64-ucrt-x86_64-pkgconf \
     mingw-w64-ucrt-x86_64-gstreamer mingw-w64-ucrt-x86_64-gst-plugins-base mingw-w64-ucrt-x86_64-gst-plugins-good \
     mingw-w64-ucrt-x86_64-gst-plugins-bad mingw-w64-ucrt-x86_64-gst-libav
   ```

3. Install Apple Bonjour (`winget install Apple.Bonjour`). UxPlay uses it to announce itself on the network.

## 2. Bonjour headers without the Bonjour SDK download

UxPlay's build looks for the Bonjour SDK. Instead of the SDK, make a folder (for example `bonjour-sdk`) with Apple's open source header and a link library made from Bonjour's `dnssd.dll`:

```bash
mkdir -p bonjour-sdk/Include bonjour-sdk/Lib/x64
curl -L -o bonjour-sdk/Include/dns_sd.h https://raw.githubusercontent.com/apple-oss-distributions/mDNSResponder/main/mDNSShared/dns_sd.h
cd bonjour-sdk/Lib/x64
gendef /c/Windows/System32/dnssd.dll
dlltool -d dnssd.def -l dnssd.lib -D dnssd.dll
cd ../../..
```

## 3. Source and change

```bash
git clone --branch v1.73.7 https://github.com/FDH2/UxPlay
cd UxPlay
git apply ../uxplay-1.73.7-azscreenshare.patch
cd ..
```

## 4. Build and collect

`build-uxplay.sh` (in this folder) builds UxPlay as a Windows GUI program (`-DCMAKE_EXE_LINKER_FLAGS=-mwindows`), copies `uxplay.exe` with only the GStreamer plugins and DLLs it needs, then starts the result once without MSYS2 to check nothing is missing.

Copy it to `app/scripts/build-uxplay.sh` in this layout (or change `SRC`, `OUT` and `BONJOUR_SDK_HOME` at its top):

```
some-folder/
  UxPlay/          (step 3)
  bonjour-sdk/     (step 2)
  app/
    scripts/build-uxplay.sh
    runtime/       (the result, same as resources/uxplay in the installer)
```

```bash
bash app/scripts/build-uxplay.sh
```
