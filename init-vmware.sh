#!/bin/bash

source ./box.sh
source ./variables.sh

box "Starting Docker Machine creation" "green" "blue"
for node in $(seq 1 $leaders);
do
   box "Node leader $node" "light_purple" "red"
   docker-machine create \
      --engine-env 'DOCKER_OPTS="-H unix:///var/run/docker.sock"' \
      --driver vmwarevsphere \
	  --vmwarevsphere-username=${ESX_USER} \
	  --vmwarevsphere-password=${ESX_PASS} \
	  --vmwarevsphere-vcenter=${ESX_IP} \
   leader$node
done
for node in $(seq 1 $workers);
do
   box "Node worker $node" "light_purple" "red"
   docker-machine create \
      --engine-env 'DOCKER_OPTS="-H unix:///var/run/docker.sock"' \
      --driver vmwarevsphere \
	  --vmwarevsphere-username=${ESX_USER} \
	  --vmwarevsphere-password=${ESX_PASS} \
	  --vmwarevsphere-vcenter=${ESX_IP} \
   worker$node
done

eval "$(docker-machine env leader1)"
box "Init Swarm cluster" "light_purple" "blue"
docker swarm init --listen-addr $(docker-machine ip leader1) --advertise-addr $(docker-machine ip leader1)
token=$(docker swarm join-token -q worker)

for node in $(seq 1 $workers);
do
   eval "$(docker-machine env worker$node)"
   docker swarm join --token $token $(docker-machine ip leader1):2377
done

eval $(docker-machine env leader1)
box "Overlay Network creation" "light_purple" "blue"
docker network create -d overlay swarmnet
box "Starting WebStack services" "light_green" "green"
docker service create --name phpfpm --network swarmnet --publish 9000:9000 itwars/phpfpm
docker service create --name web    --network swarmnet --publish 8001:8001 itwars/h2o
docker service create --name cache  --network swarmnet --publish 8000:8000 itwars/varnish
docker service create --name lb     --network swarmnet --publish 80:80     itwars/haproxy
sleep $t

docker run -it -d -p 5000:5000 -e HOST=$(docker-machine ip leader1) -e PORT=5000 -v /var/run/docker.sock:/var/run/docker.sock manomarks/visualizer
box "Open web browser to visualize cluster" "light_purple" "green"
open http://$(docker-machine ip leader1):5000

box "To scale type:eval \$(docker-machine env leader1) && docker service scale web=10" "red" "red"
box "To remove swarm cluster and cleanup: ./remove.sh" "red" "red"
