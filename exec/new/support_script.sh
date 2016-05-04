#!/bin/sh

# Support functions
function help()
{
        echo "${0##*/}: run NFS build in different configuration."
        echo ""
        echo "Usage: $0 <configuration>"
        echo ""
        echo "Where configuration has following format <dalmanager_load_location>_<powerup_load_location>"
        echo "List of supported configurations"
        echo " - nodal_nfs / black / p - start powerup-launcher from NFS without DALManager (~ run-powerup.sh)"
        echo " - nfs_nfs   / red       - start build from NFS. supervisor.cfg, DALManager, group.cfg, powerup binaries are located at NFS"
        echo " - nfs_dal   / blue      - start NFS DALManager, load powerup from DAL group"
        echo " - dal_dal   / green     - start build from DAL"
        echo " - oob_dal   / white / s - start build from DAL (~ run-supervisor.sh)"
        echo " - spb       / pink      - start build inside SPB network. DALManager and PowerUp binaries would be taken from NFS"
        echo " - spb_dev   / orange    - start build inside SPB network with developer settings. DALManager and PowerUp binaries would be taken from NFS"
        echo " - spb_nodal             - start build inside SPB network. start powerup-launcher from NFS without DALManager"
        echo " - dal_li                - start build in LI network, with supervisor.cfg, version.cfg from 254 DAL group"
        echo " - nfs_li                - start build in LI network, fully from NFS"
        echo ""
        echo "Exit status is set to non zero if any errors occur."
        echo ""
        echo "Example:"
        echo " $ ${0##*/} nfs_nfs"
        exit 0
}

function check_arch()
{
arch=`uname -m`

for i in i686 x86_64 ; do
   if [ $arch == $i ]; then
      echo "arch $arch is not premitted"
      exit 1
   fi
done
}

function check()
{
check_arch

if [ -z $configuration ]; then
   help
fi

#specify confs
confs[0]="nodal_nfs"
confs[1]="nfs_nfs"
confs[2]="nfs_dal"
confs[3]="dal_dal"
confs[4]="oob_dal"
confs[5]="spb"
confs[6]="spb_dev"
confs[7]="dal_li"
confs[8]="nfs_li"
confs[9]="spb_nodal"

#specify aliases
nodal_nfs[0]="black"; nodal_nfs[1]="p"
nfs_nfs[0]="red"
nfs_dal[0]="blue"
dal_dal[0]="green"
oob_dal[0]="white"; oob_dal[1]="s"
spb[0]="pink"
spb_dev[0]="orange"


conf_exists="false"

for conf in ${confs[*]} ; do
    eval aliases="\${$conf[*]}"
    for a in $aliases; do
        if [ $configuration == $a ]; then
            configuration=$conf
        fi
    done

    if [ $configuration == $conf ]; then
        conf_exists="true"
    fi
done

if [ $conf_exists == "false" ]; then
   echo "unable to find valid configuration"
   help
fi

echo "configuration exists: $conf_exists"

}
