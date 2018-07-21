#!/bin/bash

## $1: target
## $2: build dir (prefix)
## $3: destination directory where ffmpeg binary will copy to

set -e
set -x

## Support either NDK linux or darwin (mac os)
## Check $NDK exists
if [ "$NDK" = "" ] || [ ! -d $NDK ]; then
	echo "NDK variable not set or path to NDK is invalid, exiting..."
	exit 1
fi

export TARGET=$1
export FLAVOR=$2
export PREFIX=$3
export DESTINATION_FOLDER=$4

if [ "$(uname)" == "Darwin" ]; then
    OS="darwin-x86_64"
else
    OS="linux-x86_64"
fi

NATIVE_SYSROOT=/

if [ "$FLAVOR" = "lite" ]; then 
    # LITE flavor support android 16+
    ARM_SYSROOT=$NDK/platforms/android-16/arch-arm/
    X86_SYSROOT=$NDK/platforms/android-16/arch-x86/
else 
    # FULL flavor require android 21 at minimum (because of including openssl)
    ARM_SYSROOT=$NDK/platforms/android-21/arch-arm/
    X86_SYSROOT=$NDK/platforms/android-21/arch-x86/
fi
ARM_PREBUILT=$NDK/toolchains/arm-linux-androideabi-4.9/prebuilt/$OS
X86_PREBUILT=$NDK/toolchains/x86-4.9/prebuilt/$OS

ARM64_SYSROOT=$NDK/platforms/android-21/arch-arm64/
ARM64_PREBUILT=$NDK/toolchains/aarch64-linux-android-4.9/prebuilt/$OS

X86_64_SYSROOT=$NDK/platforms/android-21/arch-x86_64/
X86_64_PREBUILT=$NDK/toolchains/x86_64-4.9/prebuilt/$OS

## No longer support MIPS MIPS64

# MIPS_SYSROOT=$NDK/platforms/android-16/arch-mips/
# MIPS_PREBUILT=$NDK/toolchains/mipsel-linux-android-4.9/prebuilt/darwin-x86_64
# MIPS_CROSS_PREFIX=$MIPS_PREBUILT/bin/$HOST-

# MIPS64_SYSROOT=$NDK/platforms/android-21/arch-mips64/
# MIPS64_PREBUILT=$NDK/toolchains/mips64el-linux-android-4.9/prebuilt/darwin-x86_64
# MIPS64_CROSS_PREFIX=$MIPS64_PREBUILT/bin/$HOST-

if [ "$FFMPEG_VERSION" = "" ]; then
    FFMPEG_VERSION="3.3.2"
fi
if [ ! -d "ffmpeg-${FFMPEG_VERSION}" ]; then
    echo "Downloading ffmpeg-${FFMPEG_VERSION}.tar.bz2"
    curl -LO http://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.bz2
    echo "extracting ffmpeg-${FFMPEG_VERSION}.tar.bz2"
    tar -xf ffmpeg-${FFMPEG_VERSION}.tar.bz2
else
    echo "Using existing `pwd`/ffmpeg-${FFMPEG_VERSION}"
fi

LIBX264_VERSION="snapshot-20171130-2245"
if [ ! -d "x264-$LIBX264_VERSION" ]; then
    echo "Downloading x264-$LIBX264_VERSION"
    curl -O "ftp://ftp.videolan.org/pub/videolan/x264/snapshots/x264-$LIBX264_VERSION.tar.bz2"
    tar -xf "x264-$LIBX264_VERSION.tar.bz2"
else
    echo "Using existing `pwd`/x264-$LIBX264_VERSION"
fi

OPUS_VERSION="1.1.5"
if [ ! -d "opus-${OPUS_VERSION}" ]; then
    echo "Downloading opus-${OPUS_VERSION}"
    curl -LO https://archive.mozilla.org/pub/opus/opus-${OPUS_VERSION}.tar.gz
    tar -xf opus-${OPUS_VERSION}.tar.gz
else
    echo "Using existing `pwd`/opus-${OPUS_VERSION}"
fi

FDK_AAC_VERSION="0.1.5"
if [ ! -d "fdk-aac-${FDK_AAC_VERSION}" ]; then
    echo "Downloading fdk-aac-${FDK_AAC_VERSION}"
    curl -LO http://downloads.sourceforge.net/opencore-amr/fdk-aac-${FDK_AAC_VERSION}.tar.gz
    tar -xf fdk-aac-${FDK_AAC_VERSION}.tar.gz
else
    echo "Using existing `pwd`/fdk-aac-${FDK_AAC_VERSION}"
fi

LAME_MAJOR="3.99"
LAME_VERSION="3.99.5"
if [ ! -d "lame-${LAME_VERSION}" ]; then
    echo "Downloading lame-${LAME_VERSION}"
    curl -LO http://downloads.sourceforge.net/project/lame/lame/${LAME_MAJOR}/lame-${LAME_VERSION}.tar.gz
    tar -xf lame-${LAME_VERSION}.tar.gz
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
    tar -xf libogg-${LIBOGG_VERSION}.tar.gz
else
    echo "Using existing `pwd`/libogg-${LIBOGG_VERSION}"
fi

LIBVORBIS_VERSION="1.3.4"
if [ ! -d "libvorbis-${LIBVORBIS_VERSION}" ]; then
    echo "Downloading libvorbis-${LIBVORBIS_VERSION}"
    curl -LO http://downloads.xiph.org/releases/vorbis/libvorbis-${LIBVORBIS_VERSION}.tar.gz
    tar -xf libvorbis-${LIBVORBIS_VERSION}.tar.gz
else
    echo "Using existing `pwd`/libvorbis-${LIBVORBIS_VERSION}"
fi

# LIBVPX_VERSION="1.6.1"
# if [ ! -d "libvpx-${LIBVPX_VERSION}" ]; then
#     echo "Downloading libvpx-${LIBVPX_VERSION}"
#     curl -LO http://storage.googleapis.com/downloads.webmproject.org/releases/webm/libvpx-${LIBVPX_VERSION}.tar.bz2
#     tar -xf libvpx-${LIBVPX_VERSION}.tar.bz2
# else
#     echo "Using existing `pwd`/libvpx-${LIBVPX_VERSION}"
# fi

LIBFREETYPE_VERSION="2.9"
if [ ! -d "freetype-${LIBFREETYPE_VERSION}" ]; then
    echo "Downloading freetype-${LIBFREETYPE_VERSION}"
    curl -LO https://download.savannah.gnu.org/releases/freetype/freetype-${LIBFREETYPE_VERSION}.tar.gz
    tar -xf freetype-${LIBFREETYPE_VERSION}.tar.gz
else
    echo "Using existing `pwd`/freetype-${LIBFREETYPE_VERSION}"
fi

EXPAT_VERSION="2.2.3"
if [ ! -d "expat-${EXPAT_VERSION}" ]; then
    echo "Downloading expat-${EXPAT_VERSION}"
    curl -LO http://downloads.sourceforge.net/project/expat/expat/${EXPAT_VERSION}/expat-${EXPAT_VERSION}.tar.bz2
    tar -xf expat-${EXPAT_VERSION}.tar.bz2
else
    echo "Using existing `pwd`/expat-${EXPAT_VERSION}"
fi

LIBUUID_VERSION="1.0.3"
if [ ! -d "libuuid-${LIBUUID_VERSION}" ]; then
    echo "Downloading libuuid-${LIBUUID_VERSION}"
    curl -LO https://downloads.sourceforge.net/project/libuuid/libuuid-${LIBUUID_VERSION}.tar.gz
    tar -xf libuuid-${LIBUUID_VERSION}.tar.gz
else
    echo "Using existing `pwd`/libuuid-${LIBUUID_VERSION}"
fi

LIBFONTCONFIG_VERSION="2.13.0"
if [ ! -d "fontconfig-${LIBFONTCONFIG_VERSION}" ]; then
    echo "Downloading fontconfig-${LIBFONTCONFIG_VERSION}"
    curl -LO https://www.freedesktop.org/software/fontconfig/release/fontconfig-${LIBFONTCONFIG_VERSION}.tar.gz
    tar -xf fontconfig-${LIBFONTCONFIG_VERSION}.tar.gz
else
    echo "Using existing `pwd`/fontconfig-${LIBFONTCONFIG_VERSION}"
fi

GETTEXT_VERSION="0.19.8.1"
if [ ! -d "gettext-${GETTEXT_VERSION}" ]; then
    echo "Downloading gettext-${GETTEXT_VERSION}"
    curl -LO http://ftp.gnu.org/pub/gnu/gettext/gettext-${GETTEXT_VERSION}.tar.gz
    tar -xf gettext-${GETTEXT_VERSION}.tar.gz
else
    echo "Using existing `pwd`/gettext-${GETTEXT_VERSION}"
fi

LIBPNG_VERSION="1.6.34"
if [ ! -d "libpng-${LIBPNG_VERSION}" ]; then
    echo "Downloading libpng-${LIBPNG_VERSION}"
    curl -LO https://downloads.sourceforge.net/project/libpng/libpng16/${LIBPNG_VERSION}/libpng-${LIBPNG_VERSION}.tar.xz
    tar -xf libpng-${LIBPNG_VERSION}.tar.xz
else
    echo "Using existing `pwd`/libpng-${LIBPNG_VERSION}"
fi

# Download lib openssl prebuilt
OPENSSL_PREBUILT_FOLDER="$(pwd)/openssl-prebuilt"
if [ ! -d $OPENSSL_PREBUILT_FOLDER/android ]; then
    curl -LO "https://github.com/leenjewel/openssl_for_ios_and_android/releases/download/openssl-1.0.2k/openssl.1.0.2k_for_android_ios.zip"
    mkdir -p $OPENSSL_PREBUILT_FOLDER && unzip -q "openssl.1.0.2k_for_android_ios.zip" -d $OPENSSL_PREBUILT_FOLDER
fi


function build_one
{

if [ "$(uname)" == "Darwin" ]; then
    brew install yasm nasm automake gettext
    export PATH="/usr/local/opt/gettext/bin:$PATH"
else
    sudo apt-get update
    sudo apt-get -y install automake autopoint libtool gperf
    # Install nasm >= 2.13 for libx264
    if [ ! -d "nasm-2.13.03" ]; then
        curl -LO 'http://www.nasm.us/pub/nasm/releasebuilds/2.13.03/nasm-2.13.03.tar.xz'
        tar -xf nasm-2.13.03.tar.xz
    fi
    pushd nasm-2.13.03
        ./configure --prefix=/usr
        make
        sudo make install
    popd

    if [ "$FLAVOR" = "full" ]; then 
        pushd gettext-${GETTEXT_VERSION}
            ./configure --prefix=/usr
            make
            sudo make install
        popd
    fi;
fi

if [ $ARCH == "native" ]
then
    SYSROOT=$NATIVE_SYSROOT
    HOST=
    CROSS_PREFIX=
    if [ "$(uname)" == "Darwin" ]; then
        brew install openssl
    else 
        sudo apt-get install -y libssl-dev
    fi
elif [ $ARCH == "arm" ]
then
    SYSROOT=$ARM_SYSROOT
    HOST=arm-linux-androideabi
    CROSS_PREFIX=$ARM_PREBUILT/bin/$HOST-
    OPTIMIZE_CFLAGS="$OPTIMIZE_CFLAGS "
elif [ $ARCH == "arm64" ]
then
    SYSROOT=$ARM64_SYSROOT
    HOST=aarch64-linux-android
    CROSS_PREFIX=$ARM64_PREBUILT/bin/$HOST-
elif [ $ARCH == "x86_64" ]
then
    SYSROOT=$X86_64_SYSROOT
    HOST=x86_64-linux-android
    CROSS_PREFIX=$X86_64_PREBUILT/bin/$HOST-
elif [ $ARCH == "i686" ]
then
    SYSROOT=$X86_SYSROOT
    HOST=i686-linux-android
    CROSS_PREFIX=$X86_PREBUILT/bin/$HOST-
# elif [ $ARCH == "mips" ]
# then
#     SYSROOT=$MIPS_SYSROOT
#     HOST=mipsel-linux-android
#     CROSS_PREFIX=$MIPS_CROSS_PREFIX
# elif [ $ARCH == "mips64" ]
# then
#     SYSROOT=$MIPS64_SYSROOT
#     HOST=mips64el-linux-android
#     CROSS_PREFIX=$MIPS64_CROSS_PREFIX

fi

export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig"
export CPP="${CROSS_PREFIX}cpp"
export CXX="${CROSS_PREFIX}g++"
export CC="${CROSS_PREFIX}gcc"
export LD="${CROSS_PREFIX}ld"
export AR="${CROSS_PREFIX}ar"
export NM="${CROSS_PREFIX}nm"
export RANLIB="${CROSS_PREFIX}ranlib"
export LDFLAGS="-L$PREFIX/lib -fPIE -pie "
export CFLAGS="$OPTIMIZE_CFLAGS -I$PREFIX/include --sysroot=$SYSROOT -fPIE "
export CXXFLAGS="$CFLAGS "
export CPPFLAGS="--sysroot=$SYSROOT "
export STRIP=${CROSS_PREFIX}strip
export PATH="$PATH:$PREFIX/bin/"

if [ "$FLAVOR" = "full" ]; then 
    pushd x264-$LIBX264_VERSION
        ./configure \
            --cross-prefix=$CROSS_PREFIX \
            --sysroot=$SYSROOT \
            --host=$HOST \
            --enable-pic \
            --enable-static \
            --disable-shared \
            --disable-cli \
            --disable-opencl \
            --prefix=$PREFIX \
            $LIBX264_FLAGS

        make clean
        make -j8
        make install
    popd

    # Non-free
    pushd fdk-aac-${FDK_AAC_VERSION}
        ./configure \
            --prefix=$PREFIX \
            --host=$HOST \
            --enable-static \
            --disable-shared \
            --with-sysroot=$SYSROOT

        make clean
        make -j8
        make install
    popd

    pushd libpng-${LIBPNG_VERSION}
        ./configure \
            --prefix=$PREFIX \
            --host=$HOST \
            --with-pic \
            --enable-static \
            --disable-shared \
            --enable-arm-neon="$ARM_NEON" \
            --disable-shared

        make clean 
        make -j8
        make install
    popd

    pushd freetype-${LIBFREETYPE_VERSION}
        ./configure \
            --prefix=$PREFIX \
            --host=$HOST \
            --with-pic \
            --with-png=yes \
            --with-zlib=yes \
            --enable-static \
            --disable-shared 
        
        make clean
        make -j8
        make install
    popd

    # required by fontconfig
    pushd libuuid-${LIBUUID_VERSION}
        ./configure \
            --prefix=$PREFIX \
            --host=$HOST \
            --enable-static \
            --disable-shared 
        
        make clean
        make -j8
        make install
    popd

    # required by fontconfig
    pushd expat-${EXPAT_VERSION}
        ./configure \
            --prefix=$PREFIX \
            --host=$HOST \
            --with-pic \
            --enable-static \
            --disable-shared 

        make clean 
        make -j8
        make install
    popd

    pushd fontconfig-${LIBFONTCONFIG_VERSION}
        autoreconf -iv
        ./configure \
            --prefix=$PREFIX \
            --host=$HOST \
            --with-pic \
            --disable-libxml2 \
            --disable-iconv \
            --enable-static \
            --disable-shared \
            --disable-docs

        make clean
        make -j8
        make install
    popd
fi;


pushd opus-${OPUS_VERSION}
./configure \
    --prefix=$PREFIX \
    --host=$HOST \
    --enable-static \
    --disable-shared \
    --disable-doc \
    --disable-extra-programs

make clean
make -j8
make install V=1
popd

pushd lame-${LAME_VERSION}
./configure \
    --prefix=$PREFIX \
    --host=$HOST \
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
    --host=$HOST \
    --enable-static \
    --disable-shared

make clean
make -j8
make install
popd

pushd libogg-${LIBOGG_VERSION}
./configure \
    --prefix=$PREFIX \
    --host=$HOST \
    --enable-static \
    --disable-shared \
    --with-sysroot=$SYSROOT

make clean
make -j8
make install
popd

pushd libvorbis-${LIBVORBIS_VERSION}
./configure \
    --prefix=$PREFIX \
    --host=$HOST \
    --enable-static \
    --disable-shared \
    --with-sysroot=$SYSROOT \
    --with-ogg=$PREFIX

make clean
make -j8
make install
popd

# (wget --no-check-certificate https://raw.githubusercontent.com/FFmpeg/gas-preprocessor/master/gas-preprocessor.pl && \
#     chmod +x gas-preprocessor.pl && \
#     sudo mv gas-preprocessor.pl /usr/bin) || exit 1
pushd ffmpeg-$FFMPEG_VERSION

if [ $ARCH == "native" ] 
then
    CROSS_COMPILE_FLAGS=
else 
    CROSS_COMPILE_FLAGS="--target-os=linux \
        --arch=$ARCH \
        --cross-prefix=$CROSS_PREFIX \
        --enable-cross-compile \
        --sysroot=$SYSROOT"
fi

if [ "$FLAVOR" = "full" ]; then
    # Build - FULL version
    ./configure --prefix=$PREFIX \
        $CROSS_COMPILE_FLAGS \
        --pkg-config=$(which pkg-config) \
        --pkg-config-flags="--static" \
        --enable-pic \
        --enable-small \
        --enable-gpl \
        --enable-nonfree \
        \
        --disable-shared \
        --enable-static \
        \
        --enable-ffmpeg \
        --disable-ffplay \
        --disable-ffprobe \
        --disable-ffserver \
        \
        --enable-libshine \
        --enable-libmp3lame \
        --enable-libopus \
        --enable-libvorbis \
        --enable-libx264 \
        --enable-libfdk-aac \
        --enable-bsf=aac_adtstoasc \
        --enable-openssl \
        --enable-libfreetype  \
        --enable-libfontconfig \
        --enable-zlib \
        \
        --disable-doc \
        $ADDITIONAL_CONFIGURE_FLAG
else 
    # Build - LITE version
    ./configure --prefix=$PREFIX \
        $CROSS_COMPILE_FLAGS \
        --pkg-config=$(which pkg-config) \
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
        --disable-demuxers \
        --disable-muxers \
        --enable-demuxer='aac,avi,dnxhd,flac,flv,gif,h261,h263,h264,image2,matroska,webm,mov,mp3,mp4,mpeg,ogg,srt,wav,webvtt,gif,image2,image2pipe,mjpeg' \
        --enable-muxer='3gp,dnxhd,flac,flv,gif,image2,matroska,webm,mov,mp3,mp4,mpeg,ogg,opus,srt,wav,webvtt,ipod,gif,image2,image2pipe,mjpeg' \
        \
        --disable-encoders \
        --disable-decoders \
        --enable-encoder='aac,dnxhd,flac,flv,gif,libmp3lame,libopus,libshine,libvorbis,mpeg4,png,mjpeg,gif,srt,subrip,webvtt' \
        --enable-decoder='aac,aac_at,aac_fixed,aac_latm,dnxhd,flac,flv,h261,h263,h263i,h263p,h264,vp8,vp9,libopus,libvorbis,mp3,mpeg4,wavpack,png,mjpeg,gif,pcm_s16le,pcm_s16be,rawvideo,srt,webvtt' \
        \
        --enable-libshine \
        --enable-libmp3lame \
        --enable-libopus \
        --enable-libvorbis \
        --enable-bsf=aac_adtstoasc \
        \
        --disable-doc \
        $ADDITIONAL_CONFIGURE_FLAG
fi;

make clean
make -j8
make install V=1

mkdir -p $DESTINATION_FOLDER/$FLAVOR/
cp $PREFIX/bin/ffmpeg $DESTINATION_FOLDER/$FLAVOR/

popd
}

ARM_NEON="no"
if [ $TARGET == 'arm-v7n' ]; then
    #arm v7n
    CPU=armv7-a
    ARCH=arm
    OPTIMIZE_CFLAGS="-mfloat-abi=softfp -mfpu=neon -marm -mtune=cortex-a8 -march=$CPU -Os -O3"
    ADDITIONAL_CONFIGURE_FLAG="--enable-neon "
    LIBX264_FLAGS=
    cp -a $OPENSSL_PREBUILT_FOLDER/android/openssl-armeabi-v7a/. $PREFIX
    ARM_NEON="yes"    
    build_one
elif [ $TARGET == 'arm64-v8a' ]; then
    #arm64-v8a
    CPU=armv8-a
    ARCH=arm64
    OPTIMIZE_CFLAGS="-march=$CPU -Os -O3"
    ADDITIONAL_CONFIGURE_FLAG=
    LIBX264_FLAGS=
    cp -a $OPENSSL_PREBUILT_FOLDER/android/openssl-arm64-v8a/. $PREFIX
    build_one
elif [ $TARGET == 'x86_64' ]; then
    #x86_64
    CPU=x86-64
    ARCH=x86_64
    OPTIMIZE_CFLAGS="-fomit-frame-pointer -march=$CPU -Os -O3"
    ADDITIONAL_CONFIGURE_FLAG=
    LIBX264_FLAGS=
    cp -a $OPENSSL_PREBUILT_FOLDER/android/openssl-x86_64/. $PREFIX
    build_one
elif [ $TARGET == 'i686' ]; then
    #x86
    CPU=i686
    ARCH=i686
    OPTIMIZE_CFLAGS="-fomit-frame-pointer -march=$CPU -Os -O3"
    # disable asm to fix 
    ADDITIONAL_CONFIGURE_FLAG='--disable-asm' 
    LIBX264_FLAGS="--disable-asm"
    cp -a $OPENSSL_PREBUILT_FOLDER/android/openssl-x86/. $PREFIX
    build_one
elif [ $TARGET == 'armv7-a' ]; then
    # armv7-a
    CPU=armv7-a
    ARCH=arm
    OPTIMIZE_CFLAGS="-mfloat-abi=softfp -marm -march=$CPU -Os -O3 "
    ADDITIONAL_CONFIGURE_FLAG=
    LIBX264_FLAGS=
    cp -a $OPENSSL_PREBUILT_FOLDER/android/openssl-armeabi-v7a/. $PREFIX
    build_one
elif [ $TARGET == 'arm' ]; then
    #arm
    CPU=armv5te
    ARCH=arm
    OPTIMIZE_CFLAGS="-march=$CPU -Os -O3 "
    ADDITIONAL_CONFIGURE_FLAG=
    LIBX264_FLAGS="--disable-asm"
    cp -a $OPENSSL_PREBUILT_FOLDER/android/openssl-armeabi/. $PREFIX
    build_one
elif [ $TARGET == 'native' ]; then
    # host = current machine
    CPU=x86-64
    ARCH=native
    OPTIMIZE_CFLAGS="-O2 -pipe -march=native"
    ADDITIONAL_CONFIGURE_FLAG=
    LIBX264_FLAGS=
    build_one
else
    echo "Unknown target: $TARGET"
    exit 1
fi

