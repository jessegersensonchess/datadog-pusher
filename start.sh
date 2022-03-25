#!/bin/bash
while sleep 60; 
do 
	echo "DEBUGGING info $(date -u) $0"
	timeout 10 /app/generic.sh
done

