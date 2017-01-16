#!/bin/bash
tail -n +3 "$0" | ssh ubuntu@35.157.32.132; exit;

# Prevent errors
set -e

# Send apt-get update, upgrade, install ngnix
echo " ... apt-get update..."
sudo apt-get update
echo " ... apt-get upgrade..."
sudo apt-get upgrade
echo " ... apt-get install nginx..."
sudo apt-get install nginx

# Set permission to html folder
# chown ubuntu:ubuntu .
cd /var/www/html

# TODO: pull if exist, please
sudo rm -Rf WebCloud
sudo git clone https://github.com/CelesteBegassat/WebCloud.git
