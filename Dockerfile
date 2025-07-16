### LibreSource
FROM debian:bookworm-slim

ARG steamcmd_url="http://media.steampowered.com/installer/steamcmd_linux.tar.gz"

RUN dpkg --add-architecture i386 && apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends wget locales ca-certificates libarchive-tools bash curl:i386 lib32gcc-s1 libstdc++6:i386 && \
    rm -rf /var/lib/apt/lists/*

RUN addgroup --gid 1001 libre-source && \
    adduser --uid 1001 --gid 1001 --system --disabled-password --no-create-home libre-source

RUN mkdir -p /steam/SteamCMD

# Download and extract SteamCMD as root
RUN wget -P /steam/SteamCMD/ "$steamcmd_url" && \
    bsdtar -xf /steam/SteamCMD/steamcmd_linux.tar.gz -C /steam/SteamCMD && \
    rm /steam/SteamCMD/steamcmd_linux.tar.gz

COPY ./src/install_css /steam/SteamCMD/
RUN chmod +x /steam/SteamCMD/install_css

# Run SteamCMD install as root (fixes permission issues)
RUN bash /steam/SteamCMD/steamcmd.sh +runscript /steam/SteamCMD/install_css

# Fix ownership for runtime usage
RUN chown -R libre-source:libre-source /steam

# Switch to unprivileged user for runtime
USER libre-source
WORKDIR /steam

# Expose ports as needed
EXPOSE 27015 27015/udp

