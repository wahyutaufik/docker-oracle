FROM ubuntu:14.04

MAINTAINER Wahyu Taufik <wahyutaufik37@gmail.com>

# get rid of the message: "debconf: unable to initialize frontend: Dialog"
ENV DEBIAN_FRONTEND noninteractive

ENV APT_PROXY http://192.168.1.10:3128

ADD chkconfig /sbin/chkconfig
ADD oracle-install.sh /oracle-install.sh
ADD init.ora /
ADD initXETemp.ora /

# use proxy
RUN echo "\n\
	Acquire::HTTP::Proxy \"$APT_PROXY\";\n\
	Acquire::HTTPS::Proxy \"$APT_PROXY\";\n\
	" > /etc/apt/apt.conf.d/01proxy

# Prepare to install Oracle
RUN apt-get update && apt-get install -y -q libaio1 net-tools bc curl rlwrap && \
apt-get clean && \
rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/* &&\
ln -s /usr/bin/awk /bin/awk &&\
mkdir /var/lock/subsys &&\
chmod 755 /sbin/chkconfig &&\
/oracle-install.sh

# see issue #1
ENV ORACLE_HOME /u01/app/oracle/product/11.2.0/xe
ENV PATH $ORACLE_HOME/bin:$PATH
ENV ORACLE_SID=XE

EXPOSE 1521
EXPOSE 8080
VOLUME ["/u01/app/oracle"]

ENV processes 500
ENV sessions 555
ENV transactions 610

ADD entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
CMD [""]