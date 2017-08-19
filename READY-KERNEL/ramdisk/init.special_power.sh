#!/system/bin/sh

################################################################################
# helper functions to allow Android init like script

function write() {
    echo -n $2 > $1
}

function copy() {
    cat $1 > $2
}

# macro to write pids to system-background cpuset
function writepid_sbg() {
    until [ ! "$1" ]; do
        echo -n $1 > /dev/cpuset/system-background/tasks;
        shift;
    done;
}

function writepid_top_app() {
    until [ ! "$1" ]; do
        echo -n $1 > /dev/cpuset/top-app/tasks;
        shift;
    done;
}
################################################################################

sleep 5

write /dev/cpuset/background/cpus 0-1
write /dev/cpuset/system-background/cpus 0-2

sleep 20

QSEECOMD=`pidof qseecomd`
THERMAL-ENGINE=`pidof thermal-engine`
TIME_DAEMON=`pidof time_daemon`
IMSQMIDAEMON=`pidof imsqmidaemon`
IMSDATADAEMON=`pidof imsdatadaemon`
DASHD=`pidof dashd`
CND=`pidof cnd`
DPMD=`pidof dpmd`
RMT_STORAGE=`pidof rmt_storage`
TFTP_SERVER=`pidof tftp_server`
NETMGRD=`pidof netmgrd`
IPACM=`pidof ipacm`
QTI=`pidof qti`
LOC_LAUNCHER=`pidof loc_launcher`
QSEEPROXYDAEMON=`pidof qseeproxydaemon`
IFAADAEMON=`pidof ifaadaemon`
LOGCAT=`pidof logcat`
LMKD=`pidof lmkd`
PERFD=`pidof perfd`
IOP=`pidof iop`
MSM_IRQBALANCE=`pidof msm_irqbalance`
SEEMP_HEALTHD=`pidof seemp_healthd`
ESEPMDAEMON=`pidof esepmdaemon`
WPA_SUPPLICANT=`pidof wpa_supplicant`

writepid_sbg $QSEECOMD
writepid_sbg $THERMAL-ENGINE
writepid_sbg $TIME_DAEMON
writepid_sbg $IMSQMIDAEMON
writepid_sbg $IMSDATADAEMON
writepid_sbg $DASHD
writepid_sbg $CND
writepid_sbg $DPMD
writepid_sbg $RMT_STORAGE
writepid_sbg $TFTP_SERVER
writepid_sbg $NETMGRD
writepid_sbg $IPACM
writepid_sbg $QTI
writepid_sbg $LOC_LAUNCHER
writepid_sbg $QSEEPROXYDAEMON
writepid_sbg $IFAADAEMON
writepid_sbg $LOGCAT
writepid_sbg $LMKD
writepid_sbg $PERFD
writepid_sbg $IOP
writepid_sbg $MSM_IRQBALANCE
writepid_sbg $SEEMP_HEALTHD
writepid_sbg $ESEPMDAEMON
writepid_sbg $WPA_SUPPLICANT
