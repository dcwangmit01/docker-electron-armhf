FROM armv7/armhf-ubuntu:16.04
#FROM node:slim

ARG ELECTRON_TGZ
ADD ${ELECTRON_TGZ} /opt/electron

COPY [ ".cache/qemu-arm-static", "/usr/bin/qemu-arm-static" ]
COPY ["*.html", \
       "*.js", \
       "*.json", \
       "LICENSE", \
       "/opt/" ]

# Enable apt-proxy for this build
COPY [ ".cache/00aptproxy", "/etc/apt/apt.conf.d/00aptproxy" ]

RUN apt-get update && \
    apt-get -yq install libgtk2.0-0 libxtst6 libxss1 libgconf-2-4 libnss3 libasound2 \
    nodejs npm \
    xterm

# Disable apt-proxy now that build has completed
RUN rm -f /etc/apt/apt.conf.d/00aptproxy

RUN ln -s /usr/bin/nodejs /usr/bin/node && \
    cd /opt && npm install


#####################################################################
# Notes

# apt-get -yq install libgtkextra-dev libgconf2-dev libnss3 libasound2 libxtst-dev
#
# http://stackoverflow.com/questions/39930223/how-to-run-an-electron-app-on-docker
# https://resin.io/blog/building-arm-containers-on-any-x86-machine-even-dockerhub/
