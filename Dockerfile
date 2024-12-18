FROM ubuntu:latest

# Mise à jour et installation des dépendances
RUN apt update -y > /dev/null 2>&1 && apt upgrade -y > /dev/null 2>&1 && apt install locales -y \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

# Installation des outils nécessaires
RUN apt install ssh wget unzip curl php php-cli php-curl -y > /dev/null 2>&1

# Téléchargement et installation de ngrok
RUN wget -O ngrok.zip https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.zip > /dev/null 2>&1
RUN unzip ngrok.zip && rm ngrok.zip

# Configuration de ngrok avec ton token d'authentification
RUN ./ngrok config add-authtoken 2c8bOYFGPf7xyfMFMLnMFFq1LCN_2Yoc8Q5eD6JSpqLwihRE2

# Configuration SSH
RUN mkdir /run/sshd
RUN echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
RUN echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config
RUN echo root:root | chpasswd
RUN service ssh start

# Lancer ngrok dans un script et enregistrer l'URL dans un fichier texte
RUN echo "#!/bin/bash\n\
./ngrok tcp 22 &\n\
sleep 5\n\
ngrok_url=$(curl --silent --show-error http://localhost:4040/api/tunnels | jq -r '.tunnels[0].public_url')\n\
echo \"Ngrok SSH URL: $ngrok_url\" > /ngrok_url.txt\n\
echo 'Ngrok SSH URL saved to /ngrok_url.txt'" > /start.sh

# Rendre le script exécutable
RUN chmod +x /start.sh

# Créer un fichier PHP pour le serveur web
RUN echo '<?php echo "Hello, this is a test from PHP server."; ?>' > /var/www/html/index.php

# Exposition des ports nécessaires pour SSH et HTTP
EXPOSE 80 22 4040 8080 8081

# Lancer ngrok et le serveur PHP
CMD /start.sh && php -S 0.0.0.0:80 -t /var/www/html
