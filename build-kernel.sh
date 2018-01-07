#!/bin/sh
clear

LANG=C

# What you need installed to compile
# gcc, gpp, cpp, c++, g++, lzma, lzop, ia32-libs flex

# What you need to make configuration easier by using xconfig
# qt4-dev, qmake-qt4, pkg-config

# toolchain is already exist and set! in kernel git. ../aarch64-linux-android-4.9/bin/

# location
KERNELDIR=$(readlink -f .);

KERNEL_CONFIG_FILE=alucard_defconfig;

echo "Initialising................."
if [ -e "$KERNELDIR"/READY-KERNEL/Image.gz-dtb ]; then
	rm "$KERNELDIR"/READY-KERNEL/Image.gz-dtb;
fi;
if [ -e "$KERNELDIR"/READY-KERNEL/modules/system/lib/modules/wlan.ko ]; then
	rm "$KERNELDIR"/READY-KERNEL/modules/system/lib/modules/*.ko;
fi;
if [ -e "$KERNELDIR"/arch/arm64/boot/Image.gz-dtb ]; then
	rm "$KERNELDIR"/arch/arm64/boot/Image.gz-dtb;
fi;

CHECK_ZIP=$(find READY-KERNEL/ -name *.zip | wc -l);
if [ "$CHECK_ZIP" -gt "0" ]; then
	rm READY-KERNEL/*.zip;
fi;

# check if .config exist before building
if [ ! -e "$KERNELDIR/.config" ]; then
	cp "$KERNELDIR"/arch/arm64/configs/"$KERNEL_CONFIG_FILE" "$KERNELDIR"/.config;
fi;

BUILD_NOW()
{
	PYTHON_CHECK=$(ls -la /usr/bin/python | grep python3 | wc -l);
	PYTHON_WAS_3=0;

	if [ "$PYTHON_CHECK" -eq "1" ] && [ -e /usr/bin/python2 ]; then
		if [ -e /usr/bin/python2 ]; then
			rm /usr/bin/python
			ln -s /usr/bin/python2 /usr/bin/python
			echo "Switched to Python2 for building kernel will switch back when done";
			PYTHON_WAS_3=1;
		else
			echo "You need Python2 to build this kernel. install and come back."
			exit 1;
		fi;
	else
		echo "Python2 is used! all good, building!";
	fi;

	# remove all old modules before compile
	for i in $(find "$KERNELDIR"/ -name "*.ko"); do
		rm -f "$i";
	done;

	# Idea by savoca
	NR_CPUS=$(grep -c ^processor /proc/cpuinfo)

	if [ "$NR_CPUS" -le "2" ]; then
		NR_CPUS=4;
		echo "Building kernel with 4 CPU threads";
	else
		echo "Building kernel with $NR_CPUS CPU threads";
	fi;

	# build kernel and modules
	time make ARCH=arm64 CROSS_COMPILE=../aarch64-linux-android-4.9/bin/aarch64-linux-android- -j $NR_CPUS

	cp "$KERNELDIR"/.config "$KERNELDIR"/arch/arm64/configs/"$KERNEL_CONFIG_FILE";

	if [ -e "$KERNELDIR"/arch/arm64/boot/Image.gz-dtb ]; then

		stat "$KERNELDIR"/arch/arm64/boot/Image.gz-dtb;

		# move the compiled Image.gz-dtb and modules into the READY-KERNEL working directory
		echo "Move compiled objects........"

		cp "$KERNELDIR"/arch/arm64/boot/Image.gz-dtb READY-KERNEL/Image.gz-dtb;

		for i in $(find "$KERNELDIR" -name '*.ko'); do
			cp -av "$i" READY-KERNEL/modules/system/lib/modules;
		done;

		chmod 755 READY-KERNEL/modules/system/lib/modules/*.ko

		if [ "$PYTHON_WAS_3" -eq "1" ]; then
			rm /usr/bin/python
			ln -s /usr/bin/python3 /usr/bin/python
		fi;

		# add kernel config to kernel zip for other devs
		cp "$KERNELDIR"/.config READY-KERNEL/config/;

		# create the flashable zip file from the contents of the READY-KERNEL directory
		cd READY-KERNEL/;
		echo "Creating flashable zip..........."
		zip -r Kernel-EAS-OP5-"$(date +"[%y-%m-%d]-[%H-%M]-O-PWR-CORE")".zip * -x@exclude.list >/dev/null
		cd $KERNELDIR;
		echo "Cleaning";
		rm "$KERNELDIR"/READY-KERNEL/Image.gz-dtb;
		rm "$KERNELDIR"/arch/arm64/boot/Image.gz-dtb;
		rm "$KERNELDIR"/READY-KERNEL/modules/system/lib/modules/*.ko;
		rm "$KERNELDIR"/READY-KERNEL/config/.config
		echo "All Done";
	else
		if [ "$PYTHON_WAS_3" -eq "1" ]; then
			rm /usr/bin/python
			ln -s /usr/bin/python3 /usr/bin/python
		fi;

		# with red-color
		echo -e "\e[1;31mKernel STUCK in BUILD! no Image.gz-dtb exist\e[m"
	fi;
}

BUILD_NOW;
