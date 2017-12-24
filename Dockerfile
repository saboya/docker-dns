FROM alpine:latest
MAINTAINER Zanaca "carlos@zanaca.com"

VOLUME /var/run
EXPOSE 53/udp 53 11194/udp

ENV DOCKER_GEN_VERSION 0.7.3
ENV DOCKER_HOST unix:///var/run/docker.sock
ENV UNAME Linux
ENTRYPOINT ["/root/entrypoint.sh"]
RUN echo "nameserver 8.8.4.4" > /etc/resolv.conf
RUN echo "nameserver 8.8.8.8" > /etc/resolv.conf

RUN apk --no-cache add dnsmasq openssl openvpn
RUN wget -qO- https://github.com/jwilder/docker-gen/releases/download/$DOCKER_GEN_VERSION/docker-gen-alpine-linux-amd64-$DOCKER_GEN_VERSION.tar.gz | tar xvz -C /usr/local/bin
ADD conf/dnsmasq.tpl /root/dnsmasq.tpl
ADD dnsmasq-restart.sh /root/dnsmasq-restart.sh
ADD Dockerfile_entrypoint.sh /root/entrypoint.sh

ADD conf/openvpn.conf /etc/openvpn
RUN mkdir /etc/openvpn/certs.d
ADD conf/certs.d /etc/openvpn/certs.d
RUN chmod 600 /etc/openvpn/certs.d/*.key

RUN echo net.ipv4.ip_forward = 1 >> /etc/sysctl.conf
