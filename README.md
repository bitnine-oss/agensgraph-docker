## Tag Info

* **v2.1.3 ( latest )** : alpine:3.13
* **v2.1.1 ** : CentOS 7 / Java 8
* **v2.1.0** : CentOS 7 / Java 8
* **v2.0.0** : CentOS 7 / Java 8
* **v1.3.2** : CentOS 7 / Java 8
* **v1.3.1** : CentOS 7 / Java 8
* **v1.3.0** : CentOS 7 / Java 8



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
bash-5.1# psql
psql: FATAL:  role "root" does not exist
bash-5.1# su - postgres
7ae96ba6af71:~$ psql
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



# Reference
* AgensGraph Quick Guide : http://bitnine.net/wp-content/uploads/2017/06/html5/1.3-quick-guide.html
* Dockerfile repository : https://github.com/bitnine-oss/agensgraph-docker.git

