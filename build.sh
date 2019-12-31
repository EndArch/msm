#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2018 Raphiel Rollerscaperers (raphielscape)
# Copyright (C) 2018 Rama Bondan Prakoso (rama982)
# Copyright (C) 2019 Joshua Primero (Jprimero15)
# Android Kernel Build Script

# Main environtment
KERNEL_DIR=$PWD
BUILD_DATE="$(date +"%Y%m%d")"
LOLZ_VERSION="2"
OUTDIR=$KERNEL_DIR/out
RELEASE_DIR=$KERNEL_DIR/release
AK3_DIR=$KERNEL_DIR/olive_anykernel
KERN_IMG=$OUTDIR/arch/arm64/boot/Image.gz-dtb
VENDOR_MODULEDIR=$AK3_DIR/modules/vendor/lib/modules
CONFIG=lolz_olive_defconfig
PATH="${HOME}/clang/bin:${HOME}/gcc4/bin:${PATH}"

# Build start
make O=$OUTDIR ARCH=arm64 $CONFIG

# Update Lolz Version here
sed -i "s;Lolz-Kernel-V1; Lolz-Kernel-V$LOLZ_VERSION;" $OUTDIR/.config;

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
# Credit Adek Maulana <adek@techdro.id>
cd $KERNEL_DIR && rm -rf $AK3_DIR/zImage && rm -rf $AK3_DIR/modules/vendor/lib/modules/*;
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

zip -r9 LOLZ-V$LOLZ_VERSION-olive-$BUILD_DATE.zip * -x README.md LOLZ-V$LOLZ_VERSION-olive-$BUILD_DATE.zip;
cd $KERNEL_DIR && rm -rf $AK3_DIR/zImage && rm -rf $AK3_DIR/modules/vendor/lib/modules/*;

    if [ ! -d "$RELEASE_DIR" ]; then
        mkdir -p $RELEASE_DIR
    fi;

# Final Product boi
mv $AK3_DIR/LOLZ-V$LOLZ_VERSION-olive-$BUILD_DATE.zip $RELEASE_DIR;

echo "Flashable zip generated under /release folder.";
cd $KERNEL_DIR;
# Build end
