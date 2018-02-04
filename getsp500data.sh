#!/bin/bash

filename='sp500.txt'
filelines=`cat $filename`

echo "Start loading yahoo finance daily prices..."

for line in $filelines ; do
    echo "processing $line ...";
    ./getyahoopx.sh $line;
    #sleep 2;
done

