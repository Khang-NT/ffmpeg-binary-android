# FFmpeg Prebuilt Android
This repo contains static FFmpeg executable binary which compatible with all Android [ABIs](https://developer.android.com/ndk/guides/abis.html):  
- `armeabi` (Android 16+)
- `armeabi-v7a`  (Android 16+)
- `arm64-v8a`  (Android 21+)
- `x86`  (Android 16+)
- `x86_64` (Android 21+)
- `mips`  (Android 16+)
- `mips64` (Android 21+)

```
$ ./ffmpeg
ffmpeg version 3.3.2 Copyright (c) 2000-2017 the FFmpeg developers
  built with gcc 4.9.x (GCC) 20150123 (prerelease)
  configuration: --prefix=/Users/khangnt/Desktop/ffmpeg-binary-android/build_scripts/build/armeabi-v7a --target-os=linux --arch=arm --cross-prefix=/Users/khangnt/Desktop/android-ndk-r15/toolchains/arm-linux-androideabi-4.9/prebuilt/darwin-x86_64/bin/arm-linux-androideabi- --enable-cross-compile --sysroot=/Users/khangnt/Desktop/android-ndk-r15/platforms/android-16/arch-arm/ --pkg-config=/usr/local/bin/pkg-config --pkg-config-flags=--static --extra-ldflags='-L/Users/khangnt/Desktop/ffmpeg-binary-android/build_scripts/build/armeabi-v7a/lib -fPIE -pie ' --extra-cflags='-mfloat-abi=softfp -marm -march=armv7-a -Os -O3 -I/Users/khangnt/Desktop/ffmpeg-binary-android/build_scripts/build/armeabi-v7a/include -fPIE ' --enable-pic --enable-small --enable-gpl --disable-shared --enable-static --enable-ffmpeg --disable-ffplay --disable-ffprobe --disable-ffserver --disable-protocols --enable-protocol='file,pipe' --enable-libshine --enable-libmp3lame --enable-libopus --enable-libvorbis --enable-bsf=aac_adtstoasc --disable-demuxers --disable-muxers --enable-demuxer='mp4,flv,matroska,webm,mov,3gp,mp3,libmp3lame,libshine,aac,aac_latm,m4a,vorbis,ogg,opus,mp4a,mpegts,image2,mjpeg,jpeg,ipod,dnxhd' --enable-muxer='mp4,flv,matroska,webm,3gp,mp3,libmp3lame,libshine,aac,aac_latm,m4a,vorbis,ogg,opus,mp4a,mpegts,mjpeg,jpeg,image2,ipod,dnxhd' --disable-encoders --disable-decoders --enable-encoder='mp4,m4a,aac,aac_latm,mp3,libmp3lame,libshine,mp4a,mjpeg,jpeg,image2,ipod,dnxhd' --enable-decoder='mp4,flv,matroska,webm,mov,3gp,mp3,libmp3lame,libshine,aac,aac_latm,m4a,vorbis,ogg,opus,mp4a,mjpeg,jpeg,image2,ipod,dnxhd' --disable-doc
  libavutil      55. 58.100 / 55. 58.100
  libavcodec     57. 89.100 / 57. 89.100
  libavformat    57. 71.100 / 57. 71.100
  libavdevice    57.  6.100 / 57.  6.100
  libavfilter     6. 82.100 /  6. 82.100
  libswscale      4.  6.100 /  4.  6.100
  libswresample   2.  7.100 /  2.  7.100
  libpostproc    54.  5.100 / 54.  5.100
Hyper fast Audio and Video encoder
```

## Build  
You can build it and customize as you want using build scripts in [build_scripts](build_scripts) folder. (Recommended using Android NDK r15).
```
export NDK="path/to/ndk-r15"
./build_all.sh
```

## Credit
Build instruction is learned from https://github.com/wseemann/FFmpegMediaPlayer
