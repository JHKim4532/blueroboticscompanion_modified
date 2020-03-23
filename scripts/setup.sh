#!/bin/bash

# RPi2 setup script for use as companion computer. This script is simplified for use with
# the ArduSub code.
cd $HOME

# Update package lists and current packages
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -yq

# Update Raspberry Pi
sudo DEBIAN_FRONTEND=noninteractive apt-get install -yq rpi-update
sudo rpi-update

# install python and pip
sudo apt-get install -y python-dev python-pip python3-dev python3-pip python-libxml2 python-lxml python3-lxml libcurl4-openssl-dev python-opencv python-matplotlib python3-opencv python3-matplotlib 

# dependencies
sudo apt-get install -y libxml2-dev libxslt1-dev

sudo pip install future pymavlink
sudo pip3 install future pymavlink

# install git
sudo apt-get install -y git

# download and install pymavlink from source in order to have up to date ArduSub support
#git clone https://github.com/mavlink/mavlink.git $HOME/mavlink
#pushd mavlink
#git submodule init && git submodule update --recursive
#pushd pymavlink
#sudo python setup.py build install
#popd
#popd

# install MAVLink tools
sudo pip install mavproxy dronekit dronekit-sitl # also installs pymavlink
sudo pip3 install mavproxy dronekit dronekit-sitl
# install screen
sudo apt-get install -y screen

# web ui dependencies, separate steps to avoid conflicts
# sudo apt-get install -y node
# sudo apt-get install -y nodejs-legacy
# sudo apt-get install -y npm

# node updater
# sudo npm install n -g

# Get recent version of node
# sudo n 5.6.0

# browser based terminal
# sudo npm install tty.js -g

# clone bluerobotics companion repository
# git clone https://github.com/bluerobotics/companion.git $HOME/companion

# cd $HOME/companion/br-webui

# npm install

# Disable camera LED
sudo sed -i '\%disable_camera_led=1%d' /boot/config.txt
sudo sed -i '$a disable_camera_led=1' /boot/config.txt

# Enable UART 1
sudo sed -i '\%enable_uart=%d' /boot/config.txt
sudo sed -i '\%dtoverlay=pi3-disable-bt' /boot/config.txt
sudo sed -i '$a enable_uart=1' /boot/config.txt
sudo sed -i '$a dtoverlay=pi3-disable-bt' /boot/config.txt

# Enable RPi camera interface
sudo sed -i '\%start_x=%d' /boot/config.txt
sudo sed -i '\%gpu_mem=%d' /boot/config.txt
sudo sed -i '$a start_x=1' /boot/config.txt
sudo sed -i '$a gpu_mem=256' /boot/config.txt

# source startup script
S1="$HOME/companion/scripts/expand_fs.sh"
S2=". $HOME/companion/.companion.rc"

# this will produce desired result if this script has been run already,
# and commands are already in place
# delete S1 if it already exists
# insert S1 above the first uncommented exit 0 line in the file
sudo sed -i -e "\%$S1%d" \
-e "\%$S2%d" \
-e "0,/^[^#]*exit 0/s%%$S1\n$S2\n&%" \
/etc/rc.local

# compile and install gstreamer 1.8 from source
if [ "$1" = "gst" ]; then
    $HOME/companion/scripts/setup_gst.sh
fi

# Copy udev rules
sudo cp $HOME/companion/params/100.autopilot.rules /etc/udev/rules.d/

sudo reboot now
