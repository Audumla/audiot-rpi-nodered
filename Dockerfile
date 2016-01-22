FROM resin/rpi-raspbian:jessie

ENV NODE_VERSION 5.5.0
ENV NPM_CONFIG_LOGLEVEL info
ENV ARM_VERSION armv6l
        
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    git \
    build-essential \
    python-dev \
    libi2c-dev \
    i2c-tools

# install node red
RUN wget --no-check-certificate "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-$ARM_VERSION.tar.gz" \
  && tar -xzf "node-v$NODE_VERSION-linux-$ARM_VERSION.tar.gz" -C /usr/local --strip-components=1 \
  && rm "node-v$NODE_VERSION-linux-$ARM_VERSION.tar.gz"
        
# install python gpio        
RUN wget -O python-rpi.gpio_armhf.deb http://sourceforge.net/projects/raspberry-gpio-python/files/raspbian-jessie/python-rpi.gpio_0.6.1-1.deb/download && \
    dpkg -i python-rpi.gpio_armhf.deb && \
    rm python-rpi.gpio_armhf.deb
    
# install latest wiring pi    
RUN git clone git://git.drogon.net/wiringPi && \
    cd wiringPi && \
    ./build

# install top level node dependencies
RUN npm install -g --unsafe-perm \
        raspi-io \
        node-red \
        node-red-contrib-gpio 

# clean up
RUN apt-get autoremove -y \
        wget \
        git \
        build-essential && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

# run application
EXPOSE 1880
ENTRYPOINT ["node-red-pi","-v","--max-old-space-size=128"]
