#!/bin/bash

TEMP=/tmp/counter.tmp
if [ ! -f /tmp/counter.tmp ]
then
 echo 0 > $TEMP
fi

ps auxw | grep apache2 | grep -v grep > /dev/null
if [ $? != 0 ]
then
 echo "Apache was not running"
 systemctl start apache2
 COUNTER=$[$(cat $TEMP) + 1]
 echo $COUNTER > $TEMP
fi

netstat -ln | grep -E ':80' >> server.log
if [ $? != 0 ]
then
 echo "Port 80 was closed"
 systemctl restart apache2
 COUNTER=$[$(cat $TEMP) + 1]
 echo $COUNTER > $TEMP
fi

status=$(curl -s --head -w %{http_code} http://www.mywebsite.ro/ -o /dev/null)
if [ $status != 200 ]
then
 echo "Website down, restarting Apache"
 systemctl restart apache2 
 COUNTER=$[$(cat $TEMP) + 1]
 echo $COUNTER > $TEMP
fi

wget "www.mywebsite.ro" --timeout 30 -O - 2>/dev/null  | grep "test_pattern" > /dev/null
if [ $? != 0 ]
then
 echo "Test word not found, restarting Apache"
 systemctl restart apache2 
 COUNTER=$[$(cat $TEMP) + 1]
 echo $COUNTER > $TEMP
fi

if [[ $COUNTER -ge 5 ]]
then
 echo "Too many errors, sending an email"
 mail -s 'we have a major problem' me@myemail.dom
 unlink $TEMP
fi



# eu nu ma pricep la bash dar stiu ceva python si am incercat sa aplic aceleasi principii
# scriptul verifica fiecare conditie una dupa alta si reporneste Apache daca are o problema
# pentru counterul de erori, am folosit un fisier extern 
# nu stiu daca functioneaza corect dar altfel s-ar fi resetat de fiecare data cand rula scriptul
# la inceput, se verifica existenta fisierului temporar
# pentru a evita stergerea valorii de acolo

#ca sa ruleze la fiecare 2 minute intre 8 si 5, se poate folosi crontab
#pentru a seta un daily job
#*/2 8-17 * * * /path/apache.sh
#mi se pare mai elegant sa setezi cron din afara scriptului
#se putea include si in script, dar ar fi rulat linia respectiva de fiecare data

