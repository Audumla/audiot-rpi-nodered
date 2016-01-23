# audiot-rpi-nodered
Docker Image with [Node.js](https://nodejs.org/) and [Node-RED](http://nodered.org/)
Based on [Raspbian Jessie](resin/rpi-raspbian:jessie) image using armv6l based builds

A docker implementation for Node-Red on a RaspberryPi providing native device access such as GPIO, I2C etc. The base image 

Built with device access to GPIO, I2C etc, and pre installed modules: 
   * node-red-contrib-gpio
   * raspi-io

Installed libraries:
   * Node-RED : v0.13.1
   * Node.js : v5.5.0
   * Python : v2.7
   * WiringPI : v2.31

Also available with a docker-compose configuration with RaspberryPi hardware and connectivity to an accompanying MQTT docker container. 

Capabilities provided through the use of docker are,
  * Easily apply newer versions of node-red
  * Swap in different MQTT implementations without impacting the installed flows
  * Issolate each component into discrete containers without impacting the host system
  * Easily migrate to a new host platform
  * Templated environments to segregate non-production or test from production

Issues that often need to be overcome occur when nodejs packages have build dependancies that are not part of the base docker container and utilize mutlitple languages. To simplify this the provide Docker file builds dependant libraries for the more troublesome packages and loads them into the global node context. More modules may be added over time to simplify using node-red within a docker container on the RaspberryPi platform  

#Installation and Setup

i2c must be exposed on the host system otherwise the raspi-io module will fail when the docker container starts node-red. To ensure i2c is available, run the following commands  
```Shell

sudo apt-get install i2c-dev
sudo modprobe i2c-dev
ls /dev/i2c*
```

# Docker Compose
To provide a clean and simple set of configuration, docker-compose is used to expose ports and device mappings to the containers and allows an easy way to load the entire setup on boot.

# Installing Node Modules
Adding nodes should be performed from within the docker container so that the build processes utilize the docker installed libraries and not the host systems. Otherwise version conflicts may occur. 
Generated node module output files will be stored in the containers /root/.node-red/node_modules directory. This should be mapped to a directory within the host system, or a docker volume, to ensure that the docker container is not modified and can be swapped out at a later stage. 

Modules that produce output files that are not installed under this node_modules directory may require customization of the Dockerfile itself, or more volume points within the container. 

When upgrading or changing the version of the node-red container, post installed modules may need to be rebuilt as version numbers are often stored as part of the module build process.

The following commands can be used to install a new module using the container
```Shell

docker ps
docker exec -it [docker_id] bash
cd /root/.node-red
sudo npm install [module]
```
#Useful Docker Commands

Run the Node-red docker image from command line
```Shell

docker run --cap-add=SYS_RAWIO --privileged=true -it audiot-rpi-nodered
```

Build the audio-rpi-nodered docker image
```Shell

docker build --rm -t audiot-rpi-nodered .
```

Start/Stop the docker containers using docker-compose
```Shell

docker-compose up     //forground
docker-compose start  //background
docker-compose stop
```

Open a shell to the running docker image
```Shell

docker exec -it [docker_id] bash
```


