#!/bin/bash

PYTHON_SCRIPT='/app/generic.py'

#### ccc ####
function datadogPush() {
	metric="$1"
	value="$2"
	if [[ -z "$3" ]]
	then 
		tags="$3"
	else 
		tags=''
	fi

	python3 "$PYTHON_SCRIPT" "$metric" "$value" "$tags"
	
}

function fourPlayer() {
	output=$(curl -s -H "Chesscom-JesseBot/curl (monitoring;#monitoring_variants)" https://4player.chess.com/ping)
	numGames = $(echo $output | jq '.numGames')
	numUsers = $(echo $output | jq '.numUsers')
	avgMoveLag = $(echo $output | jq '.avgMoveLag')
	avgPing = $(echo $output | jq '.avgPing')

	datadogPush 'fourPlayerChess.activeGames' "$numGames"
	datadogPush 'fourPlayerChess.activeUsers' "$numUsers"
	datadogPush 'fourPlayerChess.avgMoveLag' "$avgMoveLag"
	datadogPush 'fourPlayerChess.avgPing' "$avgPing"

}

fourPlayer



