#!/bin/bash

source ./box.sh
source ./variables.sh


box "Setting security network groups" "red" "blue"
#### Set up Security Group in AWS
aws ec2 create-security-group --group-name ${group_name} --description "A Security Group for Docker Networking" > /dev/null 2>&1
# Permit SSH, required for Docker Machine
aws ec2 authorize-security-group-ingress --group-name ${group_name} --protocol tcp --port 22    --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-name ${group_name} --protocol tcp --port 2376  --cidr ${my_ip}/${mask}
aws ec2 authorize-security-group-ingress --group-name ${group_name} --protocol tcp --port 2377  --cidr ${my_ip}/${mask}
#aws ec2 authorize-security-group-ingress --group-name ${group_name} --protocol tcp --port 5000  --cidr ${my_ip}/${mask}
# Permit Serf ports for discovery
aws ec2 authorize-security-group-ingress --group-name ${group_name} --protocol tcp --port 7946  --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-name ${group_name} --protocol udp --port 7946  --cidr 0.0.0.0/0
# Permit VXLAN
aws ec2 authorize-security-group-ingress --group-name ${group_name} --protocol tcp --port 4789  --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-name ${group_name} --protocol udp --port 4789  --cidr 0.0.0.0/0
#Permit WEB for demo
aws ec2 authorize-security-group-ingress --group-name ${group_name} --protocol tcp --port 8080  --cidr ${my_ip}/${mask}
aws ec2 authorize-security-group-ingress --group-name ${group_name} --protocol tcp --port 5000  --cidr ${my_ip}/${mask}
aws ec2 authorize-security-group-ingress --group-name ${group_name} --protocol tcp --port 5001  --cidr ${my_ip}/${mask}


box "Starting Docker Machine creation" "green" "blue"
for node in $(seq 1 $leaders);
do
   box "Node leader $node" "light-purple" "red"
   docker-machine create \
   --driver amazonec2 \
   --amazonec2-region ${region} \
   --amazonec2-security-group ${group_name} \
   leader$node &
done
wait
ip=$(docker-machine ssh leader1 ifconfig eth0 | grep "inet addr" | cut -d ':' -f 2 | cut -d ' ' -f 1)

for node in $(seq 1 $workers);
do
   box "Node worker $node" "light-purple" "red"
   docker-machine create \
   --driver amazonec2 \
   --amazonec2-region ${region} \
   --amazonec2-security-group ${group_name} \
   worker$node &
done
wait

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
box "Overlay Network creation" "light-purple" "blue"
docker network create -d overlay swarmnet

box "Starting App" "light-green" "green"
docker stack deploy --compose-file docker-stack.yml vote

box "Open web browser" "light-purple" "green"
open http://$(docker-machine ip leader1):8080
open http://$(docker-machine ip leader1):5000
open http://$(docker-machine ip leader1):5001