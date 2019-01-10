FROM debian:jessie
 
RUN groupadd -r agens --gid=999 && useradd -ms /bin/bash -r -g agens --uid=999 agens    
 
RUN apt-get update && \
    apt-get -y install build-essential libreadline-dev zlib1g-dev flex bison libkeyutils-dev libnss3 default-jre vim
 
ENV GOSU_VERSION 1.10
RUN set -ex; \
    \
    fetchDeps=' \
        ca-certificates \
        wget \
    '; \
    apt-get install -y --no-install-recommends $fetchDeps; \
    rm -rf /var/lib/apt/lists/*; \
    \
    dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
    wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
    wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
    \
# verify the signature
    export GNUPGHOME="$(mktemp -d)"; \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
    gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
    rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc; \
    \
    chmod +x /usr/local/bin/gosu; \
# verify that the binary works
    gosu nobody true; \
    \
    apt-get purge -y --auto-remove $fetchDeps
 
RUN useradd -ms /bin/bash stolon
ADD bin/stolon-keeper bin/stolon-sentinel bin/stolon-proxy bin/stolonctl /usr/local/bin/
RUN chmod +x /usr/local/bin/stolon-keeper /usr/local/bin/stolon-sentinel /usr/local/bin/stolon-proxy /usr/local/bin/stolonctl
 
RUN mkdir -p /home/agens
ADD AgensGraph-v1.3.1_linux.tar.gz /home/agens
 
RUN sed -ri "s!^#?(listen_addresses)\s*=\s*\S+.*!\1 = '*'!" /home/agens/AgensGraph/share/postgresql/postgresql.conf.sample

RUN mkdir -p /home/agens/AgensGraph/data
RUN chown -R agens:agens /home/agens
RUN chmod -R 700 /home/agens


ENV PGDATA=/home/agens/AgensGraph/data \
    PATH=/home/agens/AgensGraph/bin:$PATH \
    LD_LIBRARY_PATH=/home/agens/AgensGraph/lib:$LD_LIBRARY_PATH \
    PGHOME=/home/agens/AgensGraph

VOLUME /home/agens/AgensGraph/data
 
RUN mkdir -p /home/agens/scripts
ADD docker-ag-entrypoint.sh /home/agens/scripts
RUN chmod +x /home/agens/scripts/docker-ag-entrypoint.sh
ENTRYPOINT ["/home/agens/scripts/docker-ag-entrypoint.sh"]


EXPOSE 5432
CMD ["postgres"]
