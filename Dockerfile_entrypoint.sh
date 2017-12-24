#!/usr/bin/env sh

#ssh-keygen -A
export HOST_IP=`cat /etc/resolv.conf  | grep ^nameserver | cut -d\  -f2 | head -n1`

docker-gen -watch -only-exposed -notify "/root/dnsmasq-restart.sh -u root $@" /root/dnsmasq.tpl /etc/dnsmasq.conf

test $HOSTUNAME = "Darwin" && (
    iptables -I INPUT -p udp --dport 11149 -j ACCEPT
    iptables -t nat -A POSTROUTING -s 172.17.0.0/24 -d 0.0.0.0/0 -o eth0 -j MASQUERADE
    iptables -I FORWARD -i eth0 -o tun0 -j ACCEPT
    iptables -I FORWARD -i tun0 -o eth0 -j ACCEPT
    iptables -t nat -P POSTROUTING ACCEPT
    iptables -t nat -P PREROUTING ACCEPT
    iptables -t nat -P OUTPUT ACCEPT

    openvpn /etc/openvpn/openvpn.conf &
)

syslogd -n -O /dev/stdout