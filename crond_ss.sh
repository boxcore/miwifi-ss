#!/bin/sh

cd /tmp
/usr/bin/curl -o gfwlist.conf https://raw.githubusercontent.com/boxcore/miwifi-ss/master/tmp/dnsmasq.d-gfwlist.conf

/etc/init.d/dnsmasq restart
/etc/init.d/firewall restart
/etc/init.d/shadowsocks restart
