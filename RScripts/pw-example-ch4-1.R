# PWIQF excercise 1 chapter 4 (p.145)

n = 100
s0 = 100

drift = 0.12 # return annual
volatility = 0.2 # annual
timestep = 1/52

# calculate stock price
#nextPrice <- function (s) {
#  s * (1 + drift * timestep + volatility * sqrt(timestep) * rnorm(1))
#}

dS <- function(S) {
  S * (1 + drift * timestep + volatility * sqrt(timestep) * rnorm(1))
}

s = array(n)

for (i in 1:n) {
  if (i == 1) {
    s[i] = s0
  }
  else {
    s[i] = dS(s[i - 1])
  }
}

plot(s, type = "line")