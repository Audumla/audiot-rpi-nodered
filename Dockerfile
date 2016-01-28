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
    npm install -g --unsafe-perm --link node-red && \
    mkdir /root/node_modules && \
    cd /root/node_modules && \
    npm install --no-optional --unsafe-perm --link serialport johnny-five raspi-io node-red-contrib-gpio cron cron-job-manager simple-ssh && \ 
    apt-get autoremove -y git build-essential
#
#    cd /root/node_modules && \
#    npm ddp && \

RUN npm cache clean && \
    cd /usr/local/lib/node_modules/node-red/ && \
    rm settings.js && \
    wget --no-check-certificate https://github.com/audumla/audiot-rpi-nodered/raw/master/node-red/settings.js && \
    rm -fr /root/.node-gyp && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /.tmp && \
    rm -rf /tmp && \
    apt-get clean

# run application
EXPOSE 1880
VOLUME ["/root/.node-red", "/lib/modules"]
ENTRYPOINT ["node-red-pi","-v","--max-old-space-size=128"]
