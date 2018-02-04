\l log.q

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

/ read sp500 tickers
tickers:("SS";enlist " ")0: `$":sp500.txt";
syms:`SPY`QQQ,exec SPY from tickers;  / add `SPY`QQQ to the list

spdaily:loaddata[0;syms];
update AdjClose:spdaily`$"Adj Close" from `spdaily;
update retdaily:log(AdjClose%prev AdjClose) from `spdaily;

d:.z.D; / "D"$"." sv (string d.year;"01";"01")
yr0:"D"$"." sv (string d.year;"01";"01");
yr1:"D"$"." sv (string d.year-1;"01";"01");
yr3:"D"$"." sv (string d.year-3;"01";"01");
yr5:"D"$"." sv (string d.year-5;"01";"01");
yr10:"D"$"." sv (string d.year-10;"01";"01");


spytd:select count i, avg Volume, ytd0:first Date, ytdn:last Date, YTD:log(last AdjClose%first AdjClose) by Sym from spdaily where Date>=yr0;
sp1yr:select count i, avg Volume, yr1:first Date, yr1n:last Date, YR1:log(last AdjClose%first AdjClose) by Sym from spdaily where Date within (yr1;yr0);
sp5yr:select count i, avg Volume, yr5:first Date, yr5n:last Date, YR5:log(last AdjClose%first AdjClose) by Sym from spdaily where Date within (yr5;yr0);
sp10yr:select count i, avg Volume, yr10:first Date, ytdn:last Date, YR10:log(last AdjClose%first AdjClose) by Sym from spdaily where Date within (yr10;yr0);

spstats:spytd lj `Sym xkey sp1yr lj `Sym xkey sp5yr lj `Sym xkey sp10yr;

