\l log.q
\l utils.q

indexfile:frmt_handle get_param`indexfile;
show indexfile;


/ read index tickers
tickers:("SS";enlist ",")0: indexfile;
syms:exec Symbol from tickers;

loaddata:{[ndays;stocks] 
 tbl:(); / initialize results table
 i:0;
 do[count stocks; /iterate over all the stocks
     stock:stocks[i];
     .log.inf "loading sym: ",string stock;
 
    txt:"data/",(string stock),".csv";
	stocktable: ("DEEEEEJ";enlist",")0: hsym `$txt; / parse the string and create a table from it
    stocktable: update Sym:stock from stocktable; / add a column with name of stock
    tbl,: stocktable; / append the table for this stock to tbl
    i+:1
  ];

 tbl: select from tbl where not null Volume; / get rid of rows with nulls
 `Date`Sym xasc tbl  / order by date and stock
 } 


/ get years range - 1 yr, 5 yr, 10 yr
d:.z.D; / "D"$"." sv (string d.year;"01";"01")
yr0:"D"$"." sv (string d.year;"01";"01");
yr1:"D"$"." sv (string d.year-1;"01";"01");
yr3:"D"$"." sv (string d.year-3;"01";"01");
yr5:"D"$"." sv (string d.year-5;"01";"01");
yr10:"D"$"." sv (string d.year-10;"01";"01");

/ load all S&P data
spdaily:loaddata[0;syms];

update AdjClose:spdaily`$"Adj Close" from `spdaily;
update retdaily:log(AdjClose%prev AdjClose) from `spdaily;
indexlast:select by Sym from spdaily;


indexytd:select yr0days:count i, yr0adv:floor avg Volume, yr0start:first Date, yr0end:max Date, retytd:log(last AdjClose%first AdjClose) by Sym from spdaily where Date>=yr0;
index1yr:select yr1days:count i, yr1adv:floor avg Volume, yr1start:first Date, yr1end:last Date, ret1yr:0.2*log(last AdjClose%first AdjClose) by Sym from spdaily where Date within (yr1;yr0);
index5yr:select yr5days:count i, yr5adv:floor avg Volume, yr5start:first Date, yr5end:last Date, ret5yr:0.2*log(last AdjClose%first AdjClose) by Sym from spdaily where Date within (yr5;yr0);
index10yr:select yr10days:count i, yr10adv:floor avg Volume, yr10start:first Date, ytd10end:last Date, ret10yr:0.1*log(last AdjClose%first AdjClose) by Sym from spdaily where Date within (yr10;yr0);

indexall:indexytd lj `Sym xkey index1yr lj `Sym xkey index5yr lj `Sym xkey index10yr;
indexstats:select Date, Sym, Close, AdjClose, Volume, retdaily, retytd, ret5yr, ret10yr, yr5start, yr10start from (indexlast lj `Sym xkey indexall);
/ indexstats

/ select from indexstats where Sym=`SPY


\c 50 1000
