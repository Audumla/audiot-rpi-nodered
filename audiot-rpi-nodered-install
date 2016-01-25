#!/bin/bash

cd /home/pi
mkdir -p node-red
rm docker-compose.yml
wget  --no-check-certificate https://github.com/Audumla/audiot-rpi-nodered/raw/master/docker-compose.yml
armv = 'armv6l'
if grep -l v7l /proc/cpuinfo then
    armv = 'armv7l'
fi
sed -i 's/audumla\/audiot-rpi-nodered/audumla\/audiot-rpi-nodered:$armv/g' docker-compose.yml

if ! [ -e '/dev/i2c-1' ] then 
    if ! grep -l 'dtparam=i2c_arm=on' /boot/config.txt then
        sudo echo 'dtparam=i2c_arm=on' >> /boot/config.txt
        echo "Reboot required to enable i2c devices"
    fi
    sudo modprobe i2c-dev
fi

