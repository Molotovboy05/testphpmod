FROM ubuntu:latest

# Configurer les locales pour éviter les erreurs liées à l'environnement
RUN apt update -y && apt upgrade -y && apt install locales -y \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

# Installer les outils nécessaires (ssh, wget, unzip)
RUN apt install -y ssh wget unzip

# Télécharger et installer ngrok
RUN wget -O ngrok.zip https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.zip \
    && unzip ngrok.zip && rm ngrok.zip

# Ajouter le token ngrok et configurer le tunnel TCP sur le port 22
RUN echo "./ngrok config add-authtoken 2c8bOYFGPf7xyfMFMLnMFFq1LCN_2Yoc8Q5eD6JSpqLwihRE2 &&" >> /start.sh \
    && echo "./ngrok tcp 22 --region us &>/dev/null &" >> /start.sh

# Configurer SSH pour autoriser la connexion root
RUN mkdir /run/sshd \
    && echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config \
    && echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config \
    && echo "root:root" | chpasswd

# Lancer SSHD dans le conteneur
RUN echo "/usr/sbin/sshd -D" >> /start.sh \
    && chmod +x /start.sh

# Exposer les ports nécessaires
EXPOSE 22 80 8080 443 8888

# Commande par défaut : exécuter le script de démarrage
CMD ["/bin/bash", "/start.sh"]
