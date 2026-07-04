FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    xrdp \
    xfce4 \
    xfce4-goodies \
    dbus-x11 \
    curl \
    && rm -rf /var/lib/apt/lists/*

# XFCE as the xrdp session
RUN echo "xfce4-session" > /root/.xsession
RUN sed -i 's|startwm=.*|startwm=/etc/X11/Xsession|' /etc/xrdp/startwm.sh
RUN echo "startxfce4" >> /etc/xrdp/startwm.sh

# Allow root login over RDP
RUN sed -i 's/#AllowRootLogin=true/AllowRootLogin=true/' /etc/xrdp/sesman.ini

# Install ngrok
RUN curl -sL https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz | tar -xz -C /usr/local/bin

# Set root password
RUN echo "root:RDPpassword!" | chpasswd

COPY start-rdp.sh /usr/local/bin/start-rdp.sh
RUN chmod +x /usr/local/bin/start-rdp.sh
