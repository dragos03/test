#!/bin/bash

#this script install Kerberos on either CentOS or Ubuntu

#set up file locations
RED=/etc/redhat-release
UBU=/etc/issue

#check if the server is running CentOS and the version
if [ -e "$RED" ]; then
  TX=`cat $RED`
  if [[ ${TX:21:1} -eq "6" || ${TX:21:1} -eq "7" ]]; then
    OS=new
  else
    OS=old
  fi
fi

#check if the server is running Ubuntu and the version
if [ -e "$UBU" ]; then
  VS=`cat $UBU`
  if [[ ${VS:8:2} -gt "15" ]]; then
    OS=new
  else
    OS=old
  fi
fi

#install packages on CentOS
if [ -e "$RED" ]; then
  yum install -y krb5-libs krb5-server krb5-workstation
fi

#install packages on Ubuntu
if [ -e "$UBU" ]; then
  apt-get install -y krb5-libs krb5-server krb5-workstation
fi

#enter domain name and password
read -p "Please enter your domain: " DOMAIN

PASS="a"
PASS2="b"

until [ $PASS == $PASS2 ]; do
  read -sp "Please enter your password: " PASS
  echo
  read -sp "Please confirm your password: " PASS2
  if [ $PASS != $PASS2 ]; then
    printf "\nPasswords don't match, try again\n"
  fi
done

DOMAINU=`echo $DOMAIN | tr [a-z] [A-Z]`

# edit configuration files
sed -i -e 's/example.com/$DOMAIN/g' /etc/krb5.conf
sed -i -e 's/EXAMPLE.COM/$DOMAINU/g' /etc/krb5.conf
sed -i -e 's/example.com/$DOMAIN/g' /var/kerberos/krb5kdc/kdc.conf
sed -i -e 's/EXAMPLE.COM/$DOMAINU/g' /var/kerberos/krb5kdc/kdc.conf

# create Kerberos database
echo -e "$PASS\n$PASS" | kdb5_util create -s

# edit another configuration file
sed -i -e 's/EXAMPLE.COM/$DOMAINU/g' /var/kerberos/krb5kdc/kadm5.acl

# create the administrative user
echo -e "$PASS\n$PASS" | /usr/sbin/kadmin.local -q "addprinc admin/admin"

#start and enable the services on system with or without SystemD
if [[ $OS == "new" ]]; then
  /sbin/chkconfig krb5kdc on
  /sbin/chkconfig kadmin on
  systemctl start krb5kdc
  systemctl start kadmin
else
  /sbin/chkconfig krb5kdc on
  /sbin/chkconfig kadmin on
  service krb5kdc start
  service kadmin start
fi
