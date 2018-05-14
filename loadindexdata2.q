\l log.q
\l utils.q

indexfile:frmt_handle get_param`index;
show indexfile;

sp500:xcol[`Symbol`Name`SEC`Sector`Industry`Address`DateFirstAdd`CIK;("SSSSSSDI";enlist ",")0: `:csv/sp500.csv];
sp500:update Symbol:{`$ssr[string x;".";"-"]} each Symbol from sp500;
spstate:select count i, distinct Symbol by State from (update State:{`$last "," vs string x} each Address from sp500);
/ t:xcol[`$ssr[;" ";""]each string cols t;t];

/ read index tickers
tickers:?[indexfile like "*dow30*";("SSSSDS";enlist ",")0: indexfile;sp500];
tickers:?[indexfile like "*401k*";("SSSSDS";enlist ",")0: indexfile;tickers];
tickers:?[indexfile like "*etf*";("SSSSDS";enlist ",")0: indexfile;tickers];
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
indexdaily:loaddata[0;syms];
update AdjClose:indexdaily`$"Adj Close" from `indexdaily;


/ short-term return: same day 0d, 1d, 1w, 1m, 6m
indexdailyret:raze {
 msg:"" sv ("xxxx compute ";string y;" day return for `";string x);
 .log.info msg;
 data:update ret0doc:log(Close%Open), ret0dhl:log(High%Low), ret1d:log(AdjClose%prev AdjClose) from select from `indexdaily where Sym=x;
 data
 }[;1] each syms;

indexlast:select by Sym from `indexdailyret;


index5d:raze {
 msg:"" sv ("xxxx compute ";string y;" day return for `";string x);
 .log.info msg;
 / get each of 5th day from current date
 data:select days:count i, AdjClosePrices:AdjClose, dailyret:ret1d, last Date, last AdjClose, dailyHL5days:ret0dhl by Sym, ret5d:5 xbar i from (-360#select from `indexdailyret where Sym=x);
 / data:update ret5d:{ log((last x)%(first x)) } each AdjClosePrices from data;
 data:update vol5d:stdev5d*sqrt(252), vol5dhl:dailyHLstdev5days*sqrt(252) from update ret5d:log(AdjClose%prev AdjClose), stdev5d:{dev x} each dailyret, dailyHLstdev5days:{sqrt((1.0%(4*5*log(2)))*(sum(x*x)))} each dailyHL5days from data;
 0!-1#data 
 }[;5] each syms;


index30d:raze {
 msg:"" sv ("xxxx compute ";string y;" day return for `";string x);
 .log.info msg;
 data:select days:count i, AdjClosePrices:AdjClose, dailyret:ret1d, last Date, last AdjClose, dailyHL30days:ret0dhl by Sym, ret30d:30 xbar i from (-360#select from `indexdailyret where Sym=x);
 data:update vol30d:stdev30d*sqrt(252), vol30dhl:dailyHLstdev30days*sqrt(252) from update ret30d:log(AdjClose%prev AdjClose), stdev30d:{dev x} each dailyret, dailyHLstdev30days:{sqrt((1.0%(4*30*log(2)))*(sum(x*x)))} each dailyHL30days from data;
 0!(-1#data) / just output the latest date
 }[;30] each syms;


indexytd:select retytd:log(last AdjClose%first AdjClose), ytddays:count i, ytdadv:floor avg Volume, ytdstart:first Date, ytdend:max Date by Sym from indexdailyret where Date>=yr0;
index1yr:select ret1yr:0.2*log(last AdjClose%first AdjClose), yr1days:count i, yr1adv:floor avg Volume, yr1start:first Date, yr1end:last Date by Sym from indexdailyret where Date within (yr1;yr0);
index5yr:select ret5yr:0.2*log(last AdjClose%first AdjClose), yr5days:count i, yr5adv:floor avg Volume, yr5start:first Date, yr5end:last Date by Sym from indexdailyret where Date within (yr5;yr0);
index10yr:select ret10yr:0.1*log(last AdjClose%first AdjClose), yr10days:count i, yr10adv:floor avg Volume, yr10start:first Date, ytd10end:last Date by Sym from indexdailyret where Date within (yr10;yr0);

indexretall:indexlast lj `Sym xkey index5d lj `Sym xkey index30d lj `Sym xkey indexytd lj `Sym xkey index1yr lj `Sym xkey index5yr lj `Sym xkey index10yr;
indexstats:select Date, Sym, Open, High, Low, Close, AdjClose, Volume, ret0doc, ret0dhl, ret1d, ret5d, ret30d, vol5d, vol5dhl, vol30d, vol30dhl, retytd, ret1yr, ret5yr, ret10yr, yr10start from indexretall;
`:csv/dow30indexstats.csv 0: "," 0: indexstats;
show "csv/dow30indexstats.csv output data files generated";

dow30dailypx:`Date`Sym`AdjClose#select from indexdaily where Date>=yr0;
`:csv/dow30dailypx.csv 0: "," 0: dow30dailypx;
show "csv/dow30dailypx.csv output data files generated";

\\



