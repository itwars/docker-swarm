#!/bin/bash

source ./variables.sh
source ./box.sh

eval "$(docker-machine env leader1)"
docker service rm lb cache web phpfpm
sleep $t
docker ps -a | grep Exit | cut -d ' ' -f 1 | xargs docker rm
docker ps -a | grep Created | cut -d ' ' -f 1 | xargs docker rm
sleep $t
docker rmi $(docker images | grep "^<none>" | awk "{print $3}")
docker rmi itwars/h2o itwars/varnish itwars/haproxy itwars/phpfpm

for node in $(seq 1 $workers);
do
   eval "$(docker-machine env worker$node)"
   docker swarm leave
done
for node in $(seq 1 $leaders);
do
   eval "$(docker-machine env leader$node)"
   docker swarm leave --force 
done
for node in $(seq 1 $workers);
do
   docker-machine rm worker$node --force 
done
for node in $(seq 1 $leaders);
do
   docker-machine rm leader$node --force 
done
