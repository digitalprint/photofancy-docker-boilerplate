#!/bin/bash

###########################################################
#
# PhotoFancy Installer
# http://opencv.org/
#
###########################################################

dateformat="+%a %b %-eth %Y %I:%M:%S %p %Z"
starttime=$(date "$dateformat")
starttimesec=$(date +%s)

curdir=$(cd `dirname $0` && pwd)

logfile="$curdir/install-opencv.log"
rm -f $logfile

log(){
	timestamp=$(date +"%Y-%m-%d %k:%M:%S")
	echo "\n$timestamp $1"
	echo "$timestamp $1" >> $logfile 2>&1
}

log "############################"
log "#                          #"
log "# PhotoFancy Installer 1.0 #"
log "#                          #"
log "############################"

log "Add Gimp Repository"
add-apt-repository -y ppa:otto-kesselgulasch/gimp

log "Execute apt-get update e apt-get upgrade"
 
apt-get -y update
apt-get -y upgrade

log "Install Ruby-Sass"
apt-get install -y ruby-sass

log "Install mc"
apt-get install -y mc

log "Install vim"
apt-get install -y vim

log "Install jhead"
apt-get install -y jhead

log "Install mysql-client"
apt-get install -y mysql-client unixodbc libpq5

log "Install gmic"
apt-get install -y gmic gimp-gmic

log "Install potrace"
apt-get install -y potrace

log "Install sphinxsearch"
apt-get install -y sphinxsearch

log "Install OpenCV 3.2.0 dependencies"

apt-get install -y libopencv-dev
apt-get install -y build-essential checkinstall cmake pkg-config
apt-get install -y libtiff5-dev libjpeg-dev libjasper-dev libpng12-dev zlib1g-dev libopenexr-dev libgdal-dev
apt-get install -y libavcodec-dev libavformat-dev libmp3lame-dev libswscale-dev libdc1394–22-dev libxine2-dev libgstreamer0.10-dev libgstreamer-plugins-base0.10-dev libv4l-dev v4l-utils libfaac-dev libopencore-amrnb-dev libopencore-amrwb-dev libtheora-dev libvorbis-dev libxvidcore-dev libx264-dev x264 yasm
apt-get install -y libtbb-dev libeigen3-dev
apt-get install -y libqt4-dev libgtk2.0-dev qt5-default
apt-get install -y libvtk6-dev
apt-get install -y ant default-jdk
apt-get install -y python-dev python-tk python-numpy python3-dev python3-tk python3-numpy python-matplotlib
apt-get install -y python-opencv
apt-get install -y doxygen

log "Grab OpenCV 3.2.0"
 
FOLDER_NAME="opencv"
EFFECTS_FOLDER="/app/web/_filesystem/photofancy/repo/private/effects/current"

cd /tmp
mkdir ${FOLDER_NAME}
cd ${FOLDER_NAME}
 
wget https://github.com/opencv/opencv/archive/3.2.0.zip
unzip 3.2.0.zip
rm 3.2.0.zip 

log "Install OpenCV 3.2.0"
 
mv opencv-3.2.0 opencv
cd opencv
mkdir build
cd build
 
cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local -D WITH_TBB=ON -D BUILD_NEW_PYTHON_SUPPORT=ON -D WITH_V4L=ON -D INSTALL_C_EXAMPLES=ON -D INSTALL_PYTHON_EXAMPLES=ON -D BUILD_DOC=ON -D BULD_EXAMPLES=ON -D WITH_QT=ON -D WITH_OPENGL=ON -D WITH_EIGEN=ON -D FORCE_VTK=TRUE -D WITH_VTK=ON ..
 
make -j4
make install

sh -c 'echo "/usr/local/lib" > /etc/ld.so.conf.d/opencv.conf'
 
ldconfig

cd /tmp
rm -r ${FOLDER_NAME}

log "Install node"
apt-get remove -y nodejs
apt-get remove -y npm
curl -sL https://deb.nodesource.com/setup | bash -
apt-get install -y nodejs

log "Install uglifyJS"
npm install -g uglify-js

log "Install uglifyCSS"
npm install -g uglifycss

log "Install Timeserver"
apt-get install -y ntpdate
ntpdate -s time.nist.gov

mkdir -p ${EFFECTS_FOLDER}

log "PhotoFancy Tools installed successfully!"

endtime=$(date "$dateformat")
endtimesec=$(date +%s)

elapsedtimesec=$(expr $endtimesec - $starttimesec)
ds=$((elapsedtimesec % 60))
dm=$(((elapsedtimesec / 60) % 60))
dh=$((elapsedtimesec / 3600))
displaytime=$(printf "%02d:%02d:%02d" $dh $dm $ds)
log "Total Time: $displaytime\n"
