# FFmpeg Prebuilt Android
This repo contains static FFmpeg executable binary which compatible with all Android [ABIs](https://developer.android.com/ndk/guides/abis.html):  
- `armeabi` (Android 16+)
- `armeabi-v7a`  (Android 16+)
- `arm64-v8a`  (Android 21+)
- `x86`  (Android 16+)
- `x86_64` (Android 21+)
- `mips`  (Android 16+)
- `mips64` (Android 21+)

This is main configuration, optimizes for smallest binary size with most common media codecs and container formats:
```
[...]
    --enable-pic \
    --enable-small \
    --enable-gpl \
    \
    --disable-shared \
    --enable-static \
    \
    --enable-ffmpeg \
    --disable-ffplay \
    --disable-ffprobe \
    --disable-ffserver \
    \
    --disable-protocols \
    --enable-protocol='file,pipe' \
    \
    --disable-demuxers \
    --disable-muxers \
    --enable-demuxer='aac,avi,dnxhd,flac,flv,gif,h261,h263,h264,image2,matroska,webm,mov,mp3,mp4,mpeg,ogg,srt,wav,webvtt' \
    --enable-muxer='3gp,dnxhd,flac,flv,gif,image2,matroska,webm,mov,mp3,mp4,mpeg,ogg,opus,srt,wav,webvtt,ipod' \
    \
    --disable-encoders \
    --disable-decoders \
    --enable-encoder='aac,dnxhd,flac,flv,gif,libmp3lame,libopus,libshine,libvorbis,mpeg4,png,srt,subrip,webvtt' \
    --enable-decoder='aac,aac_at,aac_fixed,aac_latm,dnxhd,flac,flv,h261,h263,h263i,h263p,h264,vp8,vp9,libopus,libvorbis,mp3,mpeg4,wavpack,png,rawvideo,srt,webvtt' \
    \
    --enable-libshine \
    --enable-libmp3lame \
    --enable-libopus \
    --enable-libvorbis \
    --enable-bsf=aac_adtstoasc \
```

## Build  
You can build it and customize as you want using build scripts in [build_scripts](build_scripts) folder. (Recommended using Android NDK r15).
```
export NDK="path/to/ndk-r15"
./build_all.sh
```

## Referent
  - [FFmpegMediaPlayer](https://github.com/wseemann/FFmpegMediaPlayer) by [wseemann](https://github.com/wseemann)

## FFmpeg license
This software uses code of <a href="http://ffmpeg.org">FFmpeg</a> licensed under the <a href="http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html">LGPLv2.1</a> and its source can be downloaded <a href="build_scripts/ffmpeg-3.3.2.tar.bz2">here</a>.

## App using this repo:  
![MediaConverterAndroid](https://github.com/Khang-NT/Android-Media-Converter/raw/master/app/src/main/res/mipmap-xhdpi/ic_launcher_round.png)  
**Media Converter Android:**  
  - Github: [https://github.com/Khang-NT/Android-Media-Converter](https://github.com/Khang-NT/Android-Media-Converter)  
  - PlayStore: [https://play.google.com/store/apps/details?id=com.github.khangnt.mcp](https://play.google.com/store/apps/details?id=com.github.khangnt.mcp)

