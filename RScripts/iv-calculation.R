rate = 0
error = 0.0001

#########################################################################
# Paste data from console app here
#########################################################################

# asset: RIU9, expires in 78 days, price: 137170, Trade date: 03.07.2019 0:00:00
asset = 137170
expiry = 1 / 252 * 78
callStrikes = c(130000,132500,135000,137500,140000,142500,145000,147500,150000,155000,157500,160000,180000)
callPrices = c(10000,8250,6690,5050,3750,2900,2200,1470,1000,400,240,190,20)
putStrikes = c(80000,90000,95000,97500,100000,105000,107500,110000,115000,117500,120000,122500,125000,127500,130000,132500,135000,137500,140000)
putPrices = c(40,60,150,120,130,200,270,330,570,750,980,1250,1610,2130,2720,3410,4320,5400,7250)

#########################################################################

# BS d1
d1 <- function (S, E, r, volatility, expiry) {
  (log(S / E) + (r + 0.5 * volatility ^ 2) * (expiry)) / (volatility * sqrt(expiry))
}

# BS d2
d2 <- function (d1, volatility, expiry) {
  d1 - volatility * sqrt(expiry)
}

# call
C <- function (S, d1, d2, E, r, expiry) {
  S * pnorm(d1) - E * exp(-r * (expiry)) * pnorm(d2)
}

# put
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
  while (abs(dv) > error) {
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

IvPut <- function (P, E, expiry, S, r, error) {
  sigma = 1
  dv = error + 1
  while (abs(dv) > error) {
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

n1 = length(callStrikes)
n2 = length(putStrikes)

ivCalls = array(n1)
ivPuts = array(n2)

for (i in 1:n1) {
  ivCalls[i] = IvCall(callPrices[i], callStrikes[i], expiry, asset, rate, error)
}

for (i in 1:n2) {
  ivPuts[i] = IvPut(putPrices[i], putStrikes[i], expiry, asset, rate, error)
}

xrange = range(putStrikes, callStrikes)
yrange = range(ivPuts, ivCalls)

plot(xrange, yrange, type = "n", xlab = "Strike", ylab = "Volatility")

points(callStrikes, ivCalls, col = "red3", type = "o")
points(putStrikes, ivPuts, col = "forestgreen", type = "o")

abline(v=asset, col="blue")
