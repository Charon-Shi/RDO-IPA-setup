#!/bin/bash

IPA=$1

hostname rdo.charlie.com
/etc/init.d/network start

systemctl stop NetworkManager
systemctl disable NetworkManager
systemctl enable network
systemctl start network

sed -i "1s/^/DNS1=\"$IPA\"\n/" /etc/sysconfig/network-scripts/ifcfg-eth0
/etc/init.d/network start
sed -i "s/[0-9.][0-9.]*/$IPA/" /etc/resolv.conf

yum update -y
yum install -y https://rdoproject.org/repos/rdo-release.rpm
yum install -y openstack-packstack
packstack --allinone
