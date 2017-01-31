#!/bin/bash

# Propose de renseigner l'adresse IP du serveur
if [ "$1" = '' ]; then
    echo "Quelle est l'adresse IP de votre serveur ? [ex: 35.157.32.132] : "
    read IP
    # Par défaut, ce sera 35.157.32.132
    if [ "$IP" = '' ]; then
        IP="35.157.32.132"
    fi
else
    # Mais on peut également le passer en argument quand on éxecute le script
    IP=$1
fi

# Propose de renseigner l'utilisateur avec lequel on se connecte au serveur
# bzg: éventuellement vérifier que USER_SSH n'est pas une déjà une variable
# d'environnement.
if [ "$2" = '' ]; then
    echo "Avec quel utilisateur voulez-vous vous connecter ? [ubuntu] : "
    read USER_SSH
    # Par défaut, ce sera ubuntu
    if [ "$USER_SSH" = '' ]; then
        USER_SSH="ubuntu"
    fi
else
    # Mais on peut encore le passer en argument quand on éxecute le script
    USER_SSH=$2
fi

# tail -n +34 "deploy.sh" -> Lit ce même fichier à partir de la ligne 34
# Puis l'envoie en pipe dans la connexion SSH
# Et enfin quitte le script
tail -n +34 "$0" | ssh $USER_SSH@$IP; exit;

### Commandes SSH ###

# Quitte le script si jamais une erreur survient !
set -e

# Message d'accueil
echo "Vous êtes sur une machine $(uname)"

# Met à jour le système
echo " ### apt-get update"
sudo apt-get update > ~/latest-update.log

# Installe les mises à jour
echo " ### apt-get upgrade"
sudo apt-get upgrade -y > ~/latest-upgrade.log

# Installation du serveur web (nginx)
echo " ### apt-get install nginx"
sudo apt-get install nginx  -y > /dev/null

# Installation de git
echo " ### apt-get install git"
sudo apt-get install git  -y > /dev/null

# Installation de php 7
sudo apt-get install php7.0 php-fpm -y > /dev/null

# Mise en place de la configuration Nginx

# Il faut obligatoirement créer le fichier en sudo pour
#  y renvoyer un pipe d'echo par la suite
sudo touch /etc/nginx/sites-available/webcloud

# Pipe de la configuration de Nginx
# bzg: expliquer pourquoi vous avez besoin de sudo ci-dessous
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
# tee nous permet d'écrire le pipe reçu dans le fichier de configuration

# Activation de cette configuration avec un symlink
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
    # $USER est ici l'utilisateur courant avec lequel nous serons connecté en SSH
    sudo chown -Rf $USER:$USER .
    # On supprime le dossier html
    rm -Rf html
    # Et on clone le projet dans un nouveau dossier html
    git clone https://github.com/CelesteBegassat/WebCloud.git html
fi

# THE END !
