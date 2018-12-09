#!/bin/bash

if [ -z $1  ]
then 
    echo "wait parameter error-*-*.log or access-*-*.log, example ./$0 access-4560-c8671a.log"
else
    if [ -f /opt/parse_log/parse.db ]; then
        echo Job is already running\!
        echo $search_file
        exit 6
    fi
fi

touch /opt/parse_log/parse.db
search_file="/opt/parse_log/parse.db"

top_ip () {
    # функция отбирает ip с наибольшим числом запросов из скормленного ей файла и ip адреса
    if [ -z $1 ] && [ -f $2 ]
then
    echo "не передано ни одного значения для функции, ожидаемый формат top_ip \$ip_list \$file"
fi

for ip in $1
do
    i=`grep -c $ip $2`
    array[$i]=$ip
done

n=$((${#array[*]}-10))
count=0

for ind in ${!array[@]};
do
    if [ $count -lt 11 ]
    then
	echo "$ind | ${array[$ind]}"
fi

done
}

if [ -f /opt/parse_log/parse.db ]
then

case $1 in
    error-*-*.log)
    grep -E '[0-9]{2}/[A-Z][a-z][a-z]/[0-9]{4}:`date -d "-1 hours"  +%T`' -A 1000000 $1 > $search_file
    echo "script worked from `date  +%d/%b/%Y:%T` to `date -d "-1 hours"  +%d/%b/%Y:%T`" 

    echo "entries top request client ip errors"
    clnt_ip=`awk -F',' '{  if(match($2, /\i/||/\d/ )) print $2   }' $search_file | awk '{ print $2 }' | sort -u`
	for cl_ip in $clnt_ip
	do
	    echo `top_ip $cl_ip  $search_file`
	done | sort -nrk1 | head -10

    echo "entries top reques server ip errors"
    srv_ip=`awk -F',' '{  if(match($2, /\i/||/\d/ )) print $3   }' $search_file | awk '{ if(match($2, /\i/||/\d/ )) print $2  }' | sort -u`
	for server_ip in $srv_ip
	do
	    echo `top_ip $server_ip  $search_file`
	done | sort -nrk1 | head -10

echo "entries top reques host ip errors"
server1_ip=`awk -F',' '{  if(match($2, /\i/||/\d/ )) print $5 }' $search_file | awk '{ if(!(match($2,/\//))) print $2 }' | sort -u`
    for srv1_ip in $server1_ip
    do
    echo `top_ip $srv1_ip  $search_file`
    done | sort -nrk1 | head -10
;;

access-*-*.log)

echo "script worked from `date  +%d/%b/%Y:%T` to `date -d "-1 hours"  +%d/%b/%Y:%T`"
grep -E '[0-9]{2}/[A-Z][a-z][a-z]/[0-9]{4} `date -d "-1 hours"  +%T`' -A 100000 $1 > $search_file

echo "entries top client ip access"
acc_ip=`awk '{  if(match($1, /\i/||/\d/ )) print $1 }' $search_file | sort -u`
    for access_ip in $acc_ip
    do
	echo `top_ip $access_ip  $search_file`
    done | sort -nrk1 | head -10
;;
esac

else
echo "File /opt/parse_log/parse.db not exist"
fi >>  /opt/parse_log/parse.log

trap 'rm -f "$search_file"; exit $?' INT TERM EXIT
echo "Exit $0""  >> /opt/parse_log/parse.log  2>&1 
if [ -f $search_file ]; then
    rm -f /opt/parse_log/parse.db
fi
trap - INT TERM EXIT




