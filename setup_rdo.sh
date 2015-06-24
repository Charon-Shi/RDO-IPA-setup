#!/bin/bash

IPA=$1

killall
hostname rdo.charlie.com
/etc/init.d/network start

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

sed -i "1s/^/DNS1=\"$IPA\"\n/" /etc/sysconfig/network-scripts/ifcfg-eth0
/etc/init.d/network start
sed -i "s/[0-9.][0-9.]*/$IPA/" /etc/resolv.conf
yum install ipa-client ipa-admintools -y
ipa-client-install --uninstall
ipa-client-install --force-ntpd --force-join 

