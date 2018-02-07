#!/bin/bash

filename='sp500.txt'

echo "Start loading yahoo finance daily prices...$filename"

{
	# skip header
	read 
	while IFS=, read -r symbol desc
	do	
	    echo "ticker $symbol "
	    ./getyahoopx.sh $symbol

	    #sleep 2;
	done	
} < $filename

