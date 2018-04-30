\l log.q
\l utils.q

/ t:("SSSSSSDI";enlist ",")0: `:csv/sp500wiki.csv

indexfile:frmt_handle get_param`index;
show indexfile;


/ read index tickers
tickers:("SS";enlist ",")0: indexfile;
syms:exec Symbol from tickers where not Name like "Index*";

loadstatsfiles:{[ndays;stocks] 
 tbl:(); / initialize results table
 i:0;
 do[count stocks; /iterate over all the stocks
     stock:stocks[i];
     .log.inf "loading stats for sym: ",string stock;
    
    statsfile:"" sv (":stats/";string stock;".json");
    txt:.j.k raze read0 `$statsfile;

    statstable: enlist (raze (first (raze value txt)));
    if [type statstable = 98h;
      statstable: update Date:.z.D, Sym:stock from statstable;
      tbl,: statstable; / append the table for this stock to tbl
    ];

    i+:1
  ];

 `Date`Sym xasc tbl  / order by date and stock
 } 


/ load all S&P data
/ syms:`GE`IBM`AAPL`GS;
statsraw:loadstatsfiles[0;syms];

/
# ge:.j.k read1 `:stats/GE.json
# .j.k raze read0`:stats/GE.json
# {show x} each  (raze (first (raze value ge)))
#
"""
d:(raze (first (raze value ge)))
d`defaultKeyStatistics
d`summaryProfile  --> enlist d`summaryData makes a table
d`financialData
"""
raze {update Sym:x`Sym from enlist (value x`summaryProfile)} each statsraw
\

/ now process each of the stats table: {defaultKeyStatistics, summaryProfile, financialData}
defaultKeyStatistics:raze {update Sym:x`Sym from enlist (x`defaultKeyStatistics)} each statsraw;
/ summaryProfile:raze { delete address2,fax,fullTimeEmployees from (update Sym:x`Sym from enlist x`summaryProfile) } each statsraw;
summaryProfile:raze { delete zip, state, address2, fax, fullTimeEmployees, longBusinessSummary, companyOfficers from (update Sym:x`Sym from enlist x`summaryProfile) } each statsraw;
financialData:raze {update Sym:x`Sym from enlist (x`financialData)} each statsraw;

/ parse out details 
statsAll:defaultKeyStatistics lj `Sym xkey financialData;

/ `Sym`marketCap`enterpriseValue1 xcols `marketCap xdesc update marketCap:sharesOutstanding1*crrentPrice1 from update enterpriseValue1:{x`raw} each enterpriseValue, sharesOutstanding1:{`float$x`raw} each sharesOutstanding, crrentPrice1:{`float$x`raw} each currentPrice from statsAll;

statsAll2:update marketCap:floor sharesOutstanding2*currentPrice2 from 
	(update enterpriseValue2:{`float$x`raw} each enterpriseValue
	, forwardPE2:{`float$x`raw} each forwardPE
	, profitMargins2:{`float$x`raw} each profitMargins
	, floatShares2:{`float$x`raw} each floatShares
	, sharesOutstanding2:{`float$x`raw} each sharesOutstanding
	, sharesShort2:{`float$x`raw} each sharesShort
	, sharesShortPriorMonth2:{`float$x`raw} each sharesShortPriorMonth
	, heldPercentInsiders2:{`float$x`raw} each heldPercentInsiders
	, heldPercentInstitutions2:{`float$x`raw} each heldPercentInstitutions
	, shortRatio2:{`float$x`raw} each shortRatio
	, shortPercentOfFloat2:{`float$x`raw} each shortPercentOfFloat
	, beta2:{`float$x`raw} each beta
	, bookValue2:{`float$x`raw} each bookValue
	, priceToBook2:{`float$x`raw} each priceToBook
	, earningsQuarterlyGrowth2:{`float$x`raw} each earningsQuarterlyGrowth
	, netIncomeToCommon2:{`float$x`raw} each netIncomeToCommon
	, trailingEps2:{`float$x`raw} each trailingEps
	, forwardEps2:{`float$x`raw} each forwardEps
	, pegRatio2:{`float$x`raw} each pegRatio
	, lastSplitDate2:{x`fmt} each lastSplitDate
	, enterpriseToRevenue2:{`float$x`raw} each enterpriseToRevenue
	, enterpriseToEbitda2:{`float$x`raw} each enterpriseToEbitda
	, Weeks52Change2:{`float$x`raw} each statsAll`52WeekChange
	, SandP52WeekChange2:{`float$x`raw} each SandP52WeekChange

	, currentPrice2:{`float$x`raw} each currentPrice 
	, targetHightPrice2:{`float$x`raw} each targetHighPrice
	, targetLowPrice2:{`float$x`raw} each targetLowPrice
	, targetMeanPrice2:{`float$x`raw} each targetMeanPrice
	, targetMedianPrice2:{`float$x`raw} each targetMedianPrice
	, recommendationKey2:`$recommendationKey
	, numberOfAnalystOpinions2:{`int$x`raw} each numberOfAnalystOpinions
	, totalCash2:{`float$x`raw} each totalCash
	, totalCashPerShare2:{`float$x`raw} each totalCashPerShare
	, ebitda2:{`float$x`raw} each ebitda
	, totalDebt2:{`float$x`raw} each totalDebt
	, quickRatio2:{`float$x`raw} each quickRatio
	, currentRatio2:{`float$x`raw} each currentRatio
	, totalRevenue2:{`float$x`raw} each totalRevenue
	, debtToEquity2:{`float$x`raw} each debtToEquity
	, revenuePerShare2:{`float$x`raw} each revenuePerShare
	, returnOnAssets2:{`float$x`raw} each returnOnAssets
	, returnOnEquity2:{`float$x`raw} each returnOnEquity
	, grossProfits2:{`float$x`raw} each grossProfits
	, freeCashflow2:{`float$x`raw} each freeCashflow
	, operatingCashflow2:{`float$x`raw} each operatingCashflow
	, earningsGrowth2:{`float$x`raw} each earningsGrowth
	, revenueGrowth2:{`float$x`raw} each revenueGrowth
	, grossMargins2:{`float$x`raw} each grossMargins
	, ebitdaMargins2:{`float$x`raw} each ebitdaMargins
	, operatingMargins2:{`float$x`raw} each operatingMargins from statsAll);

tcols:();
{if [x like "*2";tcols::tcols,`$x] }each string cols statsAll2;

statsAllOut:(`Sym`marketCap,tcols)#statsAll2;

/ model 1: 
potentialReturn:`potentialReturn xdesc `Sym`marketCap`potentialReturn`currentPrice2`targetMeanPrice2`Weeks52Change2 xcols update potentialReturn:log(targetMeanPrice2%currentPrice2) from statsAllOut; 