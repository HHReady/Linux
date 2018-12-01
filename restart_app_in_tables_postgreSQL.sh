#!/bin/bash

if [ -z $1 ]
then
echo "please, set PU name for restart. Example: ./restart app "
fi

USER=postgres
SU="runuser - $USER -c"
APP_NAME=$1

pus_set() {
    local disabled="$*"
    [ $(whoami) == root ] &&  $SU "psql -d prod --command=\"update  shema.table set $disabled where name like '$APP_NAME'\""
}

status() {
    echo `find /opt -name app.log  -exec tail -n 1 {} \; -printf %h | grep $APP_NAME -s -T`
}

#echo "step 1: disabled pu $APP_NAME"
pus_set disabled=1
sleep 5
status
#echo "step 2: enabled pu $APP_NAME"
pus_set disabled = null
sleep 5
status
