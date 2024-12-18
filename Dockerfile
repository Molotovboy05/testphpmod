FROM ubuntu:latest

# Mise à jour et installation des dépendances
RUN apt update -y > /dev/null 2>&1 && apt upgrade -y > /dev/null 2>&1 && apt install locales -y \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

# Installation des outils nécessaires
RUN apt install ssh wget unzip curl -y > /dev/null 2>&1

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

# Lancer ngrok dans un script
RUN echo "#!/bin/bash\n\
./ngrok tcp 22 --region us &\n\
sleep 5\n\
curl --silent --show-error http://localhost:4040/api/tunnels" > /1.sh

# Rendre le script exécutable
RUN chmod +x /1.sh

# Exposition des ports nécessaires
EXPOSE 80 8888 8080 443 5130 5131 5132 5133 5134 5135 3306

# Exécution du script
CMD /1.sh
