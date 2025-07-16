### Libre-Source
FROM debian:bookworm-slim

###~ Pre-Install Things
ARG steamcmd_url="http://media.steampowered.com/installer/steamcmd_linux.tar.gz"

###~ Install required dependencies
RUN dpkg --add-architecture i386 && apt-get update && apt-get upgrade -y

RUN apt-get install -y --no-install-recommends \
    wget \
    locales \
    ca-certificates \
    libarchive-tools \
    curl:i386 \
    lib32gcc-s1 \
    libstdc++6:i386

###~ Set user
RUN addgroup --gid 1001 libre-source && \
    adduser --uid 1001 --gid 1001 --system --disabled-password libre-source

RUN mkdir -p /steam/SteamCMD && \
    chown -R libre-source:libre-source /steam && \
    chmod -R u+rwX /steam

USER libre-source
WORKDIR /steam

###~ Setup SteamCMD
COPY ./src/install_css /steam/SteamCMD/
RUN mkdir -p /steam/SteamCMD && \
    wget -P /steam/SteamCMD/ "$steamcmd_url" && \
    bsdtar -xf /steam/SteamCMD/steamcmd_linux.tar.gz -C /steam/SteamCMD && \
    rm /steam/SteamCMD/steamcmd_linux.tar.gz && \
    bash /steam/SteamCMD/steamcmd.sh +runscript /steam/SteamCMD/install_css

###~ Expose Ports
EXPOSE 27015 27015/udp
