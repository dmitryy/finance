# BS d1
d1 <- function (S, E, r, volatility, expiry) {
  (log(S / E) + (r + 0.5 * volatility ^ 2) * (expiry)) / (volatility * sqrt(expiry))
}

# BS d2
d2 <- function (d1, volatility, expiry) {
  d1 - volatility * sqrt(expiry)
}

# BS call
C <- function (S, d1, d2, E, r, expiry) {
  S * pnorm(d1) - E * exp(-r * (expiry)) * pnorm(d2)
}

# BS put
P <- function (S, d1, d2, E, r, expiry) {
  -S * pnorm(-d1) + E * exp(-r * (expiry)) * pnorm(-d2)
}

Vega <- function (S, d1, expiry) {
  S * sqrt(expiry / pi / 2) * exp(-0.5 * d1 ^ 2)
}

# IV Call
IvCall <- function (C, E, expiry, S, r, error) {
  sigma = 1
  dv = error + 1
  while (!is.na(dv) && abs(dv) > error) {
    d1 = d1(S, E, r, sigma, expiry)
    d2 = d2(d1, sigma, expiry)
    CallPrice = C(S, d1, d2, E, r, expiry)
    Vega = Vega(S, d1, expiry)
    PriceError = CallPrice - C
    dv = PriceError / Vega
    sigma = sigma - dv
  }
  sigma
}

# IV Put
IvPut <- function (P, E, expiry, S, r, error) {
  sigma = 1
  dv = error + 1
  while (!is.na(dv) && abs(dv) > error) {
    d1 = d1(S, E, r, sigma, expiry)
    d2 = d2(d1, sigma, expiry)
    PutPrice = P(S, d1, d2, E, r, expiry)
    Vega = Vega(S, d1, expiry)
    PriceError = PutPrice - P
    dv = PriceError / Vega
    sigma = sigma - dv
  }
  sigma
}

N <- function(d1) {
  pnorm(d1)
}

getMoexData <- function () {
  data = NULL
  start = 0
  
  repeat {
    conn <- url(
      description = paste0(
        'http://iss.moex.com/iss/engines/futures/markets/forts/boards/RFUD/securities/',
        'SiH9/candles.csv?from=2019-01-01&till=2019-03-21&interval=60&start=',
        start
      )
    )
    
    data.raw <- try(read.csv(file = conn, header = FALSE, stringsAsFactors = FALSE, sep = ";", skip = 3))
    
    if (inherits(data.raw, 'try-error')){
      break
    }
    
    if (is.null(data)) {
      data = data.raw
    }
    else {
      data = rbind(data, data.raw)
    }
    
    row = nrow(data.raw)
    start = start + 500
  }
  
  data
}

getTransactionCost <- function (amount) {
  result = amount * 0.3 / 100
  if (result < 1) result = 1
  if (amount == 0) result = 0
  abs(result)
}

getSigma <- function(sigma) {
  dt = 1 / 365 / 24 * 100
  k = 0.3 / 100
  sigma * sqrt(1 + sqrt(8 / (pi * dt)) * k / sigma)
}

# T = 1 # one year
# one year contains 252 business days

# all data contains same length
# 2019 Jan, Feb, Mar SiH9 
#data = getMoexData()
asset = dataMin[,4] # data[,4] # c(69545,68473,67691,67622,67788,67600,67603,67488,67082,67226,66812,66928,67029,66697,66274,66487,66629,66491,66494,65844,66056,66082,65990,66230,66279,66035,66183,66004,66081,67410,66884,66419,66293,65880,65716,65660,65608,66070,66086,66082,65936,65867,65952,66150,66232,66095,65746,65500,65590,65246,64491,64423,64308,63733)
callStrikes = c(69500,68500,67500,67500,67750,67500,67500,67500,67000,67250,66500,67000,67000,66750,66000,66500,66750,66500,66500,65750,66000,66000,66000,66000,66000,66000,66250,66000,66000,67500,67000,66500,66000,66000,65750,65750,65500,66000,66000,66000,66000,65750,66000,66250,66250,66000,65750,65500,65500,65250,64500,64500,64250,63750)
callPrices = c(1880,1648,1657,1577,1585,1670,1571,1501,1436,1483,1445,1280,1330,1262,1232,1210,1100,1123,1072,1034,1015,997,890,1125,1099,990,803,897,884,945,849,824,1000,749,750,730,735,700,700,670,543,600,561,550,551,500,450,370,360,352,255,165,179,2)
putStrikes = c(69500,68500,67500,67500,67500,67500,67500,67500,67000,67250,66500,67000,67000,66500,66250,66500,66500,66500,66500,65750,66000,66000,66000,66000,66000,66000,66000,66000,66000,67500,67000,66500,66000,66000,65750,65750,65500,66000,66000,66000,66000,65750,66000,66000,66000,66000,65750,65500,65500,65250,64500,64500,64250,63750)
putPrices = c(1850,1721,1550,1654,1367,1470,1372,1430,1366,1372,1200,1376,1282,1110,1040,1213,1075,1073,1075,1000,989,907,960,814,814,952,855,902,870,1143,951,900,694,861,800,779,648,632,615,565,602,469,585,488,431,403,407,370,284,284,250,254,127,35)

count = 10
error = 0.001
rate = 0
k = 0.03

results = array(1000)

#for (int in 1:1000) {
  interval = 240 # int #240 # minutes
  n = round(length(asset) / interval) # number of trading hours
  
#calls = array(n) 
#puts = array(n)

deltas = array(n)   # 
futures = array(n)  # count of futures in portfolio
money = array(n)    # intermediate profit
portfolio = array(n)
exps = array(n)
putLosses = array(n)
callLosses = array(n)
transactions = array(n)

ivCall = 0
ivPut = 0

for (i in 1:(n-1)) {
  #expiry = 1 / 252 * (n - i) / 14
  expiry = 1 / (252 * 13.4 * (60 / interval)) * (n - i) # 43374
  exps[i] = expiry
  
  if (i == 1) {
    # create position on first day
    futures[i] = 0 # futures count
    
    # build straddle, short 10 calls and 10 puts
    money[i] = count * callPrices[1] + count * putPrices[1] - getTransactionCost(count * callPrices[1]) - getTransactionCost(count * putPrices[1])
    transactions[i] = getTransactionCost(count * callPrices[1]) + getTransactionCost(count * putPrices[1])
    
    portfolio[i] = 0
    
    # keep IV for future rehedge
    ivCall = IvCall(callPrices[1], callStrikes[1], expiry, asset[i], rate, error)
    ivPut = IvPut(putPrices[1], putStrikes[1], expiry, asset[i], rate, error)
    
    d1Call = d1(asset[i], callStrikes[1], rate, ivCall, expiry)
    d1Put = d1(asset[i], putStrikes[1], rate, ivPut, expiry)
    deltas[i] = N(d1Call) * count - N(-d1Put) * count
    callLosses[i] = 0
    putLosses[i] = 0
    #print(paste("money: ", money[i], "delta:", deltas[i], "futures:", futures[i]))
  }
  else { 
    # rehedge if needed
    assetPrice = asset[i * interval]
    d1Call = d1(assetPrice, callStrikes[1], rate, ivCall, expiry)
    d1Put = d1(assetPrice, putStrikes[1], rate, ivPut, expiry)
    deltas[i] = N(d1Call) * count - N(-d1Put) * count
    
    futures[i] = round(deltas[i]) # - futures[i - 1]
    
    if (callStrikes[1] < assetPrice) {
      # loss on call
      callLosses[i] = (assetPrice - callStrikes[1]) * count
    }
    else
      callLosses[i] = 0
    
    if (putStrikes[1] > assetPrice) {
      # loss on put
      putLosses[i] = (putStrikes[1] - assetPrice) * count
    }
    else 
      putLosses[i] = 0
    
    #if (abs(futures[i] - futures[i - 1]) > 1) {
    money[i] = money[i - 1] - ((futures[i] - futures[i - 1]) * assetPrice) - getTransactionCost((futures[i] - futures[i - 1]) * asset[i]) # - callLosses[i] - putLosses[i]
    portfolio[i] = money[i] - callLosses[i] - putLosses[i] + futures[i] * assetPrice - getTransactionCost(callLosses[i]) - getTransactionCost(putLosses[i]) - getTransactionCost(futures[i] * asset[i])
    transactions[i] = getTransactionCost((futures[i] - futures[i - 1]) * assetPrice)
    
    #}
    #else {
    #  money[i] = money[i - 1]
    #}
    #print(paste("money: ", money[i], "delta:", deltas[i], "futures:", futures[i]))
  }
}

putLoss = 0 # putStrikes[1] - asset[n]
callLoss = 0 # callStrikes[1] - asset[n]
last = length(asset)

if (callStrikes[1] < asset[last]) {
  # loss on call
  callLoss = (asset[last] - callStrikes[1]) * count + getTransactionCost((asset[last] - callStrikes[1]) * count)
}

if (putStrikes[1] > asset[last]) {
  # loss on put
  putLoss = (putStrikes[1] - asset[last]) * count + getTransactionCost((putStrikes[1] - asset[last]) * count)
}

money[n] = money[n - 1] + futures[n-1] * asset[last] - putLoss - callLoss

#par(mfrow=c(2,1))
#plot(s, type = "line", xlab = "", ylab = "Asset")
#plot(deltas, type = "lines", xlab = "", ylab = "Delta Call")
plot(portfolio, type = "l", xlab = "Номер хеджа", ylab = "Портфель")
#plot(futures, type = "l")

#results[int] = portfolio[length(portfolio)]
#}

#plot(results, xlab = "Интервал рехеджа в минутах", ylab = "Прибыль")