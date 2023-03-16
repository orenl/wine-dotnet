########################################################################
# base ubuntu with required packages
FROM ubuntu:22.04 AS base

LABEL description="Wine with Microsoft VC and .NET"
LABEL tags="Wine,VC,.NET"

# Prevents annoying debconf errors during builds
ENV DEBIAN_FRONTEND="noninteractive"

RUN dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y \
# Required for wine
        winbind \
# Required for winetricks
        cabextract \
        p7zip \
        unzip \
        wget \
        zenity \
        xvfb && \
    apt-get -y clean && \
    rm -rf \
      /var/lib/apt/lists/* \
      /usr/share/doc \
      /usr/share/doc-base \
      /usr/share/man \
      /usr/share/locale \
      /usr/share/zoneinfo

########################################################################
# base with wine and winetricks installed
FROM base AS base-wine

ARG WINEVERSION=8.0

# Install wine
RUN mkdir -p -m 0755 /etc/apt/keyrings \
    && wget -nc https://dl.winehq.org/wine-builds/winehq.key \
    && mv winehq.key /etc/apt/keyrings/winehq-archive.key \
    && wget -nc https://dl.winehq.org/wine-builds/ubuntu/dists/jammy/winehq-jammy.sources \
    && mv winehq-jammy.sources /etc/apt/sources.list.d/ \
    && apt-get update \
    && apt-get install -y --install-recommends winehq-stable=${WINEVERSION}* \
    && apt-get -y clean \
    && rm -rf \
      /var/lib/apt/lists/* \
      /usr/share/doc \
      /usr/share/doc-base \
      /usr/share/man \
      /usr/share/locale \
      /usr/share/zoneinfo \
    && wget https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks \
      -O /usr/local/bin/winetricks \
    && chmod +x /usr/local/bin/winetricks

ENV WINEARCH win64
ENV WINEDEBUG -all,err+all
ENV WINEPREFIX /wine64

RUN mkdir -p /wine64/
WORKDIR /wine64

########################################################################
# wine with windows dependencies (visual c, dotnet)
FROM base-wine AS wine-dotnet

ARG VCRUN_VERSION=2022
ARG DOTNET_VERSION=48

RUN winecfg \
    && xvfb-run winetricks -q corefonts \
    && xvfb-run winetricks -q vcrun${VCRUN_VERSION} \
    && xvfb-run winetricks -q dotnet${DOTNET_VERSION} \
    && rm -fr /root/.cache/winetricks

########################################################################
# wine with windows dependencies and target app
FROM wine-dotnet

RUN mkdir -p /app
WORKDIR /app

# copy the compiled app (Release folder from Windows) - option 2 below
# COPY Release/ /app

ENTRYPOINT ["wine"]

# Build the docker image once:
#   docker build -t wine-dotnet-img .
#
# (assume app was compiled on Windows with VC and Dotnet, result is in Release/ folder)
#
# 1) Run the windows app - with external volume:
# (the app Release/ folder mounted as a volume inside the container) 
#   docker run --rm -v $APP_RELEASE:/app wine-dotnet-img Release/$APP_BINARY [ARGS...]
#
# 2) Run the windows app - included in the docker:
# (the app Release/ folder copied into the container at build time)
#   docker run --rm -v $APP_RELEASE:/app wine-dotnet-img Release/$APP_BINARY [ARGS...]


