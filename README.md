This repository is part of a blog post on **Docker Swarm 1.12** example using *VirtualBox*.
(Docker Swarm)[img/docker-swarm.gif]
- The init-virtualbox.sh script will automaticaly create several VirtualBox using *docker-machine*
- Then it create a virtual network (optional)
- Finaly start a web stack with *docker swarm services*
- This **web stack** is based on :

   - haproxy loadbalancer
   - varnish cache
   - h2o web server
   - phpfpm application server

Fill free to fork my code and have a look to my blog IT wars : http://www.it-wars.com
