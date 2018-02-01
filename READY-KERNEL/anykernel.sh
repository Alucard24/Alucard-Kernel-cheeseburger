# AnyKernel2 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() {
kernel.string=AlucardKernelEAS by alucard24 @ xda-developers
do.devicecheck=1
do.modules=1
do.cleanup=1
do.cleanuponabort=1
device.name1=OnePlus5
device.name2=cheeseburger
device.name4=
device.name5=
} # end properties

# shell variables
block=/dev/block/bootdevice/by-name/boot;
is_slot_device=0;
ramdisk_compression=auto;

## end setup

## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. /tmp/anykernel/tools/ak2-core.sh;

## AnyKernel file attributes
# set permissions/ownership for included ramdisk files
chmod -R 750 $ramdisk/*;
chown -R root:root $ramdisk/*;

## AnyKernel install
dump_boot;

# begin ramdisk changes

# init.rc
insert_line init.rc "init.qcom.power.rc" after "import /init.usb.rc" "import /init.qcom.power.rc";

# end ramdisk changes

write_boot;

## end install
