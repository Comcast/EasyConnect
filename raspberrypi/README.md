
# Easy Connect Demo Setup

One of the Pis will be configured as a Wi-Fi client (the enrollee) and the other will be configured as an AP (the configurator).

Native Wi-Fi driver in Raspberry Pi 3 Model B+ doesn't support Easy Connect. We can either apply the Wi-Fi patches to make Easy Connect work in Raspberry Pi or use an external USB Wi-Fi dongle like Alpha Wi-Fi dongle (with Atheros AR9271 chip).

# Setup Raspberry Pi using external Wi-Fi dongle
### Setup RPI as STA
1. Install wpa_supplicant dependencies - libnl
2. Install wpa_supplicant v2.9
3. Execute following wpa_supplicant commands
```
  # Configure dpp bootstrap information
  sudo wpa_cli dpp_bootstrap_gen type=qrcode chan=81/1 mac=<Wi-Fi dongle’s MAC>

  # Retrieve dpp bootstrap URI
  sudo wpa_cli dpp_bootstrap_get_uri 1

  # Make client listen for dpp init in channel 1
  sudo wpa_cli dpp_listen 2412
```

### Setup RPI as AP
1. Install hostapd dependencies – openssl, dbus, libnl
2. Install hostapd v2.9
3. Execute following hostapd commands to add a configurator, pass dpp bootstrap URI and 
```
  # Add a dpp configurator
  sudo ./hostapd_cli dpp_configurator_add
      
  # Set the dpp bootstrap URI
  sudo ./hostapd_cli dpp_qr_code "DPP:C:81/1;M:b8:27:eb:5f:25:d3;K:MDkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDIgACbztq2A/7WMSr7XzTD+ibC1HIyxRPrfUlupi12qkabFw=;;"
      
  # dpp Init - 
  sudo ./hostapd_cli dpp_auth_init peer=1 conf=sta-psk ssid=4a414b455f3234 pass=6a616b6531323334 configurator=1
```

# Setup Raspberry Pi using native Wi-Fi module

Follow the below instructions to apply driver patch and userspace changes to make Easy Connect work in a Raspberry PI 3 Model B+ (using native Wi-Fi module).

After applying the patch you will be able to.

*   Run RPI 3B+ as a station that is capable of connecting to an AP both using:
    a) WPA2-PSK credentials configured by DPP and
    b) DPP connector based credentials configured by DPP.
*   Run RPI 3B+ as an Access point which is capable of configuring any client with WPA2-PSK credentials using the DPP mechanism without using protected management frame.

# Software specifications Used

* Linux Kernel Release version 4.19 => [https://github.com/raspberrypi/linux/](https://github.com/raspberrypi/linux/)
* Raspberry PI Raspbian OS and firmware => [https://downloads.raspberrypi.org/raspbian/images/raspbian-2019-04-09/](https://downloads.raspberrypi.org/raspbian/images/raspbian-2019-04-09/)
  * To download and flash the Raspbian OS, please refer this [link](https://www.raspberrypi.org/documentation/installation/installing-images/README.md).
  * For enabling ssh support please refer this [link](https://www.raspberrypi.org/documentation/remote-access/ssh/)
* Hostapd/wpa_supplicant 2.9 => [http://w1.fi/hostapd/](http://w1.fi/hostapd/)

# Setting up the build environment
To enable DPP in RPI 3 Model B+ wpa_supplicant, hostapd and other packages must be cross-compiled.

###  Build system info
Ubuntu 16.04 is used as the build system for this procedure
```
$ lsb_release –a 
No LSB modules are available. 
Distributor ID: Ubuntu 
Description:    Ubuntu 16.04.6 LTS 
Release:        16.04 
Codename:       xenial
```

### Packages to be installed
Install the below packages
```
$ sudo apt-get install git bc bison flex libssl-dev make autoconf
```

### Environment variables
```
# Create a separate workspace for this build
mkdir -p ~/project/rpi
cd ~/project/rpi

# Open env_setup.sh file using cat command
cat > env_setup.sh

# Copy paste the below contents and close the env_setup.sh file using - ‘Ctrl+D’ keys.
export RPI_ROOT=${PWD}
export RPI_ROOTFS=${RPI_ROOT}/rootfs
export RPI_TOOLS=${RPI_ROOT}/tools
export PATH=$PATH:${RPI_TOOLS}/arm-bcm2708/arm-linux-gnueabihf/bin
export CROSS=arm-linux-gnueabihf
export CC=${CROSS}-gcc
export LD=${CROSS}-ld
export AS=${CROSS}-as
export AR=${CROSS}-ar
export PKG_CONFIG_PATH=${RPI_ROOTFS}/lib/pkgconfig/
export LDFLAGS=-L${RPI_ROOTFS}/lib
export RPI_PKG_SRC=${RPI_ROOT}/src

# Source the script
. ./env_setup.sh
```

### Install Tool Chain
Download the tool chain via below link
```
git clone https://github.com/raspberrypi/tools.git
```

### Pre-requisite patches
Place the “EasyConnect-master.zip" file in “RPI_PKG_SRC” folder.
```
mkdir -p $RPI_PKG_SRC
cd $RPI_PKG_SRC
cp ~/Downloads/EasyConnect-master.zip $RPI_PKG_SRC

# Unzip the file EasyConnect-master.zip
unzip EasyConnect-master.zip 
```

# Cross compilation
For cross-compiling wpa_supplicant and hostapd, few packages must be compiled as it is dependent on them. Compile the kernel and other required packages in the following order.

## Kernel
```
# Switch to $RPI_PKG_SRC folder and download the kernel source code using below command.
cd $RPI_PKG_SRC
git clone --depth=1 --branch rpi-4.19.y https://github.com/raspberrypi/linux

# Switch to linux kernel folder
cd $RPI_PKG_SRC/linux

# Apply the patch
patch -p1 < $RPI_PKG_SRC/EasyConnect-master/raspberrypi/DPP_driver_Rel-V2.patch

# Export the below environmental variables
export KERNEL=kernel7
export ARCH=arm
export CROSS_COMPILE=arm-linux-gnueabihf-
export INSTALL_MOD_PATH=${RPI_ROOTFS}

# Use RPI 3B+ defconfig
make bcm2709_defconfig

# Build the kernel
make -j $(nproc)

# Install the kernel modules
make modules_install

# Unset the environment variables
unset KERNEL ARCH CROSS_COMPILE INSTALL_MOD_PATH
```

### Details of Driver patch(`DPP_driver_Rel-V2.patch`)
1) Support to send DPP OUI type action frame. (AP and client)
2) The action frames are sent by wlan0 instead of p2p-dev-wlan0. (AP and client)
3) Handled AKM cipher suite for DPP key management. (Client)
4) Adding DPP OUI in the valid OUI check. (AP)

## Openssl
```
# Switch to $RPI_PKG_SRC folder and download the openssl source code
cd $RPI_PKG_SRC
git clone --depth=1 --branch OpenSSL_1_0_2l https://github.com/openssl/openssl.git

# Switch to openssl source folder. Configure, compile and install it.
cd $RPI_PKG_SRC/openssl
./Configure --prefix=${RPI_ROOTFS} os/compiler:arm-linux-gnueabihf
make
make install
```

## Expat
```
# Switch to $RPI_PKG_SRC folder and download the expat source code
cd $RPI_PKG_SRC
wget https://github.com/libexpat/libexpat/releases/download/R_2_2_5/expat-2.2.5.tar.bz2
tar -axf expat-2.2.5.tar.bz2

# Switch to expat source folder. Configure, compile and install it.
cd $RPI_PKG_SRC/expat-2.2.5
./configure --host=arm-linux-gnueabihf --prefix=${RPI_ROOTFS} ac_cv_func_setpgrp_void=yes
make
make install
```

## D-Bus
```
# Switch to $RPI_PKG_SRC folder and download the D-Bus source code
cd $RPI_PKG_SRC
wget https://dbus.freedesktop.org/releases/dbus/dbus-1.12.8.tar.gz
tar -axf dbus-1.12.8.tar.gz

# Switch to dbus source folder. Configure, compile and install it.
cd $RPI_PKG_SRC/dbus-1.12.8
./configure --host=arm-linux-gnueabihf --prefix=${RPI_ROOTFS} CPPFLAGS=-I${RPI_ROOTFS}/include LDFLAGS=-L${RPI_ROOTFS}/lib EXPAT_CFLAGS=" " EXPAT_LIBS=-lexpat
make 
make install
```

## libnl
```
# Switch to $RPI_PKG_SRC folder and download the libnl source code
cd $RPI_PKG_SRC
git clone --depth=1 --branch libnl3_5_0 https://github.com/thom311/libnl.git

# Switch to libnl source folder. Configure, compile and install it.
cd $RPI_PKG_SRC/libnl
./autogen.sh
./configure --prefix=${RPI_ROOTFS} --host=arm-linux-gnueabihf
make 
make install
```

## wpa_supplicant
Ref: [http://w1.fi/cgit/hostap/plain/wpa_supplicant/README-DPP](http://w1.fi/cgit/hostap/plain/wpa_supplicant/README-DPP)
```
# Switch to $RPI_PKG_SRC folder and download the wpa_supplicant source code
cd $RPI_PKG_SRC
git clone --depth=1 --branch hostap_2_9 git://w1.fi/hostap.git

# Switch to wpa_supplicant folder
cd $RPI_PKG_SRC/hostap/wpa_supplicant

# Copy the defconfig
cp defconfig .config

# Make sure the below configurations has be enabled in .config file
CONFIG_DPP=y 
CONFIG_CTRL_IFACE_DBUS=y 
CONFIG_CTRL_IFACE_DBUS_NEW=y 
CONFIG_CTRL_IFACE_DBUS_INTRO=y

# Navigate to hostap folder and apply the patch
cd $RPI_PKG_SRC/hostap/ 
patch -p1 < $RPI_PKG_SRC/EasyConnect-master/raspberrypi/wpa_supplicant.diff

# Export the below environment variables
export CFLAGS=-I${RPI_ROOTFS}/include 
export DESTDIR=$RPI_ROOTFS

# Switch to wpa_supplicant folder. Compile and install it.
cd $RPI_PKG_SRC/hostap/wpa_supplicant
make 
make install

# Unset the environment variables
unset CFLAGS DESTDIR
```

### Details of userspace patch(`wpa_supplicant.diff`)
This patch is used as a temporay workaround to overcome some of the limitation of driver.
1) Forcefully use the user space 4-way handshake implementation.
2) Supplicant is given the enrollee capability in all cases.

## hostapd
```
# Switch to hostapd folder and configure the source code
cd $RPI_PKG_SRC/hostap/hostapd/

# Copy the defconfig 
cp defconfig .config

# Make sure the below configurations has be enabled in .config file
CONFIG_DPP=y 
CONFIG_INTERWORKING=y

# Export the below environment variables
export CFLAGS=-I${RPI_ROOTFS}/include
export DESTDIR=$RPI_ROOTFS

# Compile hostapd and install it
make 
make install

# Unset the environment variables
unset CFLAGS DESTDIR
```
# Binaries installation
Copy the linux kernel, modules, hostapd, wpa_supplicant and other binaries to the RPI that acts as a Wi-Fi AP
```
$ scp $RPI_ROOTFS/usr/local/bin/hostapd pi@<IP>:~/dpp_bin/ 
$ scp $RPI_ROOTFS/usr/local/bin/hostapd_cli pi@<IP>:~/dpp_bin/ 
$ scp $RPI_PKG_SRC/EasyConnect-master/raspberrypi/hostapd.conf pi@<IP>:~/dpp_bin/ 
$ scp $RPI_PKG_SRC/linux/arch/arm/boot/zImage pi@<IP>:~/dpp_bin/kernel-dpp.img  
$ cd $RPI_ROOTFS/lib/modules 
$ tar -acf 4.14.114-v7+.tar 4.14.114-v7+/ 
$ scp 4.14.114-v7+.tar pi@<IP>:~/dpp_bin 
```

Copy the binaries to the RPI that acts as a WiFi Client
```
$ scp $RPI_ROOTFS/usr/local/sbin/wpa_supplicant pi@<IP>:~/dpp_bin/ 
$ scp $RPI_ROOTFS/usr/local/sbin/wpa_cli pi@<IP>:~/dpp_bin/ 
$ scp $RPI_ROOTFS/lib/libnl-3.so pi@<IP>:~/dpp_bin/ 
$ scp $RPI_ROOTFS/lib/libnl-genl-3.so pi@<IP>:~/dpp_bin/ 
```

### On the WiFi AP RPI execute the following commands 
```
$ cd ~/dpp_bin/ $ sudo cp kernel-dpp.img /boot/ 
$ sudo cp 4.14.114-v7+.tar /lib/modules/ 
$ cd /lib/modules/ 
$ sudo rm -rf 4.14.114-v7+ $ sudo tar -axf 4.14.114-v7+.tar
```

Edit the `/boot/config.txt` file and add the below line 
```
kernel=kernel-dpp.img 
```
Reboot the RPI.

### On the WiFi Client RPI execute the following commands 
```
$ sudo rm -f /lib/arm-linux-gnueabihf/libnl-3.so.200 /lib/arm-linux-gnueabihf/libnl-genl-3.so.200
$ sudo ln -s /home/pi/dpp_bin/libnl-3.so /lib/arm-linux-gnueabihf/libnl-3.so.200 
$ sudo ln -s /home/pi/dpp_bin/libnl-genl-3.so /lib/arm-linux-gnueabihf/libnl-genl3.so.200
```

Edit the `~/dpp_bin/wpa_supplicant.conf` file and replace it with the below contents
```
ctrl_interface=DIR=/var/run/wpa_supplicant
ctrl_interface_group=0
update_config=1
pmf=2
dpp_config_processing=2
```

### Binary Version check in WiFi AP RPI
Check the kernel version 
```
$ uname -a
Linux raspberrypi 4.14.114-v7+ #1 SMP Thu Jan 2 17:36:08 IST 2020 armv7l GNU/Linux
```

Check the hostapd version
```
$ cd ~/dpp_bin
$ ./hostapd -v
hostapd v2.9-hostap_2_9+
User space daemon for IEEE 802.11 AP management,
IEEE 802.1X/WPA/WPA2/EAP/RADIUS Authenticator
Copyright (c) 2002-2019, Jouni Malinen <j@w1.fi> and contributors
```
### Binary Version check in WiFi Client RPI
Check the wpa_supplicant version
```
$ cd ~/dpp_bin 
$ ./wpa_supplicant –v
wpa_supplicant v2.9-hostap_2_9+
Copyright (c) 2003-2019, Jouni Malinen <j@w1.fi> and contributors
```

# Steps to get WPA2/PSK using DPP with RPI as STA

1.  Run hostapd for the access point device.
    `sudo ./hostapd -i <interface> configfile`

2.  Run supplicant for the PI device.
    `sudo ./wpa_supplicant -i <interface> -Dnl80211 -c configfile`

3.  In the STA device generate QR code for wlan0 interface and then switch to p2p-dev-wlan0 to be in DPP listen state
    `sudo ./wpa_cli dpp_bootstrap_gen type=qrcode mac=<mac-address-of-client> chan=81/1`
    `sudo ./wpa_cli dpp_bootstrap_get_uri <qr-code-id>`
    `sudo ./wpa_cli interface p2p-dev-wlan0`
    `sudo ./wpa_cli dpp_listen 2412`

4.  Create configurator and add the qr code in AP.
    `sudo ./hostapd_cli dpp_configurator_add`
    `sudo ./hostapd_cli dpp_qr_code "<qr-code-of-client>`

5.  Initiate DPP authentication.
    `sudo ./hostapd_cli dpp_auth_init peer=<qr-code-id> configurator=<configurator-id> conf=sta-psk ssid=HexDecimalValueOfSSID pass=HexDecimalValueOfPsk`

6.  We could see that DPP authentication is successful. GAS communication also happens successfully. Now the supplicant has all the necessary network credentials. This will initiate the 4-way handshake between STA and AP via the wlan0 interface. Switch interface to wlan0 in cli and use the command status to see the successful connection status.  
    `sudo ./wpa_cli interface p2p-dev-wlan0`
    `sudo ./wpa_cli status`

# Steps to connect using DPP Connector with RPI as STA

Notes:

*   Reboot the PI if it was earlier connected to AP via PSK. This is a known issue.
*   Do not use any PI as AP for this connection. Use preferably Alfa AWUS036NHA as Ap.

1.  First four steps of WPA2-PSK.
2.  Self configure the AP for DPP communication using the command
    `sudo ./hostapd_cli dpp_configurator_sign " conf=ap-dpp configurator=<config-id> ssid=hexaDecimalValueOfSSID`
    The DPP values can be set to run-time using the set command and for persisting on reboot save it to config file.(Refer: [http://w1.fi/cgit/hostap/plain/wpa_supplicant/README-DPP](http://w1.fi/cgit/hostap/plain/wpa_supplicant/README-DPP))

    sudo ./hostapd_cli set dpp_connector <Connector-value-printed-on-console>
    sudo ./hostapd_cli set dpp_csign <csign-value-on-console>
    sudo ./hostapd_cli set dpp_netaccesskey <netaccess-value-on-console>

3.  Initiate DPP authentication.
    `sudo ./hostapd_cli dpp_auth_init peer=<qr-code-id> conf=sta-dpp configurator=<configurator-id> ssid=HexDecimalValueOfSSID`

4.  We could see that DPP authentication is successful. GAS communication also success. Now supplicant have all the necessary network credentials. This will initiate the 4-way handshake between STA and AP via wlan0 interface. Switch interface to wlan0 in cli and use the command status to see the successful connection status.

    `sudo ./wpa_cli interface p2p-dev-wlan0`
    `sudo ./wpa_cli status`

# RPI as an AP

In AP config file, use only the key management WPA-PSK. Also do not set ieee80211w to a non-zero value. This is a known issue.

When using the DPP connector based mechanism, the network introduction was found to success. However, the association request was not handled properly by firmware resulting in association failure.

# Some known issues

1.  WPA/PSK with DPP uses driver 4-way handshake implementation while DPP connector uses user-space(hostap_2.9) 4-way handshake implementation. This causes conflict when a connected device via PSK is again tried to connect via the DPP connector. Need to reboot PI to get it running.
2.  If key management is set as DPP only on the AP side, there is an association issue. AP needs to support both DPP and WPA-PSK as key management.
3.  RPI 3B+ will not properly work as an access point if the protected management frame is enabled or using DPP Key management. However, WPA2-PSK configuration using DPP works if the protected management frame is disabled.
4.  The actual key management is not set for DPP. It is temporarily set as WPA2-PSK. If the actual value can be set in the firmware, the hacks in the userspace is no longer required.
5.  When acting as a client, the DPP listen work only on p2p interface. On wlan interface, the DPP listen seems to stop working after 5 seconds.
6.  RPI as an AP fails to associate with the client with DPP as key management.

# Details for Cypress

These are some of the extra changes required for complete and smooth functionality of DPP without any hack in userspace and driver.

1)**Protected management frame not supported in AP mode**

On running PI3B+ with Linux kernel 4.19.y as an AP (using wlan0), if protected management frame is enabled in the hostapd (ver : 2.9) with configurations as follow, the clients are not getting connected :

    wpa=2
    ieee80211w=1
    key_mgmt=WPA-PSK

We see the following error message during the 3/4 handshake in the client-side (supplicant)

    wlx00c0ca96c7d9: WPA: IE in 3/4 msg does not match with IE in Beacon/ProbeResp (src=b8:27:eb:16:48:ab)
    WPA: RSN IE in Beacon/ProbeResp - hexdump(len=26): 30 18 01 00 00 0f ac 04 01 00 00 0f ac 04 02 00 00 0f ac 02 00 0f ac 06 00 00
    WPA: RSN IE in 3/4 msg - hexdump(len=30): 30 1c 01 00 00 0f ac 04 01 00 00 0f ac 04 03 00 00 0f ac 02 00 0f ac 06 50 6f 9a 02 00 00

If we disable protected management frame (iee80211w=0), the client is able to connect and this case it does not uses RSN IE and will be using WPA IE. When using DPP as key managment it should always use protected managment frame.

Reference:

1. https://www.raspberrypi.org/forums/viewtopic.php?f=29&t=259522&p=1581463#p1581463
2. http://lists.infradead.org/pipermail/hostap/2019-November/040764.html
3. https://stackoverflow.com/questions/59250007/enabling-802-11w-mode-with-hostapd
4. https://community.cypress.com/message/218786

2)**DPP listen will work only on p2p-dev-wlan0 interface**

In primary interface wlan0, we are unable to do a dpp_listen 2412\. But on the virtual interface p2p-dev-wlan0 we are able to do the listen. If we try to listen on wlan0, the cancel remain on channel events goes to the virtual interface p2p-dev-wlan0 and wlan0 gets a cookie mismatch. [cookie (unknown)].

3)**Setting actual key management value in driver and firmware**

In `cfg80211.c` there is a function to set key management `brcmf_set_key_mgmt` based on the crypto AKM cipher suite. When the key-mgmt is set as DPP, the AKM cipher suite value is `0x506F9A02`. Based on the suite value corresponding key management value is set and passed to the firmware. The list of supported key management is given on `brcm80211/include/brcmu_wifi.h`. We are not sure about the value that needs to be set for the key management DPP. The firmware seems to accepts only the supported key management listed. Currently, we have set the key management value as WPA2-PSK for the AKM suite corresponding to DPP. This is a hack and only works if AP supports both DPP and WPA2-PSK.

4)**Information Element not getting updated with proper value**

When running as an AP, there is a function to parse and configure Information Element (IE).The function is `brcmf_configure_wpaie(struct brcmf_if *ifp, const struct brcmf_vs_tlv *wpa_ie, bool is_rsn_ie)` in the `cfg80211.c`. In case of DPP, the auth management is set to `RSN_AKM_PSK`. This is not the actual value for DPP key management. Only when setting with exact key management value, the IE will be populated with values corresponding to DPP.
