FROM resin/rpi-raspbian:jessie

#armv should be either armv6l or armv7l
ARG armv=armv6l
ARG node=5.5.0
ENV NODE_VERSION $node
ENV NPM_CONFIG_LOGLEVEL info
ENV ARM_VERSION $armv
        
RUN apt-get update && apt-get install -y --no-install-recommends \
    python \
    libi2c-dev \
    i2c-tools \ 
    wget

# install node red
RUN wget --no-check-certificate "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-$ARM_VERSION.tar.gz" && \
    tar -xzf "node-v$NODE_VERSION-linux-$ARM_VERSION.tar.gz" -C /usr/local --strip-components=1 && \
    rm "node-v$NODE_VERSION-linux-$ARM_VERSION.tar.gz"
    
# install python gpio        
RUN wget --no-check-certificate -O python-rpi.gpio_armhf.deb http://sourceforge.net/projects/raspberry-gpio-python/files/raspbian-jessie/python-rpi.gpio_0.6.1-1~jessie_armhf.deb/download && \
    dpkg -i python-rpi.gpio_armhf.deb && \
    rm python-rpi.gpio_armhf.deb

# install latest wiring pi    
# install top level node dependencies
RUN apt-get install git build-essential && \
    git clone git://git.drogon.net/wiringPi && \
    cd wiringPi && \
    ./build && \
    rm -fr /.wiringPi && \
    npm install -g --unsafe-perm node-red && \
    npm install --no-optional --unsafe-perm raspi-io johnny-five node-red-contrib-gpio && \
    npm cache clean && \
    cd /usr/local/lib/node_modules/node-red/ && \
    rm settings.js && \
    wget --no-check-certificate https://github.com/audumla/audiot-rpi-nodered/raw/master/node-red/settings.js && \
    rm -fr /root/.node-gyp && \
    apt-get autoremove -y git build-essential && \
    npm ddp
    
# clean up
RUN rm -rf /var/lib/apt/lists/* && \
    apt-get clean

# run application
EXPOSE 1880
VOLUME ["/root/.node-red", "/lib/modules"]
ENTRYPOINT ["node-red-pi","-v","--max-old-space-size=128"]
