#!/bin/bash

# Propose de renseigner l'adresse IP du serveur
if [ "$1" = '' ]; then
    echo "Quelle est l'adresse IP de votre serveur ? [35.157.32.132] : "
    read IP
    # Par défaut, ce sera 35.157.32.132
    if [ "$IP" = '' ]; then
        IP="35.157.32.132"
    fi
else
    IP=$1
fi

# Propose de renseigner l'utilisateur avec lequel on se connecte au serveur
if [ "$2" = '' ]; then
    echo "Avec quel utilisateur voulez-vous vous connecter ? [ubuntu] : "
    read USER_SSH
    # Par défaut, ce sera ubuntu
    if [ "$USER_SSH" = '' ]; then
        USER_SSH="ubuntu"
    fi
else
    USER_SSH=$2
fi
tail -n +28 "$0" | ssh $USER_SSH@$IP; exit;

### Commandes SSH ###

# Prevent errors
set -e

# Message d'accueil
echo "Vous êtes sur une machine $(uname)"

# Send apt-get update, upgrade, install ngnix
echo " ### apt-get update"
sudo apt-get update > ~/latest-update.log
echo " ### apt-get upgrade"
sudo apt-get upgrade -y > ~/latest-upgrade.log

# Installation du serveur web
echo " ### apt-get install nginx"
sudo apt-get install nginx  -y > /dev/null

# Installation de git
echo " ### apt-get install git"
sudo apt-get install git  -y > /dev/null

# Installation de php 7
sudo apt-get install php7.0 php-fpm -y > /dev/null

# Mise en place de la configuration Nginx
sudo touch /etc/nginx/sites-available/webcloud

sudo echo "server {
    listen 80 default_server;
    listen [::]:80 default_server;

    server_name _;

    root /var/www/html;
    index index.php index.html index.htm index.nginx-debian.html;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php7.0-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}" | sudo tee /etc/nginx/sites-available/webcloud > /dev/null
# Activation de cette configuration
sudo ln -f /etc/nginx/sites-available/webcloud /etc/nginx/sites-enabled

# On supprime la configuration par défaut si elle existe
if [ -f /etc/nginx/sites-enabled/default ]; then
    sudo rm /etc/nginx/sites-enabled/default
fi

# On test Nginx pour savoir si cette nouvelle configuration passe
sudo nginx -t > /dev/null 2>&1

# On se place dans le dossier web
cd /var/www

# Si un projet git existe dans le dossier html
if [ -d html/.git ]; then
    # On le met à jour
    echo " ### Un projet semble initialisé"
    echo " ### Mise à jour du projet ... "
    cd html
    git pull
else
    echo " ## Le projet n'a jamais été déployé pour le moment"
    echo " ## Mise en place du projet ... "
    # Sinon on donne les bons droits dans le dossier /var/www
    sudo chown -Rf $USER:$USER .
    # On supprime le dossier html
    rm -Rf html
    # Et on clone le projet dans un nouveau dossier html
    git clone https://github.com/CelesteBegassat/WebCloud.git html
fi

