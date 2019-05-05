s0 = 100

drift = 0.2
timestep = 0.01
volatility = 0.3
n = 100


s = array(n)

t = seq(0, timestep * n, by = timestep)

for (i in 1:n + 1) {
  if (i == 1) {
    s[i] = s0
  }
  else {
    s0 = s[i - 1]
    rand = rnorm(1)
    s[i] = s0 * (1 + drift * timestep + volatility * sqrt(timestep) * rand)
  }
}

#a = t * 100 * sqrt(rnorm(1) ^ 2)
#b = t * 100 * sqrt(rnorm(1) ^ 2) * 2

xrange = range(t)
yrange = range(0:max(s))

plot(xrange, yrange, type = "n")

points(t, s, col = "red3", type = "lines")
#points(t, b, col = "forestgreen", type = "lines")