#!/bin/bash

# this script installs Kerberos server on a CentOS machine

# install packages
yum install -y krb5-libs krb5-server krb5-workstation

# edit configuration files
sed -i -e 's/example.com/yourdomain.com/g' /etc/krb5.conf
sed -i -e 's/EXAMPLE.COM/YOURDOMAIN.COM/g' /etc/krb5.conf
sed -i -e 's/example.com/yourdomain.com/g' /var/kerberos/krb5kdc/kdc.conf
sed -i -e 's/EXAMPLE.COM/YOURDOMAIN.COM/g' /var/kerberos/krb5kdc/kdc.conf

# create Kerberos database
echo -e "<password>\n<password>" | kdb5_util create -s

# edit another configuration file
sed -i -e 's/EXAMPLE.COM/YOURDOMAIN.COM/g' /var/kerberos/krb5kdc/kadm5.acl

# create the administrative user
echo -e "<admin_password>\n<admin_password>" | /usr/sbin/kadmin.local -q "addprinc admin/admin"

# enable and start the server daemons:
/sbin/chkconfig krb5kdc on
/sbin/chkconfig kadmin on
systemctl start krb5kdc
systemctl start kadmin
