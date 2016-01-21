# DOCKER-VERSION 1.0.0
FROM resin/rpi-raspbian

# install required packages, in one command
RUN apt-get update  && \
    apt-get install -y  python-dev

ENV PYTHON /usr/bin/python2

# install nodejs for rpi
RUN apt-get install -y wget && \
    wget http://node-arm.herokuapp.com/node_latest_armhf.deb && \
    dpkg -i node_latest_armhf.deb && \
    rm node_latest_armhf.deb

# install node-red
RUN apt-get install -y build-essential && \
    npm install -g --unsafe-perm  node-red

WORKDIR /root/bin
RUN ln -s /usr/bin/python2 ~/bin/python
RUN ln -s /usr/bin/python2-config ~/bin/python-config
env PATH ~/bin:$PATH

WORKDIR /root/.node-red
RUN apt-get install -y git && \
    npm install node-red-node-redis && \
    npm install node-red-contrib-googlechart && \
    npm install node-red-node-web-nodes && \
    npm install node-red-node-wemo && \
    npm install cron && \
    npm install cron-job-manager && \
    npm install --unsafe-perm raspi-io && \
    npm install --unsafe-perm node-red-contrib-gpio 

RUN apt-get autoremove -y wget && \
    apt-get autoremove -y git && \
    apt-get autoremove -y build-essential

# run application
EXPOSE 1880
#CMD ["/bin/bash"]
ENTRYPOINT ["node-red-pi","-v","--max-old-space-size=128"]
