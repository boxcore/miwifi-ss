#!/bin/sh

clear
echo "#############################################################"
echo "#             Install Shadowsocks for Miwifi                #"
echo "#############################################################"

cd /userdisk/data/
# rm -f shadowsocks_miwifi.tar.gz
# wget -c http://okss.tk/xiaomi/r2d/shadowsocks_miwifi.tar.gz
tar zxf shadowsocks_miwifi.tar.gz

# Config shadowsocks init script
cp ./shadowsocks_miwifi/myshadowsocks /etc/init.d/myshadowsocks
chmod +x /etc/init.d/myshadowsocks

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
mkdir -p /etc/dnsmasq.d
cp -f ./shadowsocks_miwifi/dnsmasq_list.conf /etc/dnsmasq.d/dnsmasq_list.conf

#config firewall
cp -f /etc/firewall.user /etc/firewall.user.back
sed -i '/ipset -N/d' /etc/firewall.user
sed -i '/iptables -t nat -A PREROUTING -p tcp -m set --match-set/d' /etc/firewall.user
echo "ipset -N gfwlist iphash -! " >> /etc/firewall.user
echo "iptables -t nat -A PREROUTING -p tcp -m set --match-set gfwlist dst -j REDIRECT --to-port 1081" >> /etc/firewall.user

#restart all service
/etc/init.d/dnsmasq restart
/etc/init.d/firewall restart
/etc/init.d/myshadowsocks start
/etc/init.d/myshadowsocks enable

#install successfully
# rm -rf /userdisk/data/shadowsocks_miwifi
# rm -f /userdisk/data/shadowsocks_miwifi.tar.gz
echo ""
echo "Shadowsocks安装成功！"
echo ""
exit 0
