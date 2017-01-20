#!/bin/bash
if [ "$1" = '' ]; then
    echo "Quelle est l'adresse IP de votre serveur ? [35.157.32.132] : "
    read IP
    if [ "$IP" = '' ]; then
        IP="35.157.32.132"
    fi
else
    IP=$1
fi
if [ "$2" = '' ]; then
    echo "Avec quel utilisateur voulez-vous vous connecter ? [ubuntu] : "
    read USER
    if [ "$USER" = '' ]; then
        USER="ubuntu"
    fi
else
    USER=$2
fi
tail -n +22 "$0" | ssh $USER@$IP; exit;

# Prevent errors
set -e

echo "Vous êtes sur une machine $(uname)"

# Send apt-get update, upgrade, install ngnix
echo " ### apt-get update"
sudo apt-get update > ~/latest-update.log
echo " ### apt-get upgrade"
sudo apt-get upgrade -y > ~/latest-upgrade.log

# Installation du serveur web
echo " ### apt-get install nginx"
sudo apt-get install nginx  -y 2>> ~/error-installs.log > /dev/null

# Installation d'outils utiles, htop et git
echo " ### apt-get install htop git"
sudo apt-get install htop git  -y 2>> ~/error-installs.log > /dev/null

cd /var/www

if [ -d html/.git ]; then
    echo " ### Un projet semble initialisé"
    echo " ### Mise à jour du projet ... "
    cd html
    git pull
else
    echo " ## Le projet n'a jamais été déployé pour le moment"
    echo " ## Mise en place du projet ... "
    sudo chown -Rf $USER:$USER .
    rm -Rf html
    git clone https://github.com/CelesteBegassat/WebCloud.git html
fi

