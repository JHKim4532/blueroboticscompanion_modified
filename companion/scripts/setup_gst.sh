#compile and install gstreamer from source
#derived from script found at https://gist.github.com/sphaero/02717b0b35501ad94863
#!/bin/bash --debugger
set -e

BRANCH="1.8"
if grep -q BCM2 /proc/cpuinfo; then
    echo "RPI BUILD!"
    RPI="1"
fi

[ -n "$1" ] && BRANCH=$1

# Create a log file of the build as well as displaying the build on the tty as it runs
exec > >(tee build_gstreamer.log)
exec 2>&1

# sudo apt-get remove libgstreamer* gstreamer1.0*

# Update and U#pgrade the Pi, otherwise the build may fail due to inconsistencies
# grep -q BCM270 /proc/cpuinfo && sudo apt-get update && sudo apt-get upgrade -y --force-yes

# Get the required libraries
sudo apt-get install -y --force-yes build-essential


# get the repos if they're not already there
cd $HOME
[ ! -d src ] && mkdir src
cd src
[ ! -d gstreamer ] && mkdir gstreamer
cd gstreamer

# get repos if they are not there yet
[ ! -d gstreamer ] && git clone git://anongit.freedesktop.org/git/gstreamer/gstreamer
#[ ! -d gst-plugins-base ] && git clone git://anongit.freedesktop.org/git/gstreamer/gst-plugins-base
#[ ! -d gst-plugins-good ] && git clone git://anongit.freedesktop.org/git/gstreamer/gst-plugins-good
#[ ! -d gst-plugins-bad ] && git clone git://anongit.freedesktop.org/git/gstreamer/gst-plugins-bad
#[ ! -d gst-plugins-ugly ] && git clone git://anongit.freedesktop.org/git/gstreamer/gst-plugins-ugly
#[ ! -d gst-libav ] && git clone git://anongit.freedesktop.org/git/gstreamer/gst-libav
#[ ! -d gst-omx ] && git clone git://anongit.freedesktop.org/git/gstreamer/gst-omx
[ ! -d gst-python ] && git clone git://anongit.freedesktop.org/git/gstreamer/gst-python
#[ ! $RPI ] && [ ! -d gstreamer-vaapi ] && git clone git://gitorious.org/vaapi/gstreamer-vaapi.git

export LD_LIBRARY_PATH=/usr/local/lib/
# checkout branch (default=master) and build & install
cd gstreamer
git checkout -t origin/$BRANCH || true
sudo make -j4 uninstall || true
git pull
./autogen.sh --disable-gtk-doc
make -j4
sudo make -j4 install
cd ..

#cd gst-plugins-base
#git checkout -t origin/$BRANCH || true
#sudo make -j4 uninstall || true
#git pull
#./autogen.sh --disable-gtk-doc
#make -j4
#sudo make -j4 install
#cd ..

#cd gst-plugins-good
#git checkout -t origin/$BRANCH || true
#sudo make -j4 uninstall || true
#git pull
#./autogen.sh --disable-gtk-doc
#make -j4
#sudo make -j4 install
#cd ..

#cd gst-plugins-ugly
#git checkout -t origin/$BRANCH || true
#sudo make -j4 uninstall || true
#git pull
#./autogen.sh --disable-gtk-doc
#make -j4
#sudo make -j4 install
#cd ..

#cd gst-libav
#git checkout -t origin/$BRANCH || true
#sudo make -j4 uninstall || true
#git pull
#./autogen.sh --disable-gtk-doc
#make -j4
#sudo make -j4 install
#cd ..

#cd gst-plugins-bad
#git checkout -t origin/$BRANCH || true
#sudo make -j4 uninstall || true
#git pull
# some extra flags on rpi
#if [[ $RPI -eq 1 ]]; then
#    export LDFLAGS='-L/opt/vc/lib' \
#    CFLAGS='-I/opt/vc/include -I/opt/vc/include/interface/vcos/pthreads -I/opt/vc/include/interface/vmcs_host/linux' \
#    CPPFLAGS='-I/opt/vc/include -I/opt/vc/include/interface/vcos/pthreads -I/opt/vc/include/interface/vmcs_host/linux'
#    ./autogen.sh --disable-gtk-doc --disable-examples --disable-x11 --disable-glx --disable-glx --disable-opengl
#    make -j4 CFLAGS+="-Wno-error -Wno-redundant-decls -I/opt/vc/include -I/opt/vc/include/interface/vcos/pthreads -I/opt/vc/include/interface/vmcs_host/linux" \
#      CPPFLAGS+="-Wno-error -Wno-redundant-decls -I/opt/vc/include -I/opt/vc/include/interface/vcos/pthreads -I/opt/vc/include/interface/vmcs_host/linux" \
#      CXXFLAGS+="-Wno-redundant-decls" LDFLAGS+="-L/opt/vc/lib"
#else
#    ./autogen.sh --disable-gtk-doc
#    make -j4 CFLAGS+="-Wno-error -Wno-redundant-decls" CXXFLAGS+="-Wno-redundant-decls"
#fi
#sudo make -j4 install
#cd ..

# python bindings
cd gst-python
git checkout -t origin/$BRANCH || true
export LD_LIBRARY_PATH=/usr/local/lib/ 
sudo make -j4 uninstall || true
git pull
PYTHON=/usr/bin/python3 ./autogen.sh
make -j4
sudo make -j4 install
cd ..

# omx support
#cd gst-omx
#git checkout -t origin/1.0 || true
#sudo make -j4 uninstall || true
#git pull
#if [[ $RPI -eq 1 ]]; then
#    export LDFLAGS='-L/opt/vc/lib' \
#    CFLAGS='-I/opt/vc/include -I/opt/vc/include/IL -I/opt/vc/include/interface/vcos/pthreads -I/opt/vc/include/interface/vmcs_host/linux -I/opt/vc/include/IL' \
#    CPPFLAGS='-I/opt/vc/include -I/opt/vc/include/IL -I/opt/vc/include/interface/vcos/pthreads -I/opt/vc/include/interface/vmcs_host/linux -I/opt/vc/include/IL'
#    ./autogen.sh --disable-gtk-doc --with-omx-target=rpi
#    # fix for glcontext errors and openexr redundant declarations
#    make -j4 CFLAGS+="-Wno-error -Wno-redundant-decls" LDFLAGS+="-L/opt/vc/lib"
#else
#    ./autogen.sh --disable-gtk-doc --with-omx-target=bellagio
#    # fix for glcontext errors and openexr redundant declarations
#    make -j4 CFLAGS+="-Wno-error -Wno-redundant-decls"
#fi
#sudo make -j4 install
#cd ..

# VAAPI, not for RPI
if [[ $RPI -ne 1 ]]; then
    cd gstreamer-vaapi
    sudo make -j4 uninstall || true
    git pull
    ./autogen.sh
    make -j4
    sudo make -j4 install
    cd ..
fi

sudo rm -rf $HOME/src

echo export LD_LIBRARY_PATH=/usr/local/lib/ >> $HOME/.bashrc
