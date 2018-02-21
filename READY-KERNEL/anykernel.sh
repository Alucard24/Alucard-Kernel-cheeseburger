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
do.system_blobs=1
device.name1=OnePlus5
device.name2=cheeseburger
device.name3=OnePlus5T
device.name4=dumpling
} # end properties

# shell variables
block=/dev/block/bootdevice/by-name/boot;
is_slot_device=0;
ramdisk_compression=auto;


## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. /tmp/anykernel/tools/ak2-core.sh;


## AnyKernel file attributes
# set permissions/ownership for included ramdisk files
chmod -R 750 $ramdisk/*;
chmod 644 $ramdisk/modules/*;
chown -R root:root $ramdisk/*;


## AnyKernel install
# alert of unsupported Android version
android_ver=$(grep "^ro.build.version.release" /system/build.prop | cut -d= -f2);
case "$android_ver" in
  "8.0.0"|"8.1.0") support_status="supported";;
  *) support_status="unsupported";;
esac;
ui_print " ";
ui_print "Running Android $android_ver..."
ui_print "This kernel is $support_status for this version!";

userflavor="$(grep "^ro.build.user" /system/build.prop | cut -d= -f2):$(grep "^ro.build.flavor" /system/build.prop | cut -d= -f2)";
case "$userflavor" in
  "OnePlus:OnePlus5-user"|"OnePlus:OnePlus5T-user")
    os="oos";
    os_string="OxygenOS";;
  *)
    os="custom";
    os_string="a custom ROM";;
esac;
ui_print " ";
ui_print "You are on $os_string!";

dump_boot;

# begin ramdisk changes

insert_line default.prop "ro.sys.fw.bg_apps_limit=60" before "ro.secure=1" "ro.sys.fw.bg_apps_limit=60";

# init.rc
insert_line init.rc "init.qcom.power.rc" after "import /init.usb.rc" "import /init.qcom.power.rc";

if [ "$os" == "oos" ]; then
  # sepolicy
  $bin/sepolicy-inject -s init -t rootfs -c file -p execute_no_trans -P sepolicy;
  $bin/sepolicy-inject -s init -t rootfs -c system -p module_load -P sepolicy;
  $bin/sepolicy-inject -s init -t system_file -c file -p mounton -P sepolicy;
  $bin/sepolicy-inject -s init -t vendor_configs_file -c file -p mounton -P sepolicy;
  $bin/sepolicy-inject -s init -t vendor_file -c file -p mounton -P sepolicy;
  $bin/sepolicy-inject -s modprobe -t rootfs -c system -p module_load -P sepolicy;

  # sepolicy_debug
  $bin/sepolicy-inject -s init -t rootfs -c file -p execute_no_trans -P sepolicy_debug;
  $bin/sepolicy-inject -s init -t rootfs -c system -p module_load -P sepolicy_debug;
  $bin/sepolicy-inject -s init -t system_file -c file -p mounton -P sepolicy_debug;
  $bin/sepolicy-inject -s init -t vendor_configs_file -c file -p mounton -P sepolicy_debug;
  $bin/sepolicy-inject -s init -t vendor_file -c file -p mounton -P sepolicy_debug;
  $bin/sepolicy-inject -s modprobe -t rootfs -c system -p module_load -P sepolicy_debug

  # Remove suspicious OnePlus services
  remove_section init.oem.rc "service OPNetlinkService" "seclabel"
  remove_section init.oem.rc "service wifisocket" "seclabel"
  remove_section init.oem.rc "service oemsysd" "seclabel"
  remove_section init.oem.rc "service oem_audio_device" "oneshot"
  remove_section init.oem.rc "service smartadjust" "seclabel"
  remove_section init.oem.rc "service atrace" "seclabel"
  remove_section init.oem.rc "service sniffer_set" "seclabel"
  remove_section init.oem.rc "service sniffer_start" "seclabel"
  remove_section init.oem.rc "service sniffer_stop" "seclabel"
  remove_section init.oem.rc "service tcpdump-service" "seclabel"
  remove_section init.oem.debug.rc "service oemlogkit" "socket oemlogkit"
  remove_section init.oem.debug.rc "service dumpstate_log" "seclabel"
  remove_section init.oem.debug.rc "service oemasserttip" "disabled"
fi

# end ramdisk changes

write_boot;

## end install

