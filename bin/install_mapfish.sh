#!/bin/sh
# Copyright (c) 2010 Open Source Geospatial Foundation (OSGeo)
#
# Licensed under the GNU LGPL.
# 
# This library is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as published
# by the Free Software Foundation, either version 2.1 of the License,
# or any later version.  This library is distributed in the hope that
# it will be useful, but WITHOUT ANY WARRANTY, without even the implied
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU Lesser General Public License for more details, either
# in the "LICENSE.LGPL.txt" file distributed with this software or at
# web page "http://www.fsf.org/licenses/lgpl.html".

# About:
# =====
# This script install mapfish

# Running:
# =======
# sudo ./install_mapfish.sh

BIN="/usr/bin"
USER_NAME="user"
USER_DIR="/home/user"

CONF_DIR="/etc"
MAPFISH_CONF_DIR="$CONF_DIR/mapfish"

INSTALL_DIR="/usr/lib"
MAPFISH_INSTALL_DIR="$INSTALL_DIR/mapfish"
MAPFISH_VENV_DIR="$MAPFISH_INSTALL_DIR/mapfish-venv"

 
## Setup things... ##
# check required tools are installed
if [ ! -x "`which wget`" ] ; then
   echo "ERROR: wget is required, please install it and try again" 
   exit 1
fi

apt-get --assume-yes install python2.6 python2.6-dev libpq-dev

if [ $? -ne 0 ] ; then
   echo 'ERROR: Package install failed! Aborting.'
   exit 1
fi


if [ ! -d $MAPFISH_CONF_DIR ]
then
    echo "Create $MAPFISH_CONF_DIR directory"
    mkdir $MAPFISH_CONF_DIR
fi

if [ ! -d $MAPFISH_INSTALL_DIR ]
then
    echo "Create $MAPFISH_INSTALL_DIR directory"
    mkdir $MAPFISH_INSTALL_DIR
fi

# install go-mapfish-framework-all.py script
wget -P $MAPFISH_INSTALL_DIR -c http://www.mapfish.org/downloads/go-mapfish-framework-1.2.py
chmod a+x $MAPFISH_INSTALL_DIR/go-mapfish-framework-1.2.py
ln -sf $MAPFISH_INSTALL_DIR/go-mapfish-framework-1.2.py $BIN/go-mapfish-framework-1.2.py

# create a global virtualenv for mapfish
go-mapfish-framework-1.2.py --python=python2.6 --no-site-packages $MAPFISH_VENV_DIR

# install mapfish.app.minimal in mapfish virtualenv
$MAPFISH_VENV_DIR/bin/easy_install --index-url=http://www.mapfish.org/downloads/all/pkg --allow-hosts=www.mapfish.org mapfish.app.minimal

$MAPFISH_VENV_DIR/bin/paster make-config mapfish.app.minimal $MAPFISH_CONF_DIR/minimal.ini

# install launchers
wget -P $MAPFISH_INSTALL_DIR -c http://www.mapfish.org/downloads/foss4g_livedvd/start_in_browser.sh
chmod a+x $MAPFISH_INSTALL_DIR/start_in_browser.sh
wget -P $BIN -c http://www.mapfish.org/downloads/foss4g_livedvd/mapfish
chmod a+x $BIN/mapfish

# install menu and desktop shortcuts
wget -P $MAPFISH_INSTALL_DIR -c http://www.mapfish.org/downloads/foss4g_livedvd/mapfish.png
wget -P /usr/share/applications -c http://www.mapfish.org/downloads/foss4g_livedvd/MapFish.desktop
cp /usr/share/applications/MapFish.desktop $USER_DIR/Desktop/
chown $USER_NAME:$USER_NAME $USER_DIR/Desktop/MapFish.desktop

#cleanup
apt-get --assume-yes remove libpq-dev
