## AgensGraph Docker    

# Usage (docker-compose)    
This fork runs AgensGraph in the foreground so it can be used with `docker-compose`.

```Dockerfile
# db/Dockerfile
FROM wenkepaul/agensgraph
... Create your schema, seeding, etc.
```

```docker-compose.yml
version: '3.7'
services:
  db:
    build: db
    ports:
      - 3306:3306
```

# Reference
* dockerhub : https://hub.docker.com/r/wenkepaul/agensgraph/tags
* Forked from : https://github.com/bitnine-oss/agensgraph-docker
* AgensGraph Quick Guide : http://bitnine.net/wp-content/uploads/2017/06/html5/1.3-quick-guide.html
* Dockfile : https://github.com/bitnine-oss/agensgraph-docker.git
