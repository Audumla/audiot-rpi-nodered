# audiot-nodered
This is a docker implemetation for running Node-Red and MQTT (Mosquitto) on a RaspberryPi, providing a base set of node-red packages including GPIO access and the Johnnyfive enabled node-red-contrib.gpio. Also provided is a docker-compose configuration that is preconfigured to hook the docker images to the RaspberryPi hardware and connectivity between the containers. 

Advantages of using docker on this environment are,
  * Easily apply newer versions of node-red
  * Swap in different MQTT implementations without impacting the installed flows
  * Issolate each component into discrete containers without impacting the host system
  * Easily migrate to a new host platform
  * Templated environments to segregate non-production or test from production

The downside to this is overcoming the issues imposed by the segrated nature of the docker system. Notably these occur when nodejs packages have build dependancies that are not part of the base docker container and utilize mutlitple languages. To simplify this the base Docker file builds all dependant libraries for the more troublesome packages, like node-red-contrib-gpio.  

#Installation and Setup

i2c must be exposed on the host system otherwise the raspi-io module will fail when the docker container starts node-red. To ensure i2c is available, run the following commands  
```Shell

sudo modprobe i2c-dev
ls /dev/i2c*
```

# Docker Compose
To provide a clean and simple set of configuration, docker-compose is used to expose ports and device mappings to the containers and allows an easy way to load the entire setup on boot.

```YAML

nodered:
  restart: always
  image: nieleyde/rpi-nodered
  command: flows.json
  volumes:
    - /home/pi/node-red:/root/.node-red
    - /etc/localtime:/etc/localtime
  ports: 
    - "1880:1880"
  links:
    - mosquitto
  cap_add:
    - SYS_RAWIO
  devices:
    - "/dev/mem:/dev/mem"
    - "/dev/ttyAMA0:/dev/ttyAMA0"

mosquitto:
  restart: always
  image: nieleyde/rpi-mosquitto
  volumes:
    - /etc/localtime:/etc/localtime
  ports:
    - "1883:1883"
```

# Install Node Modules
Adding nodes should be performed from within the docker container so that the build processes utilize the docker installed libraries and not the host systems, which may cause version conflicts. The generated node module output files will be stored in the node_modules directory. This should be mapped to a directory within host system, or a docker volume, to ensures that the docker container is not modified and can be swapped out at a later stage. If however the build produces output files that are not installed under the node_modules directory then it may be necessary to customize the Dockerfile itself, or create more volume points within the container. 
When upgrading or chaning the version of the node-red container modules may need to be reinstalled as version numbers are often stored as part of the module build process.

The following commands can be used to install a new module using the container itself
```Shell

docker ps
docker exec -it [docker_id] bash
sudo npm --unsafe-perm install [module]
```
#Useful Docker Commands

Run the Node-red docker image from command line
```Shell

docker run --cap-add=SYS_RAWIO --device=/dev/mem:/dev/mem --device=/dev/ttyAMA0:/dev/ttyAMA0 -it audiot-rpi-nodered
```

Build the ndoer-red docker image
```Shell

docker build --rm -t audiot-rpi-nodered .
```

Start/Stop the docker images
```Shell

docker-compose up     //forground
docker-compose start  //background
docker-compose stop
```

Open a shell to the running docker image
```Shell

docker exec -it [docker_id] bash
```


