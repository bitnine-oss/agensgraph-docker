## AgensGraph Docker    

# Tag Info   
* **v2.1.1**, **latest** : AgensGraph v2.1.1 / centos7

# Usage (docker)    
* Image download       
$ docker pull bitnine/agensgraph:v2.1.1       

* Create Volume
$ docker volume create --name myvolume

* Container starting           
    - agens 
      (Temporary mode)
      $ docker run -it bitnine/agensgraph:v2.1.1 agens
      (Save mode) 
      $ docker run -i -t -v myvolume:/home/agens/AgensGraph/data bitnine/agensgraph:v2.1.1 agens
    - bash 
      $ docker run -it bitnine/agensgraph:v2.1.1 /bin/bash

# Usage (AgensGraph)     
The image already has a graph("agens_graph"), and you can see the list of graphs created with the `\dG` command.
* list graph
agens=# \dG
* set graph
agens=#  set graph_path=graph_name;
* show graph
agens=#  show graph_path;

# Reference
* AgensGraph Quick Guide : http://bitnine.net/wp-content/uploads/2017/06/html5/1.3-quick-guide.html
* Dockfile : https://github.com/bitnine-oss/agensgraph-docker.git
