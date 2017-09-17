#!/usr/bin/env bash

echo;echo "Top 10 IPs making requests, displaying the IP address and number of requests made"

cut -d\  -f1 access.log | sort -n | uniq -c | sort -k1 -nr | head -10



echo;echo "Top 10 User agents making the most requests - possibly normalizing those"

cut -d\" -f6 access.log | sort | uniq -c | sort -rn -k1 | head -10



echo;echo "Top 10 requested pages and the number of requests made for each"

cut -d\" -f2 access.log | cut -d\  -f2 | sort | uniq -c | sort -rn -k1 | head -10



echo;echo "Percentage of successful requests"

python -c "print $(cut -d\" -f3 access.log | cut -d\  -f2 | grep -c '200') / $(wc -l access.log | awk '{print $1}').0 * 100"



echo;echo "Percentage of unsuccessful requests"

python -c "print $(cut -d\" -f3 access.log | cut -d\  -f2 | grep -vc '200') / $(wc -l access.log | awk '{print $1}').0 * 100"



echo;echo "Top unsuccessful page requests"

grep -v '1.1" 200 ' access.log | cut -d\" -f2 | cut -d\  -f2 | sort | uniq -c | sort -rn -k1 | head -10



echo;echo "The total number of requests made every minute in the time period covered"

for t in 14:30 14:31; do echo -n "$t: "; grep -c $t access.log ; done



echo;echo "For each of the top 10 IPs, show the top 5 pages requested and the number of requests for each"

cut -d\  -f1 access.log | sort -n | uniq -c | sort -k1 -nr | head -10 | awk '{print $2}' | while read ip; do echo "$ip"; grep $ip access.log | cut -d\" -f2 | cut -d\  -f2 | sort | uniq -c | sort -rn -k1 | head -5; echo; done
