s0 = 100
n = 100

rate = 0.05
drift = 0.2
strike = 100
timestep = 0.01
volatility = 0.3
expiry = 1

# calculate stock price
nextPrice <- function (s) {
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
deltas = array(n)
deltasPut = array(n)
deltasSellCall = array(n)
deltasSellPut = array(n)
calls = array(n)
puts = array(n)
buyCall = array(n)
buyPut = array(n)
sellCall = array(n)
sellPut = array(n)

t = seq(0, timestep * (n - 1), by = timestep)

for (i in 1:n) {
  if (i == 1) {
    s[i] = s0
  }
  else {
    s[i] = nextPrice(s[i - 1])
  }
  
  sd1 = d1(s[i], strike, rate, volatility, expiry, t[i])
  sd2 = d2(sd1, volatility, expiry, t[i])
  calls[i] = C(s[i], sd1, sd2, strike, rate, expiry, t[i])
  puts[i] = P(s[i], sd1, sd2, strike, rate, expiry, t[i])
  deltas[i] = DeltaCall(sd1)
  deltasPut[i] = DeltaPut(sd1)
  deltasSellCall[i] = DeltaCall(sd1)
  deltasSellPut[i] = DeltaPut(sd1)
  
  if (i == 1) {
    buyCall[i] = 0 - (calls[i] - deltas[i] * s[i])
    buyPut[i] = 0 - (puts[i] - deltasPut[i] * s[i])
    sellCall[i] = calls[i] - deltasSellCall[i] * s[i]
    sellPut[i] = puts[i] - deltasSellPut[i] * s[i]
  }
  else {
    buyCall[i] = buyCall[i - 1] + (deltas[i] - deltas[i - 1]) * s[i]
    buyPut[i] = buyPut[i - 1] + (deltasPut[i] - deltasPut[i - 1]) * s[i]
    sellCall[i] = sellCall[i - 1] - (deltasSellCall[i] - deltasSellCall[i - 1]) * s[i]
    sellPut[i] = sellPut[i - 1] - (deltasSellPut[i] - deltasSellPut[i - 1]) * s[i]
  }
}

totalCall = buyCall[n] + calls[n] - deltas[n] * s[n]
totalPut = buyPut[n] + puts[n] - deltasPut[n] * s[n]
totalSellCall = sellCall[n] - calls[n] + deltasSellCall[n] * s[n]
totalSellPut = sellPut[n] - puts[n] + deltasSellPut[n] * s[n]

xrange = range(t)
yrange = range(0:max(s))

#plot(xrange, yrange, type = "n")
#points(t, s, col = "red3", type = "lines")
#points(t, deltas, col = "forestgreen", type = "lines")

par(mfrow=c(4,2))
plot(s, type = "line", xlab = "", ylab = "Asset")
plot(deltas, type = "lines", xlab = "", ylab = "Delta Call")

plot(calls, type="lines", xlab = "", ylab = "Call")
plot(buyCall, type = "lines", xlab = "", ylab = "Buy Call Portfolio")
legend('bottomright', legend = paste('Buy Call Income = ', totalCall))

plot(puts, type="lines", xlab = "", ylab = "Put")
plot(buyPut, type = "lines", xlab = "", ylab = "Buy Put Portfolio")
legend('bottomright', legend = paste('Buy Put Income = ', totalPut))

plot(sellCall, type = "lines", xlab = "", ylab = "Sell Call Portfolio")
legend('bottomright', legend = paste('Sell Call Income = ', totalSellCall))

plot(sellPut, type = "lines", xlab = "", ylab = "Sell Put Portfolio")
legend('bottomright', legend = paste('Sell Put Income = ', totalSellPut))