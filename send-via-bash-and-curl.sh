#!/bin/bash


#### description: send custom metrics values to datadog
#### AUTHOR: Jesse
#### Date: Feb 2, 2021

source /root/ENV
#### VARIABLES ####
LOG_DIR="/var/log"
LOG_FILENAME="ca-load.log"
LOG="${LOG_DIR}/${LOG_FILENAME}"
DATA_FILE="$LOG"
METRIC2='ca.system.cores'
VALUE2=1200

host=()
one=()
five=()
fifteen=()

#### loop over each host and put each load values into an array ####
for i in list my hosts; 
do 
    OUTPUT=$(/usr/local/libexec/nagios/check_nrpe3 -c check_load -H "${i}.int.chess.com"|sed 's/.*load average: //' | sed 's/|.*//' | sed 's/ //g')
    onemin=$(echo "$OUTPUT" | cut -f1 -d",")
    fivemin=$(echo "$OUTPUT" | cut -f2 -d",")
    fifteenmin=$(echo "$OUTPUT" | cut -f3 -d",")
    #    echo "$i === $onemin $fivemin $fifeteenmin"
    host=(${host[@]} $i)
    one=(${one[@]} $onemin)
    five=(${five[@]} $fivemin)
    fifteen=(${fifteen[@]} $fifteenmin)

done 

minusone=$((${#fifteen[@]} -1 ))
#### EXAMPLE FORMAT ####
        #{\"metric\":\"xxx.live.threadPool\",
        #\"points\":[[$CURRENTTIME, 48]],
        #\"host\":\"akiba.chess.com\",
        #\"tags\":[\"xxx.live.threadPool:GC\"]}


#### POST to datadog ####

CURRENTTIME=$(date +%s)

#### loop over each element in the array, i.e. once per host ####
for b in $(seq 0 $(echo $minusone));
do
    HOST="${host[$b]}"
    # METRIC == 1m, 5m, 15m
    tag='product:ca'

        #### append current row to NEW_METRIC_ITEMS ####
        NEW_METRIC="\"metric\": \"ca.system.load1m\"" 
        VALUE="${one[$b]}"
#       echo "${host[$b]} ${one[$b]} ${five[$b]} ${fifteen[$b]}"
         NEW_METRIC_ITEMS+="{$NEW_METRIC, \"points\":[[$CURRENTTIME, $VALUE]], \"tags\": [\"$tag\"], \"host\":\"$HOST\"},"

        #### append current row to NEW_METRIC_ITEMS ####
        NEW_METRIC="\"metric\": \"ca.system.load5m\"" 
        VALUE="${five[$b]}"
         NEW_METRIC_ITEMS+="{$NEW_METRIC, \"points\":[[$CURRENTTIME, $VALUE]], \"tags\": [\"$tag\"], \"host\":\"$HOST\"},"

        #### append current row to NEW_METRIC_ITEMS ####
        NEW_METRIC="\"metric\": \"ca.system.load15m\"" 
        VALUE="${fifteen[$b]}"
         NEW_METRIC_ITEMS+="{$NEW_METRIC, \"points\":[[$CURRENTTIME, $VALUE]], \"tags\": [\"$tag\"], \"host\":\"$HOST\"},"

done
NEW_METRIC_ITEMS="${NEW_METRIC_ITEMS%,}"
#echo "$NEW_METRIC_ITEMS"
#### POST to datadog ####
timeout 5 $(whereis curl | awk '{print $2}') -s -X POST -H "Content-type: application/json" -d \
     "{\"series\":[
              {\"metric\":\"$METRIC2\",
          \"points\":[[$CURRENTTIME, $VALUE2]],
          \"type\":\"gauge\",
          \"host\":\"$HOSTNAME\",
          \"tags\":[\"product:ca\"]},
    $NEW_METRIC_ITEMS]}" "https://api.datadoghq.com/api/v1/series?api_key=${DATADOG_API}"

exit


timeout 5 /usr/local/bin/curl -s -X POST -H "Content-type: application/json" \
-d "{ \"series\" :
         [
          {\"metric\":\"$METRIC2\",
          \"points\":[[$currenttime, $VALUE2]],
          \"type\":\"gauge\",
          \"host\":\"$HOSTNAME\",
          \"tags\":[\"product:ca\"]},

          {\"metric\":\"$METRIC\",
          \"points\":[[$currenttime, $VALUE]],
          \"type\":\"gauge\",
          \"host\":\"$HOSTNAME\",
          \"tags\":[\"product:ca\"]}
        ]
}" \
"https://api.datadoghq.com/api/v1/series?api_key=${DATADOG_API}"
