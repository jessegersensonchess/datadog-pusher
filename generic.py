'''
INPUT:
json string data from "curl -s https://4player.chess.com/ping"

OUTPUT:
int for datadog

DESCRIPTION:
send metric collection to datadog

AUTHOR: 
Jesse Gersenson

'''

import os, sys
from datadog import initialize, api

api_key=os.environ['DATADOG_API']
app_key=os.environ['DATADOG_APP']

options = {
    "api_key": api_key,
    "app_key": app_key,
}

initialize(**options)


metric_name=sys.argv[1]
datapoint=sys.argv[2]
tags = [sys.argv[3]]

host='33bbcc'
type='count'
interval=20
api.Metric.send(
            metric=metric_name,
            points=datapoint,
            host=host,
            tags=tags,
            type=type,
            interval=interval)





