FROM consol/ubuntu-icewm-vnc

LABEL maintainer "Muhammad Rasyid Fahroni <ochid.ghuroba@gmail.com>"

#====================
# Switch to ROOT user
#====================
USER 0

#=========================
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
#=========================
RUN apt-get -qqy update && apt-get -qqy upgrade && apt-get -qqy install --no-install-recommends \
    software-properties-common \
    python3-setuptools \
    python3-pip \
    python3-tk \
    unzip \
    libx11-6 \
    libnss3 \
    libfontconfig1 \
    libgconf2-4 \
    wget \
    && apt-get -qqy autoremove \
    && rm -rf /var/lib/apt/lists/*

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

#=======================
# Switch to DEFAULT user
#=======================
USER 1000