# docker-electron-armhf

This repo is a proof of concept.  No effort has been made to polish the code.

This is an application based on the
[Github/Electron](https://github.com/electron/electron).  Use this project to
build a docker image with Electron that runs under the arm architecture.


## To Run Locally on your Linux Host Machine

To clone and run this repository you'll need [Git](https://git-scm.com) and
[Node.js](https://nodejs.org/en/download/) (which comes with
[npm](http://npmjs.com)) installed on your computer. From your command line:

```bash
# On linux ubuntu 16.04 server

# Install node and npm
apt-get -yq install nodejs npm
ln -s /usr/bin/nodejs /usr/bin/node

# Install electron deps
apt-get -yq install libgtk2.0-0 libxtst6 libxss1 libgconf-2-4 libnss3

# Install x11 deps if you are running from a remote machine
apt-get -yq install xauth

# Install electron
INSTALL_DIR=/usr/local/electron-v1.4.15
PACKAGE=electron-v1.4.15-linux-x64.zip
URL=https://github.com/electron/electron/releases/download/v1.4.15/electron-v1.4.15-linux-x64.zip
curl -fsSL $URL > $PACKAGE
unzip -d $INSTALL_DIR $PACKAGE
ln -s $INSTALL_DIR/electron /usr/local/bin/electron

# Clone this repository
git clone https://github.com/dcwangmit01/docker-electron-armhf

# Go into the repository
cd docker-electron-armhf

# Install dependencies
npm install

# Run the app
npm start
```


## To Run on a Raspberry PI (or any other armhf arch)

```bash
# On linux ubuntu 16.04 server

# Build the image
make docker

# Push the image to the repository
make docker-push

# Run the image from your linux host using QEMU (to emulate arm)
docker run --rm \
    -e DISPLAY=:0 \
    --net=host \
    -v $HOME/.Xauthority:/root/.Xauthority \
    -it \
    registry.davidwang.com/paxarm/entry-ui:dev \
    /opt/electron/electron /opt/

# Run the image from your raspberry PI or ARMHF machine over SSH
# ssh -X to the machine
# --net=host needed because X11 socket connects to localhost
# .Xauthority for x authentication
# Display variable, for SSH to pass in
docker run --rm \
    -e DISPLAY \
    --net=host \
    -v $HOME/.Xauthority:/root/.Xauthority \
    -it \
    registry.davidwang.com/paxarm/docker-electron-armhf:dev \
    /opt/electron/electron /opt/

# Run the image from the console of the RPI
## The following are notes.  I haven't quite worked out how auto-launch on boot
##   from console using a minimal custom-build RPI raspbian image.  I may not
##   do so in favor of chromium in kiosk mode.

## Option 1
startx # only from the console of the RPI itself
docker run --rm -e DISPLAY=:0 --net=host -v $HOME/.Xauthority:/root/.Xauthority -it registry.davidwang.com/paxarm/docker-electron-armhf:dev /opt/electron/electron /opt/

## Option 2
sudo xinit # only from the console of the RPI itself
docker run --rm -e DISPLAY=:0 --net=host -v $HOME/.Xauthority:/root/.Xauthority -it registry.davidwang.com/paxarm/docker-electron-armhf:dev /opt/electron/electron /opt/

## Option 3
sudo Xorg :0 # this starts fine, but messes up once you kill -9 it.  Does not reset to console
docker run --rm -e DISPLAY=:0 --net=host -v $HOME/.Xauthority:/root/.Xauthority -it registry.davidwang.com/paxarm/docker-electron-armhf:dev /opt/electron/electron /opt/
```
