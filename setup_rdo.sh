#!/bin/bash

IPA=$1
hostname="rdo.charlie.com"

hostname $hostname
sed -i "s/[a-z.][a-z.]*/$hostname/" /etc/hostname
/etc/init.d/network start

sed -i "1s/^/DNS1=\"$IPA\"\n/" /etc/sysconfig/network-scripts/ifcfg-eth0
/etc/init.d/network start
sed -i "s/[0-9.][0-9.]*/$IPA/" /etc/resolv.conf
yum install -y ipa-client ipa-admintools 
#ipa-client-install --uninstall
ipa-client-install --force-ntpd --force-join 

systemctl stop NetworkManager
systemctl disable NetworkManager
systemctl enable network
systemctl start network

yum update -y
service sshd start
yum install -y https://rdoproject.org/repos/rdo-release.rpm
yum install -y openstack-packstack
/usr/bin/rpm -e --nodeps mariadb-server-5.5.41-2.el7_0.x86_64
packstack --allinone



