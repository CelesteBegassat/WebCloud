# WebCloud

Un projet réalisé par Nicolas de CHEVIGNE et Celeste BEGASSAT

Ce dépôt permettra de déployer ce site simple en éxecutant une simple ligne de commande sur votre ordinateur.

### Prérequis

Nous admettrons ici que vous avez l'adresse d'un serveur sur lequel vous pouvez
vous connecter en SSH via le port par défaut (22) à l'aide d'un utilisateur possédant
un système de clés privé/publique déjà opérationnel et ayant les droits d'effectuer _sudo_

### Marche à suivre

1. Clonez le dépot sur votre ordinateur et, dans un terminal, déplacez vous dans le dossier cloné
2. Rendez le fichier _deploy.sh_ éxecutable à l'aide de la commande **chmod +x deploy.sh**
3. Executez le fichier _deploy.sh_ avec la commande **bash deploy.sh** ou **./deploy.sh**

Le programme demandera tout d'abord **l'adresse de votre serveur**
_(par défaut, 35.157.32.132, le serveur que nous avons utilisé)_

Ensuite, le programme vous demandera l'utilisateur avec lequel vous souhaitez vous connecter.
_(par défaut, ubuntu, l'utilisateur de base que nous utilisons)_

### Détails du programme

Le programme mettra tout d'abord à jour le système, installera des paquets essentiels à son fonctionnement,
git et php, puis installera Nginx, configurera celui-ci pour rediriger toutes requêtes HTTP sur le port 80 vers le dossier
_/var/www/html_.

Enfin, il vérifiera si le dépôt existe ou non dans le dossier _/var/www/html_.
Il le créera ou le mettra à jour dans un cas ou l'autre.