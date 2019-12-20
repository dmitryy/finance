# calculate stock price
nextPrice <- function (s, volatility) {
  s * (1 + drift * timestep + volatility * sqrt(timestep) * rnorm(1))
}

# BS d1
d1 <- function (S, E, r, volatility, expiry, t = 0) {
  (log(S / E) + (r + 0.5 * volatility ^ 2) * (expiry - t)) / (volatility * sqrt(expiry - t))
}

# BS d2
d2 <- function (d1, volatility, expiry, t = 0) {
  d1 - volatility * sqrt(expiry - t)
}

# call
C <- function (S, d1, d2, E, r, expiry, t = 0) {
  S * pnorm(d1) - E * exp(-r * (expiry - t)) * pnorm(d2)
}

# put
P <- function (S, d1, d2, E, r, expiry, t = 0) {
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

# vega
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

