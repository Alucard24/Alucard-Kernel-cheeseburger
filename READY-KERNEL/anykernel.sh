# AnyKernel2 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# EDIFY properties
properties() {
kernel.string=AlucardKernelEAS by alucard24 @ xda-developers
do.devicecheck=1
do.initd=0
do.modules=1
do.cleanup=1
do.cleanuponabort=1
do.system_blobs=0
device.name1=OnePlus5
device.name2=cheeseburger
}

# shell variables
block=/dev/block/bootdevice/by-name/boot;
is_slot_device=0;

## end setup

# import patching functions/variables - see for reference
. /tmp/anykernel/tools/ak2-core.sh;

## AnyKernel permissions
# set permissions for included ramdisk files
chmod -R 755 $ramdisk

## AnyKernel install
dump_boot;

# begin ramdisk changes

# init.rc
backup_file init.rc
insert_line init.rc "init.qcom.power.rc" after "import /init.environ.rc" "import /init.qcom.power.rc\n";

# end ramdisk changes

write_boot;

## end install
