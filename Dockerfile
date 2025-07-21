### LibreSource
FROM debian:bookworm-slim

###################### ARGUMENTS #######################
ARG steamcmd_url="https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz"
########################################################

###################### DEPENDENCIES ####################
RUN dpkg --add-architecture i386 && \
    apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        wget \
        locales \
        ca-certificates \
        curl:i386 \
        lib32gcc-s1 \
        libstdc++6:i386 \
        libncurses5:i386 \
        libtinfo5:i386 \
        bash \
        xz-utils \
        unzip \
        zip \
    && localedef -i en_US -f UTF-8 en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
########################################################

######################## USER ##########################
RUN groupadd -r steam && useradd -r -g steam -m -d /libre-source steam
########################################################

##################### INSTALL STEAMCMD #################
USER steam
WORKDIR /libre-source
# Download and extract SteamCMD
COPY ./src/install_css /libre-source
RUN wget -O steamcmd_linux.tar.gz "$steamcmd_url" && \
    tar -xzf steamcmd_linux.tar.gz && \
    rm steamcmd_linux.tar.gz
########################################################

##################### INSTALL CSS SERVER ################
RUN bash ./steamcmd.sh +runscript ./install_css
########################################################

#################### PERMISSIONS #######################
USER root
RUN chown -R steam:steam /libre-source
USER steam
WORKDIR /libre-source/css
########################################################

#################### RUNTIME SETUP #####################
EXPOSE 27015 27015/udp
ENTRYPOINT ["/libre-source/css/srcds_run"]
########################################################
