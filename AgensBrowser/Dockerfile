FROM ubuntu

RUN apt-get update &&\
    apt-get -y install build-essential libreadline-dev zlib1g-dev flex bison libkeyutils-dev libnss3 default-jre vim

RUN useradd -m -c "AgensGraph User" -U agens -p agens

RUN mkdir -p /home/agens/AgensGraph/data
RUN chmod -R +x /home/agens

ENV AGDATA=/home/agens/AgensGraph/data \
    PATH=/home/agens/AgensGraph/bin:$PATH \
    LD_LIBRARY_PATH=/home/agens/AgensGraph/lib:$LD_LIBRARY_PATH \
    AGHOME=/home/agens

ADD AgensGraph-v1.3.1_linux.tar.gz /home/agens

RUN mkdir -p /home/agens/scripts
RUN mkdir -p /home/agens/AgensBrowser
ADD entrypoint.sh /home/agens/scripts
RUN chmod +x /home/agens/scripts/entrypoint.sh
ADD northwind_rdb1_import.sql /home/agens/scripts
ADD northwind_rdb2_to_gdb.sql /home/agens/scripts
ADD ./AgensBrowser/* /home/agens/AgensBrowser/
RUN chown -R agens:agens /home/agens
RUN chmod -R +x /home/agens

USER agens
EXPOSE 5432

RUN set -e;\
    initdb; ag_ctl start; sleep 5; createdb;\
	sleep 1;\
	agens -q -f /home/agens/scripts/northwind_rdb1_import.sql;\
	agens -q -f /home/agens/scripts/northwind_rdb2_to_gdb.sql;\
    ag_ctl stop

ENTRYPOINT ["/home/agens/scripts/entrypoint.sh"]


