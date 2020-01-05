asset = c(69545,68473,67691,67622,67788,67600,67603,67488,67082,67226,66812,66928,67029,66697,66274,66487,66629,66491,66494,65844,66056,66082,65990,66230,66279,66035,66183,66004,66081,67410,66884,66419,66293,65880,65716,65660,65608,66070,66086,66082,65936,65867,65952,66150,66232,66095,65746,65500,65590,65246,64491,64423,64308,63733)
callStrikes = c(69500,68500,67500,67500,67750,67500,67500,67500,67000,67250,66500,67000,67000,66750,66000,66500,66750,66500,66500,65750,66000,66000,66000,66000,66000,66000,66250,66000,66000,67500,67000,66500,66000,66000,65750,65750,65500,66000,66000,66000,66000,65750,66000,66250,66250,66000,65750,65500,65500,65250,64500,64500,64250,63750)
callPrices = c(1880,1648,1657,1577,1585,1670,1571,1501,1436,1483,1445,1280,1330,1262,1232,1210,1100,1123,1072,1034,1015,997,890,1125,1099,990,803,897,884,945,849,824,1000,749,750,730,735,700,700,670,543,600,561,550,551,500,450,370,360,352,255,165,179,2)
putStrikes = c(69500,68500,67500,67500,67500,67500,67500,67500,67000,67250,66500,67000,67000,66500,66250,66500,66500,66500,66500,65750,66000,66000,66000,66000,66000,66000,66000,66000,66000,67500,67000,66500,66000,66000,65750,65750,65500,66000,66000,66000,66000,65750,66000,66000,66000,66000,65750,65500,65500,65250,64500,64500,64250,63750)
putPrices = c(1850,1721,1550,1654,1367,1470,1372,1430,1366,1372,1200,1376,1282,1110,1040,1213,1075,1073,1075,1000,989,907,960,814,814,952,855,902,870,1143,951,900,694,861,800,779,648,632,615,565,602,469,585,488,431,403,407,370,284,284,250,254,127,35)

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

n = length(asset)
ivCall = array(n)
ivPut = array(n)
rate = 0
error = 0.001

for (i in 1:n) {
  expiry = 1 / 252 * (n - (i - 1))
  ivCall[i] = IvCall(callPrices[i], callStrikes[i], expiry, asset[i], rate, error)
  ivPut[i] = IvPut(putPrices[i], putStrikes[i], expiry, asset[i], rate, error)
}

xrange = range(0, n)
yrange = range(0, ivPut, ivCall)

plot(xrange, yrange, type = "n", xlab = "Day", ylab = "Volatility")
#plot(ivCall, type="l")
points(1:n, ivCall, col = "red3", type = "o")
points(1:n, ivPut, col = "forestgreen", type = "o")


