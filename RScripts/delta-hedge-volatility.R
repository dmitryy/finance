s0 = 100
n = 100
nc = 100 # experiments count

rate = 0
drift = 0.2
strike = 100
timestep = 0.01
expiry = 1
volStart = 0.7
volEnd = 0.3
#vols = c(
#  seq(volStart, volStart + (volEnd - volStart) / 2, by = (volEnd - volStart) / n),
#  seq(volStart + (volEnd - volStart) / 2, volStart, by = (volStart - volEnd) / n))
vols = seq(volStart, volEnd, by = (volEnd - volStart) / n)
#vols = runif(n, volStart, volEnd)
#vols = rep(0.3, n)

# calculate stock price
nextPrice <- function (s, volatility) {
  s * (1 + drift * timestep + volatility * sqrt(timestep) * rnorm(1))
}

# BS d1
d1 <- function (S, E, r, volatility, expiry, t) {
  (log(S / E) + (r + 0.5 * volatility ^ 2) * (expiry - t)) / (volatility * sqrt(expiry - t))
}

# BS d2
d2 <- function (d1, volatility, expiry, t) {
  d1 - volatility * sqrt(expiry - t)
}

# call
C <- function (S, d1, d2, E, r, expiry, t) {
  S * pnorm(d1) - E * exp(-r * (expiry - t)) * pnorm(d2)
}

# put
P <- function (S, d1, d2, E, r, expiry, t) {
  -S * pnorm(-d1) + E * exp(-r * (expiry - t)) * pnorm(-d2)
}

# delta call
DeltaCall <- function (d1) {
  pnorm(d1)
}

# delta put
DeltaPut <- function (d1) {
  pnorm(d1) - 1
}

s = array(n)
calls = array(n)
puts = array(n)

buyCallDeltas = array(n)
buyPutDeltas = array(n)
sellCallDeltas = array(n)
sellPutDeltas = array(n)

buyCall = array(n)
buyPut = array(n)
sellCall = array(n)
sellPut = array(n)

t = seq(0, timestep * (n - 1), by = timestep)

buyCallIncomeResults = array(nc)
buyPutIncomeResults = array(nc)
sellCallIncomeResults = array(nc)
sellPutIncomeResults = array(nc)

for (j in 1:nc) {
  for (i in 1:n) {
    if (i == 1) {
      s[i] = s0
    }
    else {
      s[i] = nextPrice(s[i - 1], vols[i])
    }
    
    sd1 = d1(s[i], strike, rate, vols[i], expiry, t[i])
    sd2 = d2(sd1, vols[i], expiry, t[i])
    
    calls[i] = C(s[i], sd1, sd2, strike, rate, expiry, t[i])
    puts[i] = P(s[i], sd1, sd2, strike, rate, expiry, t[i])
    
    buyCallDeltas[i] = DeltaCall(sd1)
    buyPutDeltas[i] = DeltaPut(sd1)
    sellCallDeltas[i] = DeltaCall(sd1)
    sellPutDeltas[i] = DeltaPut(sd1)
    
    if (i == 1) {
      buyCall[i] = 0 - (calls[i] - buyCallDeltas[i] * s[i])
      buyPut[i] = 0 - (puts[i] - buyPutDeltas[i] * s[i])
      sellCall[i] = calls[i] - sellCallDeltas[i] * s[i]
      sellPut[i] = puts[i] - sellPutDeltas[i] * s[i]
    }
    else {
      buyCall[i] = buyCall[i - 1] + (buyCallDeltas[i] - buyCallDeltas[i - 1]) * s[i]
      buyPut[i] = buyPut[i - 1] + (buyPutDeltas[i] - buyPutDeltas[i - 1]) * s[i]
      sellCall[i] = sellCall[i - 1] - (sellCallDeltas[i] - sellCallDeltas[i - 1]) * s[i]
      sellPut[i] = sellPut[i - 1] - (sellPutDeltas[i] - sellPutDeltas[i - 1]) * s[i]
    }
  }
  
  buyCallIncomeResults[j] = buyCall[n] + calls[n] - buyCallDeltas[n] * s[n]
  buyPutIncomeResults[j] = buyPut[n] + puts[n] - buyPutDeltas[n] * s[n]
  sellCallIncomeResults[j] = sellCall[n] - calls[n] + sellCallDeltas[n] * s[n]
  sellPutIncomeResults[j] = sellPut[n] - puts[n] + sellPutDeltas[n] * s[n]
}

xrange = range(t)
yrange = range(0:max(s))

par(mfrow=c(2,2))

plot(vols, type = "line", xlab = "", ylab = "Volatility")
plot(s, type = "line", xlab = "", ylab = "Asset")

hist(buyCallIncomeResults, xlab = "", main = "Buy Option")
#hist(buyPutIncomeResults)
hist(sellCallIncomeResults, xlab = "", main = "Sell Option")
#hist(sellPutIncomeResults)

#plot(buyCallDeltas, type = "lines", xlab = "", ylab = "Delta Call")

#plot(calls, type="lines", xlab = "", ylab = "Call")
#plot(buyCall, type = "lines", xlab = "", ylab = "Buy Call Portfolio")
#legend('bottomright', legend = paste('Buy Call Income = ', totalCall))

#plot(puts, type="lines", xlab = "", ylab = "Put")
#plot(buyPut, type = "lines", xlab = "", ylab = "Buy Put Portfolio")
#legend('bottomright', legend = paste('Buy Put Income = ', totalPut))

#plot(sellCall, type = "lines", xlab = "", ylab = "Sell Call Portfolio")
#legend('bottomright', legend = paste('Sell Call Income = ', totalSellCall))

#plot(sellPut, type = "lines", xlab = "", ylab = "Sell Put Portfolio")
#legend('bottomright', legend = paste('Sell Put Income = ', totalSellPut))