#!/bin/sh

LD_LIBRARY_PATH=
PATH=/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/opt/bin:/opt/sbin


echo "Entware to entware-ng upgrade..."
echo "Trying to stop running services..."
/opt/etc/init.d/rc.unslung stop
## get installed packages list
installed_pkgs=$(opkg list_installed | grep -v ^opkg | cut -d ' ' -f 1)
echo "The following packages will be reinstalled after upgrade. Some of them may require re-configuration:"
echo $installed_pkgs
opkg --force-removal-of-essential-packages --force-depends remove $installed_pkgs
rm -f /opt/usr/lib/locale/locale-archive
## now we will setup entware-ng
CURARCH="armv7"
DLOADER="ld-linux.so.3"
URL="http://entware.zyxmon.org/binaries/$CURARCH/installer/"
wget $URL/opkg -O /opt/bin/opkg
chmod +x /opt/bin/opkg
wget $URL/opkg.conf -O /opt/etc/opkg.conf
wget $URL/ld-2.22.so -O /opt/lib/ld-2.22.so
wget $URL/libc-2.22.so -O/opt/lib/libc-2.22.so
wget $URL/libgcc_s.so.1 -O /opt/lib/libgcc_s.so.1
cd /opt/lib
chmod +x ld-2.22.so
ln -s ld-2.22.so $DLOADER
ln -s libc-2.22.so libc.so.6
echo "Info: Upgrading existing packages..."
/opt/bin/opkg update
/opt/bin/opkg --force-reinstall install $installed_pkgs
/opt/bin/opkg install entware-opt
#the order of packages may cause some of the binaries/symlinks be overwritten. So
#make sure find binary is used from findutils
/opt/bin/opkg install --force-reinstall findutils
#download locale-archive if it was not created (not enough memory) by locales.ipk
if [ ! -f /opt/usr/lib/locale/locale-archive ]
then
        wget http://entware.zyxmon.org/binaries/other/locale-archive -O /opt/usr/lib/locale/locale-archive
fi

echo "Reinstallation is finished"
echo "Please reboot your device to finish upgrade"
echo "Warning: some packages need to be reconfigured!"