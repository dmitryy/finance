#library("TTR")
#library("quantmod")
library("xts")
library("timeSeries")

source('C:/Work Home/finance/RScripts/delta-hedge/delta-hedge/data.R')

#xttrc <- xts(OHLCV(ohlc)) #, ttrc[["Date"]])
#candleChart(ohlc)
#chartSeries(xttrc)

#a = as.xts(ohlc, dateFormat='Date')

x <- timeSeries(1:10, 1:10)
a <- as.xts(x)

# TODO: learn how to create time series and how to work with them