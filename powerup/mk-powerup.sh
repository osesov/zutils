orig=/mnt/nfs/bin/autobuild-trunk-dev/
build=/mnt/nfs/bin/olegs/dist/build
mkdir powerup
mkdir powerup/usr/
mkdir powerup/usr/bin/
mkdir powerup/usr/lib/


ln -s $build/DALManager					powerup/usr/bin/DALManager
ln -s $build/libbreakpad_client.so			powerup/usr/lib/libbreakpad_client.so
ln -s $build/libcarousels.so				powerup/usr/lib/libcarousels.so
ln -s $build/libcurl.so					powerup/usr/lib/libcurl.so
ln -s $build/libdc.so					powerup/usr/lib/libdc.so
ln -s $build/libdts.so					powerup/usr/lib/libdts.so
ln -s $build/libdvbs.so					powerup/usr/lib/libdvbs.so
ln -s $build/libekg.so					powerup/usr/lib/libekg.so
ln -s $build/libfreetype.so				powerup/usr/lib/libfreetype.so
ln -s $build/libipc.so					powerup/usr/lib/libipc.so
ln -s $build/libipg.so					powerup/usr/lib/libipg.so
ln -s $build/libjpeg.so					powerup/usr/lib/libjpeg.so
ln -s $build/libnetsnmp.so				powerup/usr/lib/libnetsnmp.so
ln -s $build/libnetsnmpagent.so				powerup/usr/lib/libnetsnmpagent.so
ln -s $build/libnetsnmphelpers.so			powerup/usr/lib/libnetsnmphelpers.so
ln -s $build/libnetsnmpmibs.so				powerup/usr/lib/libnetsnmpmibs.so
ln -s $build/libns.so					powerup/usr/lib/libns.so
ln -s $build/libpng.so					powerup/usr/lib/libpng.so
ln -s $build/libpowerup-api.so				powerup/usr/lib/libpowerup-api.so
ln -s $build/libpowerup.so				powerup/usr/lib/libpowerup.so
ln -s $build/libprofile.so				powerup/usr/lib/libprofile.so
ln -s $build/libsdv.so					powerup/usr/lib/libsdv.so
ln -s $build/libskia.so					powerup/usr/lib/libskia.so
ln -s $build/libtoopl.so				powerup/usr/lib/libtoopl.so
ln -s $build/libyaml.so					powerup/usr/lib/libyaml.so
ln -s $build/libz.so					powerup/usr/lib/libz.so
ln -s $build/libzvod.so					powerup/usr/lib/libzvod.so
ln -s $build/ncas_host_app				powerup/usr/bin/ncas_host_app
ln -s $build/powerup-launcher				powerup/usr/bin/powerup-launcher

ln -s $orig/ADS/					powerup/ADS
ln -s $orig/home					powerup/home
ln -s $orig/usr/bin/cbvs24n.pem				powerup/usr/bin/cbvs24n.pem
ln -s $orig/usr/bin/history				powerup/usr/bin/history
ln -s $orig/usr/bin/libncas_module_c5320-d.so.ncf	powerup/usr/bin/libncas_module_c5320-d.so.ncf
ln -s $orig/usr/bin/libncas_module_c5320.so.ncf		powerup/usr/bin/libncas_module_c5320.so.ncf
ln -s $orig/usr/bin/ntpclient				powerup/usr/bin/ntpclient
ln -s $orig/usr/bin/run-powerup.sh			powerup/usr/bin/run-powerup.sh
ln -s $orig/usr/bin/run-supervisor.sh			powerup/usr/bin/run-supervisor.sh
ln -s $orig/usr/bin/run_dvbs_framework.sh		powerup/usr/bin/run_dvbs_framework.sh
ln -s $orig/usr/bin/strace				powerup/usr/bin/strace
ln -s $orig/usr/bin/supervisor				powerup/usr/bin/supervisor
ln -s $orig/usr/bin/update_hosts.sh			powerup/usr/bin/update_hosts.sh
ln -s $orig/usr/bin/zodiac				powerup/usr/bin/zodiac
ln -s $orig/version.txt					powerup/version.txt

