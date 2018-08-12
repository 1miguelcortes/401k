#!/bin/bash

echo "xxxx $1"
filename="csv/$1"

#awk -F, '{for (i=1;i<=NF;i++) print $i }' csv/dow30.csv

echo "Start loading yahoo finance daily prices...$filename"

{
	# skip header
	read 
	while IFS=, read -r symbol col2 col3
	do

	    echo "ticker $symbol "
	    ./getyahoopx.sh $symbol
	    
	    # sleep 2;
	done	
} < $filename
