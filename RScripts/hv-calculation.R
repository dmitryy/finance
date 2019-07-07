library("TTR")

data(ttrc)

ohlc <- ttrc[,c("Open", "High", "Low", "Close")]

vClose <- volatility(ohlc, calc = "close")
vGK <- volatility(ohlc, calc = "garman")
vP <- volatility(ohlc, calc = "parkinson")
vRS <- volatility(ohlc, calc = "rogers")
vYZ <- volatility(ohlc, calc = "yang.zhang", n = 252)

plot(vYZ, type = "lines")