FROM centos:7

RUN yum install -y gcc glibc glib-common readline readline-devel zlib zlib-devel flex bison vim java-1.8.0-openjdk net-tools

RUN useradd -m -c "AgensGraph User" -U agens -p agens

RUN mkdir -p /home/agens/AgensGraph/data
RUN chown -R agens:agens /home/agens
RUN chmod -R 700 /home/agens

ENV AGDATA=/home/agens/AgensGraph/data \
    PATH=/home/agens/AgensGraph/bin:$PATH \
    LD_LIBRARY_PATH=/home/agens/AgensGraph/lib:$LD_LIBRARY_PATH \
    AGHOME=/home/agens/AgensGraph

ADD AgensGraph_v2.1.0_linux_CE.tar.gz /home/agens

RUN mkdir -p /home/agens/scripts
ADD entrypoint.sh /home/agens/scripts
RUN chmod +x /home/agens/scripts/entrypoint.sh

#RUN sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" $AGDATA/postgresql.conf
#RUN echo "host all all 0.0.0.0/0 password" >> $AGDATA/pg_hba.conf

USER agens
EXPOSE 5432
ExPOSE 8085

RUN set -e
RUN initdb

RUN sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" $AGDATA/postgresql.conf
RUN echo "host	all	all	0.0.0.0/0	trust" >> $AGDATA/pg_hba.conf

RUN ag_ctl start; sleep 5;\
    createdb;\
    agens -c "create graph agens_graph";\
    ag_ctl stop

ENTRYPOINT ["/home/agens/scripts/entrypoint.sh"]
