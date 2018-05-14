import os
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

dfin = pd.read_csv('csv/dow30dailypx.csv')
df2 = dfin.pivot(index='Date', columns='Sym', values='AdjClose')
df2.head()

log_returns = np.log(df2).diff()
#log_returns.head()
log_returns.describe()

df = log_returns.cumsum()
#df = df.tail(30)
#df = df.iloc[:,0:5]

plt.figure()
df.plot(subplots=True, layout=(10, 3), figsize=(20, 16))

plt.savefig('plot/dow30ytdplot.png')
#plt.show()

df.to_csv('csv/dow30ytdreturn.csv')
print('created plot/dow30ytdplot.png')