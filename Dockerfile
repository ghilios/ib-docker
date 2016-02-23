FROM relateiq/oracle-java8
MAINTAINER George Hilios <ghilios@gmail.com>

# install xvfb and other X dependencies for IB
RUN apt-get update -y \
    && apt-get install -y xvfb libxrender1 libxtst6 x11vnc socat unzip\
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

WORKDIR /tmp
RUN mkdir /root/IBController && \
    wget https://github.com/ib-controller/ib-controller/releases/download/2.14.0/IBController-2.14.0.zip && \
	wget http://download2.interactivebrokers.com/download/unixmacosx_latest.jar
WORKDIR /opt
RUN unzip /tmp/IBController-2.14.0.zip && \
    jar xf /tmp/unixmacosx_latest.jar && \
	chmod a+x IBController/*.sh

COPY config/IBController.ini /root/IBController/IBController.ini
COPY config/jts.ini /opt/IBJts/jts.ini
COPY config/ibg.xml /opt/IBJts/dfmhgqmywm/ibg.xml
COPY config/tws.xml /opt/IBJts/dfmhgqmywm/tws.xml
COPY init/xvfb_init /etc/init.d/xvfb
COPY init/vnc_init /etc/init.d/vnc
COPY bin/xvfb-daemon-run /usr/bin/xvfb-daemon-run
COPY bin/run-gateway /usr/bin/run-gateway

# 5900 for VNC, 4003 for the gateway API via socat
EXPOSE 5900 4003
VOLUME /root
VOLUME /opt/IBJts/dfmhgqmywm

ENV DISPLAY :0

CMD ["/usr/bin/run-gateway"]
