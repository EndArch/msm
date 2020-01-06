
#
# Custom kernel build script
#
# For Redmi 7A (pine)
#
KERNEL_DIR=$PWD
KERN_IMG=$KERNEL_DIR/arch/arm64/boot/Image.gz-dtb
BUILD_START=$(date +"%s")
blue='\033[0;34m'
cyan='\033[0;36m'
green='\e[0;32m'
yellow='\033[0;33m'
red='\033[0;31m'
nocol='\033[0m'
purple='\e[0;35m'
white='\e[0;37m'
DEVICE="pine"
J="-j32"


make $J clean mrproper

# Get Toolchain
Toolchain=$KERNEL_DIR/../Toolchain


 #android.googlesource.com/platform/prebuilts/gcc/linux-x86/arm64/aarch64-linux-android-4.9 -b android-9.0.0_r51 $Toolchain



# Modify the following variable if you want to build
export CROSS_COMPILE=$Toolchain/bin/aarch64-linux-android-
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_USER="Priyabrat1717"
export KBUILD_BUILD_HOST="Neutrino"
export USE_CCACHE=1
BUILD_DIR=$KERNEL_DIR/Anykernel_MIUI
VERSION=""
DATE=$(date -u +%Y%m%d-%H%M)
ZIP_NAME=Legendary _kernel-$DEVICE-$VERSION-$DATE

compile_kernel ()
{
echo -e "$cyan****************************************************"
echo "             Compiling Legendary ™ kernel        "
echo -e "****************************************************"
echo -e "$nocol"
rm -f $KERN_IMG
make pine_legendary_defconfig
make $J
echo -e "$nocol"
if ! [ -a $KERN_IMG ];
then
echo -e "$red Kernel Compilation failed! Fix the errors! $nocol"
fi


make_zip
}

make_zip ()
{
if [[ $( ls ${KERNEL_DIR}/arch/arm64/boot/Image.gz-dtb 2>/dev/null | wc -l ) != "0" ]]; then
	BUILD_RESULT_STRING="BUILD SUCCESSFUL"
	echo "Making Zip"
	rm $BUILD_DIR/*.zip
	rm $BUILD_DIR/Image.gz-dtb
	cp $KERNEL_DIR/arch/arm64/boot/zImage-dtb $BUILD_DIR/Image.gz-dtb
	cd $BUILD_DIR
	zip -r ${ZIP_NAME}.zip *
	cd $KERNEL_DIR
	rm -rf $KERNEL_DIR/out
	rm $BUILD_DIR/Image.gz-dtb
	make $J mrproper
else
    BUILD_RESULT_STRING="BUILD FAILED"
fi
}

case $1 in
clean)
make ARCH=arm64 $J clean mrproper
;;
*)
TC
compile_kernel
;;
esac
BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
if [[ "${BUILD_RESULT_STRING}" = "KERNEL TAILORED SUCCESSFULLY WITH ❤️ FOR REDMI 7A" ]]; then
echo -e "$cyan****************************************************************************************$nocol"
echo -e "$cyan*$nocol${red} ${BUILD_RESULT_STRING}$nocol"
echo -e "$cyan*$nocol$yellow Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.$nocol"
echo -e "$cyan*$nocol${blue} ZIP LOCATION: ${BUILD_DIR}/${ZIP_NAME}.zip$nocol"
echo -e "$cyan*$nocol${green} SIZE: $( du -h ${BUILD_DIR}/${ZIP_NAME}.zip | awk '{print $1}' )$nocol"
echo -e "$cyan****************************************************************************************$nocol"
fi


# Upload the Kernel zip to google drive if it's available
if [ -x "$(command -v gdrive)" ]; then
        echo -e "> Make sure you have setup gdrive CLI in your system before uploading..."
	echo -e "> Uploading Kernel zip to Google Drive..."
	        
                sudo gdrive upload ${BUILD_DIR}/${ZIP_NAME}.zip
	fi

