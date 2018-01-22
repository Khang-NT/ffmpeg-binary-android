#!/bin/bash

set -e
set -x

export PREFIX=$1

FFMPEG_VERSION="3.3.2"
if [ ! -d "ffmpeg-${FFMPEG_VERSION}" ]; then
    echo "Downloading ffmpeg-${FFMPEG_VERSION}.tar.bz2"
    curl -LO http://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.bz2
    echo "extracting ffmpeg-${FFMPEG_VERSION}.tar.bz2"
    tar -xvf ffmpeg-${FFMPEG_VERSION}.tar.bz2
else
    echo "Using existing `pwd`/ffmpeg-${FFMPEG_VERSION}"
fi

YASM_VERSION="1.3.0"
if [ ! -d "yasm-${YASM_VERSION}" ]; then
    echo "Downloading yasm-${YASM_VERSION}"
    curl -O "http://www.tortall.net/projects/yasm/releases/yasm-${YASM_VERSION}.tar.gz"
    tar -xvzf "yasm-${YASM_VERSION}.tar.gz"
else
    echo "Using existing `pwd`/yasm-${YASM_VERSION}"
fi

# if [ ! -d "x264" ]; then
#     echo "Cloning x264"
#     git clone --depth=1 git://git.videolan.org/x264.git x264
# else
#     echo "Using existing `pwd`/x264"
# fi

OPUS_VERSION="1.1.5"
if [ ! -d "opus-${OPUS_VERSION}" ]; then
    echo "Downloading opus-${OPUS_VERSION}"
    curl -LO https://archive.mozilla.org/pub/opus/opus-${OPUS_VERSION}.tar.gz
    tar -xvzf opus-${OPUS_VERSION}.tar.gz
else
    echo "Using existing `pwd`/opus-${OPUS_VERSION}"
fi

# FDK_AAC_VERSION="0.1.5"
# if [ ! -d "fdk-aac-${FDK_AAC_VERSION}" ]; then
#     echo "Downloading fdk-aac-${FDK_AAC_VERSION}"
#     curl -LO http://downloads.sourceforge.net/opencore-amr/fdk-aac-${FDK_AAC_VERSION}.tar.gz
#     tar -xvzf fdk-aac-${FDK_AAC_VERSION}.tar.gz
# else
#     echo "Using existing `pwd`/fdk-aac-${FDK_AAC_VERSION}"
# fi

LAME_MAJOR="3.99"
LAME_VERSION="3.99.5"
if [ ! -d "lame-${LAME_VERSION}" ]; then
    echo "Downloading lame-${LAME_VERSION}"
    curl -LO http://downloads.sourceforge.net/project/lame/lame/${LAME_MAJOR}/lame-${LAME_VERSION}.tar.gz
    tar -xvzf lame-${LAME_VERSION}.tar.gz
    curl -L -o lame-${LAME_VERSION}/config.guess "http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess;hb=HEAD"
    curl -L -o lame-${LAME_VERSION}/config.sub "http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub;hb=HEAD"
else
    echo "Using existing `pwd`/lame-${LAME_VERSION}"
fi

if [ ! -d "shine" ]; then
    echo "Cloning https://github.com/toots/shine"
    git clone --depth=1 https://github.com/toots/shine.git
else
    echo "Using existing `pwd`/shine"
fi

LIBOGG_VERSION="1.3.2"
if [ ! -d "libogg-${LIBOGG_VERSION}" ]; then
    echo "Downloading libogg-${LIBOGG_VERSION}"
    curl -LO http://downloads.xiph.org/releases/ogg/libogg-${LIBOGG_VERSION}.tar.gz
    tar -xvzf libogg-${LIBOGG_VERSION}.tar.gz
else
    echo "Using existing `pwd`/libogg-${LIBOGG_VERSION}"
fi

LIBVORBIS_VERSION="1.3.4"
if [ ! -d "libvorbis-${LIBVORBIS_VERSION}" ]; then
    echo "Downloading libvorbis-${LIBVORBIS_VERSION}"
    curl -LO http://downloads.xiph.org/releases/vorbis/libvorbis-${LIBVORBIS_VERSION}.tar.gz
    tar -xvzf libvorbis-${LIBVORBIS_VERSION}.tar.gz
else
    echo "Using existing `pwd`/libvorbis-${LIBVORBIS_VERSION}"
fi

# LIBVPX_VERSION="1.6.1"
# if [ ! -d "libvpx-${LIBVPX_VERSION}" ]; then
#     echo "Downloading libvpx-${LIBVPX_VERSION}"
#     curl -LO http://storage.googleapis.com/downloads.webmproject.org/releases/webm/libvpx-${LIBVPX_VERSION}.tar.bz2
#     tar -xvf libvpx-${LIBVPX_VERSION}.tar.bz2
# else
#     echo "Using existing `pwd`/libvpx-${LIBVPX_VERSION}"
# fi


function build_one
{

export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig"
unset CPP
unset CXX
unset CC
unset LD
unset AR
unset NM
unset RANLIB
unset STRIP
unset CPPFLAGS
export LDFLAGS="-L$PREFIX/lib "
export CFLAGS="$OPTIMIZE_CFLAGS -I$PREFIX/include "
export CXXFLAGS="$CFLAGS"

pushd yasm-${YASM_VERSION}
./configure --prefix=$PREFIX 
make clean
make -j8
make install
popd

# pushd x264
# ./configure \
#     --cross-prefix=$CROSS_PREFIX \
#     --sysroot=$PLATFORM \
#     --host=$HOST \
#     --enable-pic \
#     --enable-static \
#     --disable-shared \
#     --disable-cli \
#     --prefix=$PREFIX
# make clean
# make -j8
# make install
# popd

pushd opus-${OPUS_VERSION}
./configure \
    --prefix=$PREFIX \
    --enable-static \
    --disable-shared \
    --disable-doc \
    --disable-extra-programs

make clean
make -j8
make install V=1
popd


# Non-free
# pushd fdk-aac-${FDK_AAC_VERSION}
# ./configure \
#     --prefix=$PREFIX \
#     --enable-static \
#     --disable-shared 
# make clean
# make -j8
# make install
# popd

pushd lame-${LAME_VERSION}
./configure \
    --prefix=$PREFIX \
    --enable-static \
    --disable-shared 

make clean
make -j8
make install
popd

pushd shine
./bootstrap
./configure \
    --prefix=$PREFIX \
    --enable-static \
    --disable-shared

make clean
make -j8
make install
popd

pushd libogg-${LIBOGG_VERSION}
./configure \
    --prefix=$PREFIX \
    --enable-static \
    --disable-shared 
make clean
make -j8
make install
popd

pushd libvorbis-${LIBVORBIS_VERSION}
./configure \
    --prefix=$PREFIX \
    --enable-static \
    --disable-shared \
    --with-ogg=$PREFIX
make clean
make -j8
make install
popd

# (wget --no-check-certificate https://raw.githubusercontent.com/FFmpeg/gas-preprocessor/master/gas-preprocessor.pl && \
#     chmod +x gas-preprocessor.pl && \
#     sudo mv gas-preprocessor.pl /usr/bin) || exit 1

pushd ffmpeg-$FFMPEG_VERSION
./configure --prefix=$PREFIX \
    --pkg-config-flags="--static" \
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
    --enable-libshine \
    --enable-libmp3lame \
    --enable-libopus \
    --enable-libvorbis \
    --enable-bsf=aac_adtstoasc \
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
    --disable-doc \
    $ADDITIONAL_CONFIGURE_FLAG

make clean
make -j8
make install V=1
popd
}


OPTIMIZE_CFLAGS="-O2 -pipe -march=native"
ADDITIONAL_CONFIGURE_FLAG=
build_one

