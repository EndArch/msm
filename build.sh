#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2018 Raphiel Rollerscaperers (raphielscape)
# Copyright (C) 2018 Rama Bondan Prakoso (rama982)
# Copyright (C) 2019 Joshua Primero (Jprimero15)
# Android Kernel Build Script

# Main environtment
KERNEL_DIR=$PWD
BUILD_DATE="$(date +"%Y%m%d")"
KERNEL_VERSION="XI"
OUTDIR=$KERNEL_DIR/out
RELEASE_DIR=$KERNEL_DIR/release
AK3_DIR=$KERNEL_DIR/pine_anykernel
KERN_IMG=$OUTDIR/arch/arm64/boot/Image.gz-dtb
VENDOR_MODULEDIR=$AK3_DIR/modules/vendor/lib/modules
CONFIG=legendary_pine_defconfig
PATH="${HOME}/clang/bin:${HOME}/gcc4/bin:${PATH}"

# Download our Anykernel for olive
rm -rf $AK3_DIR
git clone https://github.com/AndroJr7/pine_anykernel -b master $AK3_DIR
rm -rf $AK3_DIR/.git

# Build start
make O=$OUTDIR ARCH=arm64 $CONFIG

# Update kernel Version here
sed -i "s;Legendary-Kernel-V1; Legendary-Kernel-V$KERNEL_VERSION;" $OUTDIR/.config;

make -j$(nproc --all) O=$OUTDIR \
 		      ARCH=arm64 \
                      CC=clang \
                      DTC_EXT=dtc \
                      CLANG_TRIPLE=aarch64-linux-gnu- \
                      CROSS_COMPILE=aarch64-linux-android-

if ! [ -a $KERN_IMG ]; then
    echo "Build error!! Do clean boi"
    exit 1
fi

# For MIUI Build (Copy Modules)
# 
cd $KERNEL_DIR && rm -rf $AK3_DIR/zImage && rm -rf $AK3_DIR/modules/vendor/lib/modules/*.ko;
STRIP="${HOME}/gcc4/bin/$(echo "$(find "${HOME}/gcc4/bin" -type f -name "aarch64-*-gcc")" | awk -F '/' '{print $NF}' |\
            sed -e 's/gcc/strip/')"
for MODULES in $(find "${OUTDIR}" -name '*.ko'); do
    "${STRIP}" --strip-unneeded --strip-debug "${MODULES}"
    "${OUTDIR}"/scripts/sign-file sha512 \
            "${OUTDIR}/certs/signing_key.pem" \
            "${OUTDIR}/certs/signing_key.x509" \
            "${MODULES}"

    find "${OUTDIR}" -name '*.ko' -exec cp {} "${VENDOR_MODULEDIR}" \;
done

cd $AK3_DIR
cp $KERN_IMG $AK3_DIR/zImage

zip -r9 Legendary-V$KERNEL_VERSION-pine-$BUILD_DATE.zip * -x README.md Legendary-V$KERNEL_VERSION-pine-$BUILD_DATE.zip;
cd $KERNEL_DIR && rm -rf $AK3_DIR/zImage && rm -rf $AK3_DIR/modules/vendor/lib/modules/*.ko;

    if [ ! -d "$RELEASE_DIR" ]; then
        mkdir -p $RELEASE_DIR
    fi;

# Final Product for pine
mv $AK3_DIR/Legendary-V$KERNEL_VERSION-pine-$BUILD_DATE.zip $RELEASE_DIR;

echo "Flashable zip generated under /release folder.";
cd $KERNEL_DIR;
# Build end
