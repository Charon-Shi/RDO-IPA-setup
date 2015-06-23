#!/bin/bash
# must run under sudo
# must have ipa-client running

hostname=$1
IPA=$2
REALM=$3

hostname $1
/etc/init.d/network start

#uninstall mariadb and ipa-client
yum remove -y mariadb-server mariadb-libs mariadb
kinit admin

yum install ipa-admintools
echo "ipa-admintools installed..."

cd /etc/yum.repos.d/
wget https://copr.fedoraproject.org/coprs/rharwood/mariadb/repo/epel-7/rharwood-mariadb-epel-7.repo
echo "mariadb downloaded..."

yum install -y epel-release
echo "epel-release installed..."

yum update -y
echo "info updated..."

yum install -y  mariadb{,-debuginfo,-devel,-libs,-server}
echo "mariadb installed..."

ipa service-add MySQL/$(hostname -f)
echo "service added..."

cd /var/lib/mysql
ipa-getkeytab -s $IPA -p MySQL/$(hostname -f)@$REALM -k mysql.keytab
chown mysql:mysql mysql.keytab
chmod 660 /var/lib/mysql/mysql.keytab
echo "fetch keytab"

service mariadb start
mysql -u root << EOF
install plugin kerberos soname 'kerberos';
EOF

service mariadb stop
cd /etc/my.cnf.d/
sed -i "/\[server\]/a kerberos_principal_name=MySQL\/$IPA@$REALM\nkerberos_keytab_path=/var/lib/mysql/mysql.keytab"  server.cnf

service mariadb start
mysql -u root << EOF
select @@kerberos_principal_name;
select @@kerberos_keytab_path;
CREATE USER test_kerberos IDENTIFIED VIA kerberos AS 'admin@CHARLIE.COM';
EOF
