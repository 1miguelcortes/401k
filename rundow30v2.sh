#!/bin/bash

filename='csv/dow30.csv'

./rundow30.sh

# q loadindexdata2.q -index csv/dow30.csv -p 0W
# to generate csv/dow30dailypx.csv - contains daily YTD prices
q loadindexdata2.q -index csv/dow30.csv -p 0W

# python myplotOne.py to create plot/dow30ytdplot.png and csv/dow30ytdreturn.csv files
python myplotOne.py

# email results as attachment to gfeng22@outlook.com
python sendMail2.py
