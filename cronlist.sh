#!/bin/bash
#this script lists all of the cronjobs on a machine
cd /var/spool/cron
ls -l > /root/cronusers.txt
for i in `cat /root/cronusers.txt`
 do
  echo "######For the user $i######" >> /root/cronlist.txt
  echo "" >> /root/cronlist.txt
  cat $i >> /root/cronlist.txt
  echo "" >> /root/cronlist.txt
  echo "###########################" >> /root/cronlist.txt
  echo "" >> /root/cronlist.txt
 done
