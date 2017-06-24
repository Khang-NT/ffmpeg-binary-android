# FFmpeg Binary Android
This repo contains FFmpeg standalone executable for android. The binary was built
with Android NDK r15 and compatible with all [ABIs](https://developer.android.com/ndk/guides/abis.html):
- `armeabi` (Android 16+)
- `armeabi-v7a`  (Android 16+)
- `arm64-v8a`  (Android 21+)
- `x86`  (Android 16+)
- `x86_64` (Android 21+)
- `mips`  (Android 16+)
- `mips64` (Android 21+)

FFmpeg main configuration:

```
--enable-protocol='file,pipe'

--enable-libshine # fast mp3 encoder
--enable-libmp3lame
--enable-bsf=aac_adtstoasc

--enable-demuxer='mp4,flv,matroska,webm,mov,3gp,mp3,libmp3lame,libshine,aac,aac_latm,m4a,vorbis,ogg,opus,mp4a,mpegts,image2,mjpeg,jpeg,ipod'

--enable-muxer='mp4,flv,matroska,webm,3gp,mp3,libmp3lame,libshine,aac,aac_latm,m4a,vorbis,ogg,opus,mp4a,mpegts,mjpeg,jpeg,image2,ipod'

--enable-encoder='mp4,m4a,aac,aac_latm,mp3,libmp3lame,libshine,mp4a,mjpeg,jpeg,image2,ipod'
--enable-decoder='mp4,flv,matroska,webm,mov,3gp,mp3,libmp3lame,libshine,aac,aac_latm,m4a,vorbis,ogg,opus,mp4a,mjpeg,jpeg,image2,ipod'

```

# Reference
Build script is referenced at https://github.com/wseemann/FFmpegMediaPlayer
