FROM ubuntu:16.04

RUN apt-get update && \
    apt-get -y install build-essential libreadline-dev zlib1g-dev flex bison libkeyutils-dev libnss3 default-jre vim

RUN useradd -m -c "AgensGraph User" -U agens -p agens

RUN mkdir -p /home/agens/AgensGraph/data
RUN chown -R agens:agens /home/agens
RUN chmod -R 700 /home/agens

ENV AGDATA=/home/agens/AgensGraph/data \
    PATH=/home/agens/AgensGraph/bin:$PATH \
    LD_LIBRARY_PATH=/home/agens/AgensGraph/lib:$LD_LIBRARY_PATH \
    AGHOME=/home/agens/AgensGraph

ADD AgensGraph-v1.3.1_linux.tar.gz /home/agens

RUN mkdir -p /home/agens/scripts
ADD entrypoint.sh /home/agens/scripts
RUN chmod +x /home/agens/scripts/entrypoint.sh

USER agens
EXPOSE 5432

RUN set -e;\
    initdb;\
	ag_ctl start; sleep 5;\
	createdb;\
	agens -c "create graph agens_graph";\
    ag_ctl stop

ENTRYPOINT ["/home/agens/scripts/entrypoint.sh"]
