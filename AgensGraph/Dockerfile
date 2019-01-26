FROM centos:7

RUN yum install -y gcc glibc glib-common readline readline-devel zlib zlib-devel

#RUN apt-get update && \
#apt-get install -y build-essential libreadline-dev zlib1g-dev flex bison libxml2 openssl

RUN useradd -m -c "AgensGraph User" -U agens -p agens

RUN mkdir -p /home/agens/AgensGraph/data
RUN chown -R agens:agens /home/agens
RUN chmod -R 700 /home/agens

ENV AGDATA=/home/agens/AgensGraph/data \
    PATH=/home/agens/AgensGraph/bin:$PATH \
    LD_LIBRARY_PATH=/home/agens/AgensGraph/lib:$LD_LIBRARY_PATH \
    AGHOME=/home/agens/AgensGraph

ADD AgensGraph_v2.1.0_linux_CE.tar.gz /home/agens

USER agens
EXPOSE 5432

RUN set -e;\
    initdb;\
    ag_ctl start; sleep 5;\
    createdb;\
    agens -c "create graph agens_graph";\
    ag_ctl stop

CMD ["postgres"]
