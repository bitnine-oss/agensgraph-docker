## Tag Info

* **v2.5.0**
  * v2.5.0 - alpine:3.14
  * v2.5.0-debian - debian:bullseye-slim
  * v2.5.0-centos - centos:8
* **v2.1.3**
  * v2.1.3 - alpine:3.13
  * v2.1.3-debian - debian:stretch
* older than **v2.1.1**
  * Based on CentOS 7

## Getting started

### Quick start

```shell
$ docker run --name agensgraph -e POSTGRES_PASSWORD=agensgraph -d bitnine/agensgraph:v2.1.3
# Username: postgres
# Password: agensgraph
```



### Advanced

- All environment arguments compatibility with postgresql, so you can read more deeply in the README of postgresql docker.
    - https://hub.docker.com/_/postgres

```shell
$ docker run -d \
    --name agensgraph \
    -e POSTGRES_PASSWORD=agensgraph \
    -e PGDATA=/var/lib/postgresql/data/pgdata \
    -v /custom/mount:/var/lib/postgresql/data \
    bitnine/agensgraph:v2.1.3
```



## Deep into AgensGraph

The image already has a graph("agens_graph"), and you can see the list of graphs created with the `\dG` command.

```shell
$ docker exec -it {NAME OR CONTAINER_ID} /bin/bash
bash-5.1# psql -u postgres
psql (10.4)
Type "help" for help.

postgres=# CREATE GRAPH AGENS;
CREATE GRAPH
postgres=# SET GRAPH_PATH=AGENS;
SET
postgres=# CREATE (:person {name: 'Tom'})-[:knows]->(:person {name: 'Summer'});
UPDATE 3
postgres=# CREATE (:person {name: 'Pat'})-[:knows]->(:person {name: 'Nikki'});
UPDATE 3
postgres=# CREATE (:person {name: 'Olive'})-[:knows]->(:person {name: 'Todd'});
UPDATE 3
postgres=# MATCH (n) RETURN n;
               n               
-------------------------------
 person[3.7]{"name": "Tom"}
 person[3.8]{"name": "Summer"}
 person[3.9]{"name": "Pat"}
 person[3.10]{"name": "Nikki"}
 person[3.11]{"name": "Olive"}
 person[3.12]{"name": "Todd"}
(6 rows)
```

# Older than v2.1.3
### Usage (docker)    

##### Image download

```
$ docker pull bitnine/agensgraph:v2.1.1
```



##### Create Volume

```
$ docker volume create --name myvolume
```

##### Container starting

- agens
  -  Temporary mode
    ```$ docker run -it bitnine/agensgraph:v2.1.1 agens```
  - Save mode
    ```$ docker run -i -t -v myvolume:/home/agens/AgensGraph/data bitnine/agensgraph:v2.1.1 agens```
- bash 
  ```$ docker run -it bitnine/agensgraph:v2.1.1 /bin/bash```



### Usage (AgensGraph)     

The image already has a graph("agens_graph"), and you can see the list of graphs created with the `\dG` command.
* list graph
```agens=# \dG```
* set graph
```agens=#  set graph_path=graph_name;```
* show graph
```agens=#  show graph_path;```



# Reference
* AgensGraph Quick Guide : https://bitnine.net/documentations/manual/agens_graph_quick_guide.html
* Dockerfile repository : https://github.com/bitnine-oss/agensgraph-docker.git

