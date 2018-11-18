FROM ubuntu:18.04

LABEL maintainer "Muhammad Rasyid Fahroni <ochid.ghuroba@gmail.com>"

#=============
# Set WORKDIR
#=============
WORKDIR /root

#==================
# General Packages
#------------------
# supervisor
#   Process manager
# xvfb
#   X virtual framebuffer
#------------------
#  NoVNC Packages
#------------------
# x11vnc
#   VNC server for X display
# openbox
#   Windows manager
# menu
#   Debian menu
# python-numpy
#   Numpy, For faster performance: https://github.com/novnc/websockify/issues/77
# net-tools
#   Netstat
#------------------
# Chromium Packages
#------------------
# chromium-browser
#   version = 70.0.3538.77-0ubuntu0.18.04.1
# chromium-browser-l10n
#   version = 70.0.3538.77-0ubuntu0.18.04.1
# chromium-codecs-ffmpeg
#   version = 70.0.3538.77-0ubuntu0.18.04.1
#-----------------
# Firefox Packages
#-----------------
# firefox
#   version = 63.0+build2-0ubuntu0.18.04.2
#-------------------------
#  Python + other Packages
#-------------------------
# software-properties-common
# python3-setuptools
# python3-pip
# python3-tk
# unzip
# libx11-6
# libnss3
# libfontconfig1
# libgconf2-4
# wget
#==================
ARG CHROMIUM_VERSION=70.0.3538.77-0ubuntu0.18.04.1
ARG FIREFOX_VERSION=63.0+build2-0ubuntu0.18.04.2
ENV DEBIAN_FRONTEND=noninteractive \
    CHROMIUM_VERSION=$CHROMIUM_VERSION \
    FIREFOX_VERSION=$FIREFOX_VERSION

RUN apt-get -qqy update && apt-get -qqy upgrade && apt-get -qqy install --no-install-recommends \
    supervisor \
    xvfb \
    x11vnc \
    openbox \
    menu \
    python-numpy \
    net-tools \
    chromium-browser=${CHROMIUM_VERSION} \
    chromium-browser-l10n=${CHROMIUM_VERSION} \
    chromium-codecs-ffmpeg=${CHROMIUM_VERSION} \
    firefox=${FIREFOX_VERSION} \
    software-properties-common \
    python3-setuptools \
    python3-pip \
    python3-tk \
    unzip \
    libx11-6 \
    libnss3 \
    libfontconfig1 \
    libgconf2-4 \
    wget && \
    apt-get -qqy autoremove && \
    rm -rf /var/lib/apt/lists/* && \
    ln -s /usr/bin/chromium-browser /usr/bin/google-chrome

#=======
# noVNC
#=======
ENV NOVNC_SHA="cffb42ee8f150d46b6ecf2727fadd0f4f6557aa8" \
    WEBSOCKIFY_SHA="f0bdb0a621a4f3fb328d1410adfeaff76f088bfd"
RUN wget -nv -O noVNC.zip "https://github.com/novnc/noVNC/archive/${NOVNC_SHA}.zip" \
    && unzip -x noVNC.zip \
    && rm noVNC.zip  \
    && mv noVNC-${NOVNC_SHA} noVNC \
    && wget -nv -O websockify.zip "https://github.com/novnc/websockify/archive/${WEBSOCKIFY_SHA}.zip" \
    && unzip -x websockify.zip \
    && mv websockify-${WEBSOCKIFY_SHA} ./noVNC/utils/websockify \
    && rm websockify.zip \
    && ln noVNC/vnc_lite.html noVNC/index.html

#==============================================
# Download Robot Framework and Selenium Library
#==============================================
RUN pip3 install wheel && pip3 install --upgrade robotframework robotframework-seleniumlibrary robotframework-faker

#======================
# Download Chromedriver
#======================
ARG CHROMEDRIVER_VERSION=2.43
ENV CHROMEDRIVER_VERSION=$CHROMEDRIVER_VERSION

RUN wget https://chromedriver.storage.googleapis.com/${CHROMEDRIVER_VERSION}/chromedriver_linux64.zip;\
unzip chromedriver_linux64.zip;\
rm -rf chromedriver_linux64.zip;\
mv -f chromedriver /usr/local/bin/chromedriver;\
chmod 0755 /usr/local/bin/chromedriver

#=====================
# Download Geckodriver
#=====================
ARG GECKODRIVER_VERSION=0.23.0
ENV GECKODRIVER_VERSION=$GECKODRIVER_VERSION

RUN wget https://github.com/mozilla/geckodriver/releases/download/v${GECKODRIVER_VERSION}/geckodriver-v${GECKODRIVER_VERSION}-linux64.tar.gz;\
tar xvfz geckodriver-v${GECKODRIVER_VERSION}-linux64.tar.gz;\
rm -rf geckodriver-v${GECKODRIVER_VERSION}-linux64.tar.gz;\
mv -f geckodriver /usr/local/bin/geckodriver;\
chmod 0755 /usr/local/bin/geckodriver

#================================================
# noVNC Default Configurations
# These Configurations can be changed through -e
#================================================
ENV DISPLAY=:0 \
    SCREEN=0 \
    SCREEN_WIDTH=1366 \
    SCREEN_HEIGHT=768 \
    SCREEN_DEPTH=24 \
    LOCAL_PORT=5900 \
    TARGET_PORT=6080 \
    TIMEOUT=1 \
    LOG_PATH=/var/log/supervisor

#=====================
# Create non-root user
#=====================
RUN useradd -ms /bin/bash robot
USER robot
WORKDIR /home/robot

### fix to start chromium in a Docker container
RUN echo "CHROMIUM_FLAGS='--no-sandbox --start-maximized --disable-gpu --user-data-dir --window-size=$SCREEN_WIDTH,$SCREEN_HEIGHT --window-position=0,0'" > /home/robot/.chromium-browser.init

### Back to root user
USER root
WORKDIR /root

#===============
# Expose Ports
#---------------
# 6080
#   noVNC port
#===============
EXPOSE 6080

#=============
# Run services
#=============
COPY src /root/src
RUN chmod -R +x /root/src

CMD /usr/bin/supervisord --configuration src/supervisord.conf