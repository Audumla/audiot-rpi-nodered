FROM hypriot/rpi-node:5.4.1-slim

# install required packages, in one command
RUN apt-get install -y --no-install-recommends \
        git \
        build-essential \
        python-dev \
        libi2c-dev \
        i2c-tools

RUN git clone git://git.drogon.net/wiringPi && \
    cd wiringPi && \
    ./build

RUN wget -O python-rpi.gpio_armhf.deb http://sourceforge.net/projects/raspberry-gpio-python/files/raspbian-jessie/python-rpi.gpio_0.6.1-1~jessie_armhf.deb/download && \
    dpkg -i python-rpi.gpio_armhf.deb && \
    rm python-rpi.gpio_armhf.deb

# install top level dependencies
RUN npm install -g --unsafe-perm \
        raspi-io \
        node-red \
        node-red-contrib-gpio 

# clean up
RUN apt-get autoremove -y 
        wget \
        git \
        build-essential \
        rm -rf /var/lib/apt/lists/* && \
        apt-get clean

# run application
EXPOSE 1880
ENTRYPOINT ["node-red-pi","-v","--max-old-space-size=128"]
