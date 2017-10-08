![docker swarm on virtualbox:passing](img/virtualbox-passing.jpg) ![docker swarm on ovh openstack:passing](img/ovh-openstack-passing.jpg) ![docker swarm on azure:passing](img/azure-passing.jpg) 

This repository is part of a blog post on **Docker Swarm 1.12** example using *VirtualBox*, **OVH Openstack**, Microsoft Azure:

- [IT wars Docker swarm VirtualBox example](http://www.it-wars.com/posts/virtualisation/docker-swarm-par-lexemple/)
- [IT wars Docker swarm OVH Openstack example](http://www.it-wars.com/posts/virtualisation/docker-swarm-112-ovh/)
- [IT wars Docker swarm Azure example](http://www.it-wars.com/posts/virtualisation/docker-swarm-112-azure/)


![Docker Swarm](img/docker-swarm.gif)

Script in action:

![Docker swarm scale](img/docker-swarm-scale.gif)

- The init-virtualbox.sh script will automaticaly create several *VirtualBox VM* using **docker-machine** and start **Docker Swarm Ochestrator**
- The init-ovh.sh script will automaticaly create several *OVH Openstack VM* using **docker-machine** and start **Docker Swarm Cluster**
- The init-azure.sh script will automaticaly create several *Microsoft Azure cloud VM* using **docker-machine** and init **Docker Swarm Scalable Services**
- Then it create a virtual network (optional)
- Finaly start a web stack with *docker swarm services*

[![asciicast](https://asciinema.org/a/bup8txirvsiszylckkzrng5gr.png)](https://asciinema.org/a/bup8txirvsiszylckkzrng5gr)

- This **web stack** is based on :

   - haproxy loadbalancer
   - varnish cache
   - [h2o web server](http://www.it-wars.com/posts/performance/web-performance-H2O-vs-nginx/)
   - phpfpm application server

Fill free to fork my code and have a look to my blog series.

- [IT wars Docker swarm VirtualBox example](http://www.it-wars.com/posts/virtualisation/docker-swarm-par-lexemple/)
- [IT wars Docker swarm OVH Openstack example](http://www.it-wars.com/posts/virtualisation/docker-swarm-112-ovh/)
- [IT wars Docker swarm Azure example](http://www.it-wars.com/posts/virtualisation/docker-swarm-112-azure/)

