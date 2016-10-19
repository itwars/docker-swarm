#!/bin/bash

source ./box.sh
source ./variables.sh

box "Starting Docker Machine creation" "green" "blue"
for node in $(seq 1 $leaders);
do
   box "Node leader $node" "light-purple" "red"
   docker-machine create \
      --driver azure \
      --azure-location $location \
      --azure-subscription-id $id \
   leader$node 
done
ip=$(docker-machine ssh leader1 ifconfig eth0 | grep "inet addr" | cut -d ':' -f 2 | cut -d ' ' -f 1)
for node in $(seq 1 $workers);
do
   box "Node worker $node" "light-purple" "red"
   docker-machine create \
      --driver azure \
      --azure-location $location \
      --azure-subscription-id $id \
   worker$node 
done

eval "$(docker-machine env leader1)"
box "Init Swarm cluster" "light-purple" "blue"
docker swarm init --listen-addr $ip --advertise-addr $ip
workertok=$(docker swarm join-token -q worker)
for node in $(seq 1 $workers);
do
   eval "$(docker-machine env worker$node)"
   docker swarm join --token $workertok $ip:2377
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

# Azure firewall rules
azure config mode arm
for node in $(seq 1 $leaders);
do
   azure network nsg show docker-machine leader$node-firewall
   azure network nsg rule create docker-machine leader$node-firewall http --priority $priority --protocol tcp --destination-port-range 80 --source-address-prefix $my_ip
   azure network nsg rule create docker-machine leader$node-firewall http --priority $priority --protocol tcp --destination-port-range 5000 --source-address-prefix $my_ip
   priority=$(expr $priority + 1)
done
for node in $(seq 1 $workers);
do
   azure network nsg show docker-machine worker$node-firewall
   azure network nsg rule create docker-machine worker$node-firewall http --priority $priority --protocol tcp --destination-port-range 80 --source-address-prefix $my_ip
   priority=$(expr $priority + 1)
done

docker run -it -d -p 5000:5000 -e HOST=$(docker-machine ip leader1) -e PORT=5000 -v /var/run/docker.sock:/var/run/docker.sock manomarks/visualizer
box "Open web browser to visualize cluster" "light_purple" "green"
open http://$(docker-machine ip leader1):5000

box "To scale type:eval \$(docker-machine env leader1) && docker service scale web=10" "red" "red"
box "To remove swarm cluster and cleanup: ./remove.sh" "red" "red"
