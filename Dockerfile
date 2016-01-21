# DOCKER-VERSION 1.0.0
FROM resin/rpi-raspbian

# install required packages, in one command
RUN apt-get update  && \
    apt-get install -y apt-utils && \
    apt-get install -y git && \
    apt-get install -y wget && \
    apt-get install -y build-essential && \
    apt-get install -y python-dev && \
    apt-get install -y libi2c-dev && \
    apt-get install -y i2c-tools

RUN git clone git://git.drogon.net/wiringPi && \
    cd wiringPi && \
    ./build

ENV PYTHON /usr/bin/python2
RUN wget -O python-rpi.gpio_armhf.deb http://sourceforge.net/projects/raspberry-gpio-python/files/raspbian-jessie/python-rpi.gpio_0.6.1-1~jessie_armhf.deb/download && \
    dpkg -i python-rpi.gpio_armhf.deb && \
    rm python-rpi.gpio_armhf.deb
 
RUN touch /usr/share/doc/python-rpi.gpio
COPY ./source /usr/local/lib/node_modules/node-red/nodes/core/hardware
RUN chmod 777 /usr/local/lib/node_modules/node-red/nodes/core/hardware/nrgpio


# install nodejs for rpi
RUN wget http://node-arm.herokuapp.com/node_latest_armhf.deb && \
    dpkg -i node_latest_armhf.deb && \
    rm node_latest_armhf.deb

# install top level dependencies
RUN npm install -g cron && \
    npm install -g cron-job-manager && \
    npm install -g --unsafe-perm raspi-io

# install node-red
RUN npm install -g --unsafe-perm  node-red

WORKDIR /root/bin
RUN ln -s /usr/bin/python2 ~/bin/python
RUN ln -s /usr/bin/python2-config ~/bin/python-config
env PATH ~/bin:$PATH

WORKDIR /root/.node-red
RUN npm install -g node-red-node-redis && \
    npm install -g node-red-contrib-googlechart && \
    npm install -g node-red-node-web-nodes && \
    npm install -g node-red-node-wemo && \
    npm install -g --unsafe-perm node-red-contrib-gpio 

RUN apt-get autoremove -y wget && \
    apt-get autoremove -y git && \
    apt-get autoremove -y build-essential

# run application
EXPOSE 1880
#CMD ["/bin/bash"]
ENTRYPOINT ["node-red-pi","-v","--max-old-space-size=128"]
