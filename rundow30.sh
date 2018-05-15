#!/bin/bash

filename='csv/dow30.csv'

echo "Start loading yahoo finance daily prices...$filename"

{
	# skip header
	read 
	while IFS=, read -r company exchange symbol industry dateadded notes
	do	
	    echo "ticker $symbol "
	    ./getyahoopx.sh $symbol
	    
	    # sleep 2;
	done	
} < $filename
