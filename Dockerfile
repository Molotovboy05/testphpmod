FROM ubuntu:latest

# Mise à jour et installation des dépendances
RUN apt update -y && apt upgrade -y && apt install locales -y \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

# Installation des outils nécessaires
RUN apt install ssh wget unzip curl -y

# Téléchargement et installation de ngrok
RUN wget -O ngrok.zip https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.zip
RUN unzip ngrok.zip && rm ngrok.zip

# Configuration de ngrok avec ton token d'authentification
RUN ./ngrok config add-authtoken 2c8bOYFGPf7xyfMFMLnMFFq1LCN_2Yoc8Q5eD6JSpqLwihRE2

# Configuration SSH
RUN mkdir /run/sshd
RUN echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
RUN echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config
RUN echo root:root | chpasswd
RUN service ssh start

# Lancer ngrok et récupérer l'URL du tunnel SSH
RUN echo "#!/bin/bash\n\
./ngrok tcp 22 --region us &\n\
sleep 5\n\
ngrok_url=$(curl --silent --show-error http://localhost:4040/api/tunnels | jq -r '.tunnels[0].public_url')\n\
echo \"Ngrok SSH URL: $ngrok_url\"" > /start.sh

# Rendre le script exécutable
RUN chmod +x /start.sh

# Exposition des ports nécessaires
EXPOSE 80 8888 8080 443 5130 5131 5132 5133 5134 5135 3306

# Exécution du script d'entrée
CMD /start.sh
