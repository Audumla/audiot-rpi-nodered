# audiot-nodered
This is a docker implemetation for running Node-Red and MQTT (Mosquitto) on a RaspberryPi, providing a base set of node-red packages including GPIO access and the Johnnyfive enabled node-red-contrib.gpio. Also provided is a docker-compose configuration that is preconfigured to hook the docker images to the RaspberryPi hardware and connectivity between the containers. 

Advantages of using docker on this environment are,
  Easily apply newer versions of node-red
  Swap in different MQTT implementations without impacting the installed flows
  Issolate each component into discrete containers without impacting the host system
  Easily migrate to a new host platform
  Templated environments to segregate non-production or test from production

The downside to this is overcoming the issues imposed by the segrated nature of the docker system. Notably these occur when nodejs packages have build dependancies that are not within the docker container. To simplify this the base Docker file builds all dependant libraries for the more troublesome packages, like node-red-contrib-gpio.  

docker-compose provides a clean method to expose ports and device mappings to the containers and allows an easy way to load the entire setup on boot.

# Docker Compose
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

# Add new nodes
To add new nodes get the docker id using docker ps, and then shell into the docker container.
Installing the nodes through the docker container ensures that the build processes will execute using the versions contained within the contained and not the host system. The generated output files however will be stored in the node_modules directory located on the host and not within the container. This ensures that the docker container is not modified and can be swapped out at a later stage.

If the node-red container is updated however, the nodes may need to be reinstalled as version numbers are often stored as part of the build process.

```Shell

docker ps
docker exec -it [docker_id] bash
sudo npm --unsafe-perm install [node_id]
```
