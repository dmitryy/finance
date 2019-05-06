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

s = array(n)
calls = array(n)
puts = array(n)
parity = array(n)
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
  parity[i] = s[i] - calls[i] + puts[i]
}

xrange = range(t)
yrange = range(0:max(s))

plot(xrange, yrange, type = "n")

points(t, s, col = "red3", type = "lines")
points(t, calls, col = "forestgreen", type = "lines")
points(t, puts, col = "blue", type = "lines")
points(t, parity, col = "orange", type = "lines")
