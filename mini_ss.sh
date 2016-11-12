#!/bin/sh

clear
echo "#############################################################"
echo "#             Install Shadowsocks for Miwifi(mini)          #"
echo "#############################################################"

cd /tmp
# rm -f shadowsocks_mini.tar.gz
# wget http://okss.tk/xiaomi/mini/shadowsocks_mini.tar.gz

if [ -s shadowsocks_mini.tar.gz ]; then
  echo "shadowsocks_mini.tar.gz [found]"
else
  echo "Error: shadowsocks_mini.tar.gz not found!!!download now......"
  curl -o shadowsocks_mini.tar.gz https://raw.githubusercontent.com/boxcore/miwifi-ss/master/tmp/shadowsocks_mini.tar.gz
fi

if [ -s dnsmasq.d-gfwlist.conf ]; then
  echo "dnsmasq.d-gfwlist.conf [found]"
else
  echo "Error: dnsmasq.d-gfwlist.conf not found!!!download now......"
  curl -o dnsmasq.d-gfwlist.conf https://raw.githubusercontent.com/boxcore/miwifi-ss/master/tmp/dnsmasq.d-gfwlist.conf
fi

tar zxf shadowsocks_mini.tar.gz

# install shadowsocks ss-redir to /data/usr/sbin
mkdir -p /data/usr/sbin


cp -f ./shadowsocks_mini/ss-redir  /data/usr/sbin/ss-redir
chmod +x /data/usr/sbin/ss-redir

# Config shadowsocks init script
cp ./shadowsocks_mini/shadowsocks /etc/init.d/shadowsocks
chmod +x /etc/init.d/shadowsocks

#config setting and save settings.
echo "#############################################################"
echo "#                                                           #"
echo "#         Please input your shadowsocks configuration       #"
echo "#                                                           #"
echo "#############################################################"
echo ""
echo -n "请输入节点地址: "
read serverip
echo -n "请输入连接端口: "
read serverport
echo -n "请输入连接密码: "
read shadowsockspwd
echo -n "请输入加密方式: "
read method

# Config shadowsocks
cat > /etc/shadowsocks.json<<-EOF
{
  "server":"${serverip}",
  "server_port":${serverport},
  "local_address":"127.0.0.1",
  "local_port":1081,
  "password":"${shadowsockspwd}",
  "timeout":600,
  "method":"${method}"
}
EOF

#config dnsmasq
cp -f ./dnsmasq.d-gfwlist.conf /etc/dnsmasq.d/gfwlist.conf

#config firewall
cp -f /etc/firewall.user /etc/firewall.user.back
sed -i '/ipset -N/d' /etc/firewall.user
sed -i '/iptables -t nat -A PREROUTING -p tcp -m set --match-set/d' /etc/firewall.user
echo "ipset -N gfwlist iphash -! " >> /etc/firewall.user
echo "iptables -t nat -A PREROUTING -p tcp -m set --match-set gfwlist dst -j REDIRECT --to-port 1081" >> /etc/firewall.user

#restart all service
/etc/init.d/dnsmasq restart
/etc/init.d/firewall restart
/etc/init.d/shadowsocks start
/etc/init.d/shadowsocks enable

#install successfully
# rm -rf /tmp/shadowsocks_mini
# rm -f /tmp/shadowsocks_mini.tar.gz
echo ""
echo "Shadowsocks安装成功！"
echo ""
exit 0
