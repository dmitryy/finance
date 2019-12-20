library("TTR")

rate = 0
error = 0.001

#########################################################################
# Paste data from console app here
#########################################################################

# asset: RIU9, expires in 56 days, price: 134110, Trade date: 24.07.2019 0:00:00
asset = 134110
expiry = 1 / 252 * 56
callStrikes = c(130000,132500,135000,137500,140000,142500,145000,150000,152500,155000,160000)
callPrices = c(6900,5450,3710,2560,1720,1200,670,230,170,90,40)
putStrikes = c(60000,100000,112500,115000,117500,120000,122500,125000,127500,130000,132500,135000,137500,140000)
putPrices = c(10,70,230,320,500,690,950,1320,1750,2560,3470,4600,6000,7620)

Open = c(121210,120230,119400,119300,117880,117200,120350,120320,121590,120720,120690,123030,124360,122430,123050,123700,122160,122550,123510,123490,126400,125650,125580,127460,128070,128710,130910,131270,131020,131180,132660,133170,136090,134480,135810,135430,136200,136150,135230,137550,136690,137120,138430,137210,138300,137610,138760,137810,137160,137000,136340,136220,135340,135430,134730,134600)
High = c(121440,120720,120000,119410,118500,120500,121000,121990,121590,121580,123150,124760,124520,124070,123770,124050,122920,124130,124070,127300,127260,126640,128060,128670,130070,131630,131490,132690,132330,133110,133850,136650,136370,136350,136560,136390,137080,136780,138360,137910,137730,138580,138850,138310,138340,139270,139540,138040,137980,137090,136970,136650,137000,135740,135480,135400)
Low = c(118750,119380,118950,117150,117000,117110,119620,120080,120420,120330,120630,122640,121980,121880,122960,121590,121390,122540,122070,122450,125180,125200,125370,127330,127870,128450,129910,130970,130530,127100,132610,132710,133800,134350,134460,134470,135270,135160,134600,136370,136130,137120,137210,136600,137310,136830,137240,136140,136910,135560,135360,135120,135310,134510,134150,133960)
Close = c(120240,119720,119740,117680,117700,120500,120520,121640,120770,121120,123100,124690,122500,122990,123650,123540,122600,123600,123880,126740,125720,125630,127540,128200,128650,130800,131430,131030,131300,132780,132960,136030,134450,135690,135370,136070,136130,135280,137710,136610,137170,138470,137260,138220,137510,138820,137750,137100,137130,136460,136110,135340,135450,134760,134660,134110)
ohlc <- data.frame(Open, High, Low, Close)

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

# IV Put
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
yrange = range(0, ivPuts, ivCalls)

plot(xrange, yrange, type = "n", xlab = "Strike", ylab = "Volatility")

points(callStrikes, ivCalls, col = "red3", type = "o")
points(putStrikes, ivPuts, col = "forestgreen", type = "o")

vClose <- volatility(ohlc, calc = "close")
vYZ <- volatility(ohlc, calc = "yang.zhang")

abline(v=asset, col="blue")
abline(h=vYZ[length(vYZ)], col="orange")
abline(h=vClose[length(vClose)], col="black")
