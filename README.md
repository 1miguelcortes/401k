# 401k

q)httpGet:{[host;location] (`$":http://",host)"GET ",location," HTTP/1.0\r\nHost:",host,"\r\n\r\n"};
q)b:httpGet[ "ichart.finance.yahoo.com"; "/table.csv?s=MSFT" ]	
b:httpGet[ "www.timestored.com"; "/" ]
