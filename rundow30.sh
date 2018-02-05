#!/bin/bash

filename='dow30.csv'
filelines=`cat $filename`

echo "Start loading yahoo finance daily prices..."

for line in $filelines ; do
    echo "processing $line ...";
    ticker=$
    # ./getyahoopx.sh $line;
    #sleep 2;
done

