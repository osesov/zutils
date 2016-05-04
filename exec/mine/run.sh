#!/bin/sh
configuration=$1

source ./support_script.sh

check

rm -f /mnt/flash/dhcpc/*eth1*

export TZ=EST+5EDT,M3.2.0/2,M11.1.0/2

RAMDISK_PATH=/tmp/ramdisk
RAMDISK_SIZE=25600k
RAMDISK_MODE=01777

if [ -n "$RAMDISK_PATH" ]; then
    echo "Mount $RAMDISK_PATH virtual filesystem"

    if mkdir -p $RAMDISK_PATH  &&  mount -t tmpfs -o size=${RAMDISK_SIZE:-25000k},${RAMDISK_MODE:+mode=$RAMDISK_MODE} tmpfs $RAMDISK_PATH; then
        echo mouting ramdisk suuceeded
        export SUPERVISOR_TEMP_DIRECTORY_PATH=$RAMDISK_PATH
    else
        echo mouting ramdisk failed
        export SUPERVISOR_TEMP_DIRECTORY_PATH=
    fi
else
    echo "Skip mounting ramdisk"
fi

if [ $configuration == "spb" ]; then
  echo "Synchronizing time"
  NTP="208.53.158.34"
  ping -c 3 $NTP
  date
  ./ntpclient -s -h $NTP
  sleep 1
  date
fi

export SKIA_ENABLE_KEY_SERVER=1
export SKIA_DISABLE_KEYBOARD=1
export DVBS_LOGGER_UPLOAD_INTERFACE=ETH

LOCAL_NFS_ROOT_DIR=/mnt/flash/zodiac/build

CONFIGS_DIR=$LOCAL_NFS_ROOT_DIR/home/zodiac
NFS_LIBS_DIR=$LOCAL_NFS_ROOT_DIR/usr/lib
NFS_BINS_DIR=$LOCAL_NFS_ROOT_DIR/usr/bin

PATH_ZODIAC_HOME=$CONFIGS_DIR
PATH_ZODIAC_STORE=/mnt/flash/zodiac

export PATH_ZODIAC_STORE_CAS=$PATH_ZODIAC_STORE/cas
export PATH_ZODIAC_STORE_SNMP=$PATH_ZODIAC_STORE/snmp

export SUPERVISOR_REBOOT_CONFIG_FILE=$PATH_ZODIAC_STORE/supervisor_reboot.yaml
export DSGCC_PROXY_CONFIG_FILE=$PATH_ZODIAC_HOME/DSG-CC_Proxy.yaml
export DVBS_IPC_CONFIG_FILE=$PATH_ZODIAC_HOME/ipc.yaml
export DVBS_NETWORK_CONFIG_FILE=$PATH_ZODIAC_HOME/network.yaml
export EAS_CONFIG_FILE=$PATH_ZODIAC_HOME/EAS.yaml
export CAROUSELS_CONFIG_FILE=$PATH_ZODIAC_HOME/carousels.yaml
export DVBS_CONFIG_FILE=$PATH_ZODIAC_HOME/dvbs.yaml
export DVBS_NVM_CONFIG_FILE=$PATH_ZODIAC_STORE/dvbs_nvm.yaml
export SKIA_KEYBOARD_LOCATION=$PATH_ZODIAC_HOME/keyboard
export SNMPCONFPATH=$PATH_ZODIAC_HOME
export POWERUP_NVM_SETTINGS_DIRECTORY=$PATH_ZODIAC_STORE/settings
export NCAS_CERTIFICATE_FILE=$PATH_ZODIAC_HOME/cas/cbvs24n.pem
export dal_splash_image=$PATH_ZODIAC_HOME/boot/splash_screen.jpg
export DVBS_LOG_SETTINGS_NVM_PATH=$PATH_ZODIAC_STORE/logger.cfg
export DVBS_DUMP_DIRECTORY_PATH=$PATH_ZODIAC_STORE/dumps
export DVBS_REBOOT_LOOP_COUNT_FILE=$PATH_ZODIAC_STORE/reboot_loop_count
export LD_BIND_NOW=1
export DVBS_SUPERVISOR_DONT_HANDLE_SIGNALS=1
export CMD2K_DEBUG=1
export DVBS_LOG_LEVEL=6
export hdmi_i2c_software_mode=n
export SUPERVISOR_CONFIG_FILE=$PATH_ZODIAC_HOME/supervisor_$configuration.yaml

if [ $configuration == "nodal_nfs" ]; then
  export POWERUP_DEFAULT_NETWORK=RF
  export POWERUP_SETTINGS_FILE=$PATH_ZODIAC_HOME/settings.ini
  export DPI_CONTAINER_CONFIG_PATH=$PATH_ZODIAC_HOME/dvbs.yaml
  export POWERUP_PROFILE_INI=$PATH_ZODIAC_HOME/profile.ini
  export NCAS_HOST_APP_CONFIG_FILE=$PATH_ZODIAC_HOME/ncas_host_app.yaml
fi
if [ $configuration == "spb" ]; then
  export POWERUP_DEFAULT_NETWORK=ETH
  export DVBS_CONFIG_FILE=$PATH_ZODIAC_HOME/dvbs_$configuration.yaml
  export POWERUP_SETTINGS_FILE=settings_$configuration.ini
  export POWERUP_PROFILE_INI=profile_$configuration.ini
fi
if [ $configuration == "spb_nodal" ]; then
  export POWERUP_DEFAULT_NETWORK=ETH
  export DVBS_CONFIG_FILE=$PATH_ZODIAC_HOME/dvbs_spb.yaml
  export POWERUP_SETTINGS_FILE=$PATH_ZODIAC_HOME/settings_spb.ini
  export POWERUP_PROFILE_INI=$PATH_ZODIAC_HOME/profile_spb.ini
  export SUPERVISOR_CONFIG_FILE=$PATH_ZODIAC_HOME/supervisor_spb.yaml
fi
if [ $configuration == "nfs_li" ]; then
  export POWERUP_SETTINGS_FILE=settings_li.ini
  export POWERUP_PROFILE_INI=profile_li.ini
fi

echo "Making Directories"
mkdir -p $PATH_ZODIAC_STORE
mkdir -p $PATH_ZODIAC_STORE_CAS
mkdir -p $PATH_ZODIAC_STORE_SNMP
mkdir -p $DVBS_DUMP_DIRECTORY_PATH

if [ -h $LOCAL_NFS_ROOT_DIR ]; then
    rm $LOCAL_NFS_ROOT_DIR
fi
ln -fs `pwd`/../../ $LOCAL_NFS_ROOT_DIR

export LD_LIBRARY_PATH=$NFS_LIBS_DIR:$LD_LIBRARY_PATH
export DAL_LD_LIBRARY_PATH=$NFS_LIBS_DIR
export LD_PRELOAD=$NFS_LIBS_DIR/libresolv-wrapper.so
export SUPERVISOR_VERSION=`cat $CONFIGS_DIR/version.txt`

echo "Starting Supervisor version: $SUPERVISOR_VERSION"
stty eof undef

if [ -e $DVBS_REBOOT_LOOP_COUNT_FILE ]; then
    counter=`cat $DVBS_REBOOT_LOOP_COUNT_FILE`

    if [ $counter -ge 3 ]; then
        echo "Reboot count $counter, will force emergengcy standby!"

        export DVBS_EMERGENCY_STANDBY=1
    fi
fi

if [ -f $SUPERVISOR_REBOOT_CONFIG_FILE ]; then
    echo $SUPERVISOR_REBOOT_CONFIG_FILE
    kill_counter=`grep 'reboots_count: ' $SUPERVISOR_REBOOT_CONFIG_FILE | grep -o -E [0-9]+`
    echo "Kill counter $kill_counter"
    ((kill_counter++))
    echo "Kc $kill_counter"
else
    echo "Reboot config not found"
    kill_counter=1
fi

if [ $configuration == "nodal_nfs" -o $configuration == "spb_nodal" ]; then
  cd $NFS_BINS_DIR
  $NFS_BINS_DIR/supervisor $NFS_BINS_DIR/powerup-launcher
else
  cd $PATH_ZODIAC_STORE
  $NFS_BINS_DIR/supervisor
fi

EXIT_CODE=$?
EXIT_TIME=`date`

echo "Supervisor has crashed at $EXIT_TIME, exit code $EXIT_CODE"

echo "last_reboot:
    reason: 0
    subreason: $EXIT_CODE
    time: $EXIT_TIME
reboots_count: $kill_counter
" > $SUPERVISOR_REBOOT_CONFIG_FILE

if [ -e $DVBS_REBOOT_LOOP_COUNT_FILE ]; then
    counter=`cat $DVBS_REBOOT_LOOP_COUNT_FILE`
    ((counter++))
else
    counter=1
fi

echo "New reboot loop count $counter"

echo "$counter" > $DVBS_REBOOT_LOOP_COUNT_FILE

