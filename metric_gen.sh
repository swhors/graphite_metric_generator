#!/usr/bin/env bash

ONLY_GEN=2
READ_FILE=2
STEP=60
FILE_NAME=""

FROM_TIME_STR=""
FROM_TIMESTAMP=0
TO_TIME_STR=60

echo "argument count :"$#

function get_start_metric() {
    CUR=`date +%s`
    FROM_TIMESTAMP=$(date +%s -d "$1 $2 ago")
}

if [ $# -gt 2 ];then
    ONLY_GEN=$1
    READ_FILE=$2
    STEP=$3
    if [ $# -gt 3 ];then
        FILE_NAME=$4
    fi
    if [ $# -gt 4  ];then
        FROM_TIME_STR=$5
        TO_TIME_STR=$6
        get_start_metric $5 %6
        echo 'FROM_TIMEATAMP='$FROM_TIMESTAMP
    fi
else
    echo $0 ' ONLY_GEN=1[gen]/0[gen and send] READ_FILE=1[metric from file]/0[random metric] STEP=[0-60] FILE_NAME'
    echo ''
    echo 'example :'
    echo '  '$0' 1 0 60'
    echo '  '$0' 1 1 60 test.metric'
    echo '  '$0' 1 1 60 test.metric "1 days" 30' 
    exit
fi

function send_metric(){
    #echo "ONLY_GEN"$1
    DATE=0 
    if [ $3 -eq 0 ];then
        DATE=`date +%s`
    else
        DATE=$3
    fi
    if [ $1 -eq 1 ];then
        echo "test.bash.stats $2 $DATE" 
    else
        echo "Send metric :"$2","$DATE
        echo "test.bash.stats $2 $DATE" | ncat localhost 2003
    fi
}

if [ $READ_FILE -eq 1 ];then
    FROM=$FROM_TIMESTAMP
    exec < $FILE_NAME
    while read line
    do 
        #echo $line
        if [ $FROM_TIMESTAMP -gt 0 ];then
           FROM=$((FROM + STEP))
        fi
        #echo "FROM="$FROM
        send_metric $ONLY_GEN $line $FROM
        if [ $FROM_TIMESTAMP -eq 0 ];then
            sleep $STEP
        fi
    done
else
    for i in {1..100}
    do
        echo "----Start : $i----"
        send_metric $ONLY_GEN $i
        sleep $STEP
    done
fi
