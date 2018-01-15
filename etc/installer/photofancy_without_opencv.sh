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

log "Install node"
apt-get remove -y nodejs
apt-get remove -y npm
curl -sL https://deb.nodesource.com/setup_4.x | bash -
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
