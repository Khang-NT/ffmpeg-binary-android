#!/bin/bash

set -e
set -x

if [ "$NDK" = "" ] || [ ! -d $NDK ]; then
	echo "NDK variable not set or path to NDK is invalid, exiting..."
	exit 1
fi

export WORKING_DIR=`pwd`
export BUILD_DIR="$WORKING_DIR/build"

TARGET_ARMEABI_DIR=$BUILD_DIR/armeabi
TARGET_ARMEABIV7A_DIR=$BUILD_DIR/armeabi-v7a
TARGET_ARMEABIV7N_DIR=$BUILD_DIR/armeabi-v7-neon
TARGET_X86_DIR=$BUILD_DIR/x86
TARGET_MIPS_DIR=$BUILD_DIR/mips
TARGET_MIPS64_DIR=$BUILD_DIR/mips64
TARGET_X86_64_DIR=$BUILD_DIR/x86_64
TARGET_ARMEABI_64_DIR=$BUILD_DIR/arm64-v8a

cd $WORKING_DIR
./build_ffmpeg.sh i686 $TARGET_X86_DIR

cd $WORKING_DIR
./build_ffmpeg.sh x86_64 $TARGET_X86_64_DIR

cd $WORKING_DIR
./build_ffmpeg.sh arm $TARGET_ARMEABI_DIR

cd $WORKING_DIR
./build_ffmpeg.sh armv7-a $TARGET_ARMEABIV7A_DIR

cd $WORKING_DIR
./build_ffmpeg.sh arm-v7n $TARGET_ARMEABIV7N_DIR

cd $WORKING_DIR
./build_ffmpeg.sh arm64-v8a $TARGET_ARMEABI_64_DIR

cd $WORKING_DIR
./build_ffmpeg.sh mips $TARGET_MIPS_DIR

cd $WORKING_DIR
./build_ffmpeg.sh mips64 $TARGET_MIPS64_DIR

echo "Build complete."
exit 0