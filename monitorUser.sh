#!/bin/bash

# If a user reaches the fd or thread limit and you cannot log into the machine with that user
# login with another (maybe root but not usually allowed) and use this script to find out
# whats going on. 
# TODO: monitor resident and virtual memory, maybe also shared memory

if [ $# -ne 1 ]
  then
    echo "Unix user name must be provided as argument. Usage: $0 <user name>"
    exit -1
fi

USER=$1
echo $USER

while true
do
     TOTAL_THREAD=0
     TOTAL_FD=0
     for i in `ps -fu ${USER} | awk '{print $2}'`
     do
        PID=$i
        FILE="/proc/$PID/status"

        if [ -f $FILE ]; then
            NTHREADS=`cat /proc/$i/status | grep "Threads:" | awk '{print $2}'`
            PROCESS_NAME=`cat /proc/$i/status | grep "Name:" | awk '{print $2}'`
            NUM_FDS=`ls /proc/$i/fd/ 2>/dev/null| wc -l `
            echo PID $i NAME $PROCESS_NAME THREADS $NTHREADS NFDS $NUM_FDS
            TOTAL_THREAD=`expr $TOTAL_THREAD + $NTHREADS`
            TOTAL_FD=`expr $TOTAL_FD + $NUM_FDS`
        fi
     done
     echo "totals threads $TOTAL_THREAD fds $TOTAL_FD"
     echo "---------------------------------"
     sleep 2;
done
