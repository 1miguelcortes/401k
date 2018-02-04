\l log.q

loaddata:{[ndays;stocks] 
 tbl:(); / initialize results table
 i:0;
 do[count stocks; /iterate over all the stocks
     stock:stocks[i];
     .log.inf "loading sym: ",string stock;
 
    txt:"data/",(string stock),".csv";
	stocktable: ("DEEEEEI ";enlist",")0: hsym `$txt; / parse the string and create a table from it
    stocktable: update Sym:stock from stocktable; / add a column with name of stock
    tbl,: stocktable; / append the table for this stock to tbl
    i+:1
  ];

 tbl: select from tbl where not null Volume; / get rid of rows with nulls
 `Date`Sym xasc tbl  / order by date and stock
 } 