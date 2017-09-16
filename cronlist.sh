#!/bin/bash
cd /var/spool/cron
ls -1 > /root/cronusers.txt
for i in `cat /root/cronusers.txt`
 do
  echo "######For the user $i######" >> /root/cronlist.txt
  echo "" >> /root/cronlist.txt
  cat $i >> /root/cronlist.txt
  echo "" >> /root/cronlist.txt
  echo "###########################" >> /root/cronlist.txt
  echo "" >> /root/cronlist.txt
 done
