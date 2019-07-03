asset = 100
rate = 0
error = 0.001

#asset: SiU9, expires in 78 days, close price: 64039
asset = 64039
strikes = c(62000,62500,63000,63500,64000,64250,64500,65000,65500,66000,66500,67000,68000,69000,70000,71000,72000,72500,73000,75000,80000)
prices = c(2280,1900,1595,1355,1043,843,820,706,550,455,371,312,180,136,109,79,65,55,48,36,25)
T = 1 / 252 * 78

#asset: SiU9, expires in 78 days, price: 63642
asset = 63642
strikes = c(62000,62500,63000,63500,64000,64250,64500,65000,65500,66000,66500,67000,68000,69000,70000,71000,72000,72500,73000,75000,80000)
prices = c(2280,1825,1550,1169,892,823,850,625,544,433,361,264,180,135,95,73,52,55,46,33,25)

#asset: SiU9, expires in 78 days, price: 64106
asset = 64106
strikes = c(62000,62500,63000,63500,64000,64250,64500,65000,65500,66000,66500,67000,68000,69000,70000,71000,72000,72500,73000,75000,80000)
prices = c(2280,1900,1595,1355,1084,843,850,706,550,455,371,320,180,137,110,79,72,55,48,38,25)

#prices = c(18.6, 14.8, 11.5, 8.9, 7)
#strikes = c(90, 95, 100, 105, 110)
#T = 1

IvCall <- function(C, K, T, S, r, error) {
  vol = 0.2
  dv = error + 1
  while (abs(dv) > error) {
    da = log(S/K) + (r + 0.5 * vol ^ 2) * T
    da = da / (vol * sqrt(T))
    dbee = da - vol * sqrt(T)
    #priceerror = asset * cdf(da) - strike * Exp(-intrate * expiry) * cdf(dbee) - mktprice
    priceerror = S * CDF(da) - K * exp(-r * T) * CDF(dbee) - C
    #vega = asset * Sqr(expiry / 3.1415926 / 2) * Exp(-0.5 * da * da)
    vega = S * sqrt(T / pi / 2) * exp(-0.5 * da * da)
    if (vega == 0)
    {
      a = 1
    }
    #dv = priceerror / vega
    dv = priceerror / vega
    #Volatility = Volatility - dv
    vol = vol - dv
  }
  vol
}

CDF <- function(x) {
  d = 1 / (1 + 0.2316419 * abs(x))
  a1 = 0.31938153
  a2 = -0.356563782
  a3 = 1.781477937
  a4 = -1.821255978
  a5 = 1.330274429
  
  cdf = 1 - 1 / sqrt(2 * 3.1415926) * exp(-0.5 * x ^ 2) * (a1 * d + a2 * d ^ 2 + a3 * d ^ 3 + a4 * d ^ 4 + a5 * d ^ 5)
  
  if (x < 0) {
    1 - cdf
  }
  else {
    cdf
  }
}

n = length(prices)
iv = array(n)

for (i in 1:n) {
  iv[i] = IvCall(prices[i], strikes[i], T, asset, rate, error)
}

plot(strikes, iv, type = "lines")