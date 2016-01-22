FROM resin/rpi-raspbian:jessie

ENV NODE_VERSION 5.5.0
ENV NPM_CONFIG_LOGLEVEL info
ENV ARM_VERSION armv6l
        
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    wget \
    git \
    build-essential \
    python-dev \
    libi2c-dev \
    i2c-tools

# gpg keys listed at https://github.com/nodejs/node
RUN set -ex \
  && for key in \
    9554F04D7259F04124DE6B476D5A82AC7E37093B \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    0034A06D9D9B0064CE8ADF6BF1747F4AD2306D93 \
    FD3A5288F042B6850C66B31F09FE44734EB7990E \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
    B9AE9905FFD7803F25714661B63B535A4C206CA9 \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
  ; do \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
  done

# install node red
RUN curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-$ARM_VERSION.tar.gz" \
  && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
  && gpg --verify SHASUMS256.txt.asc \
  && grep " node-v$NODE_VERSION-linux-$ARM_VERSION.tar.gz\$" SHASUMS256.txt.asc | sha256sum -c - \
  && tar -xzf "node-v$NODE_VERSION-linux-$ARM_VERSION.tar.gz" -C /usr/local --strip-components=1 \
  && rm "node-v$NODE_VERSION-linux-$ARM_VERSION.tar.gz" SHASUMS256.txt.asc
        
# install python gpio        
RUN wget -O python-rpi.gpio_armhf.deb http://sourceforge.net/projects/raspberry-gpio-python/files/raspbian-jessie/python-rpi.gpio_*.deb/download && \
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
        curl \
        git \
        build-essential && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

# run application
EXPOSE 1880
ENTRYPOINT ["node-red-pi","-v","--max-old-space-size=128"]
