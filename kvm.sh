#!/bin/bash
#This script only suitable for CentOS 7 
#This script is written for installing KVM on CentOS 7 enabled bridge
#UPDATE DATE 2016-10-10
#Only Enabled IPv4.If you need Enable IPv6 Please do it yourself
yum makecache
yum update -y
yum -y install qemu-kvm libvirt virt-install bridge-utils

sed -i 's/#user = "root"/user = "root"/g' /etc/libvirt/qemu.conf
sed -i 's/#group = "root"/group = "root"/g' /etc/libvirt/qemu.conf
sed -i 's/#dynamic_ownership = 1/dynamic_ownership = 0/g' /etc/libvirt/qemu.conf
systemctl restart libvirtd
systemctl enable libvirtd
networkPath=/etc/sysconfig/network-scripts/
enName=$(ls /etc/sysconfig/network-scripts/|grep ifcfg-en)
bridgeName=ifcfg-br0
# cp -a $networkPath$enName $networkPath$bridgeName
theConfEnName=$(cat $networkPath$enName|grep NAME)
echo $theConfEnName
ipaddr=$(cat $networkPath$enName|grep IPADDR|awk -F'=' '{print $2}')
prefix=$(cat $networkPath$enName|grep PREFIX|awk -F'=' '{print $2}')
gateway=$(cat $networkPath$enName|grep GATEWAY|awk -F'=' '{print $2}')
dns1=$(cat $networkPath$enName|grep DNS1|awk -F'=' '{print $2}')

# sed -i 's/TYPE=Ethernet/TYPE=Bridge/g' /etc/sysconfig/network-scripts/ifcfg-br0
# sed -i "s/${theConfEnName}/NAME=br0/g" /etc/sysconfig/network-scripts/ifcfg-br0
sed -i '/^IPADDR0*/d' $networkPath$enName
sed -i '/^PREFIX*/d' $networkPath$enName
sed -i '/^GATEWAY0*/d' $networkPath$enName
sed -i '/^DNS*/d' $networkPath$enName
sed -i '/^NAME/a\BRIDGE=br0' $networkPath$enName
sed -i '/^IPV6*/d' $networkPath$enName

cat >$networkPath$bridgeName<<EOF
DEVICE=br0
TYPE=Bridge
BOOTPROTO=none
NAME=br0
ONBOOT=yes
IPADDR=$(echo $ipaddr)
GATEWAY=$(echo $gateway)
PREFIX=$(echo $prefix)
DNS1=$(echo $dns1)
EOF
yum install -y net-tools
systemctl restart network
iptables -F
service iptables save

