x <- 100
n <- 100
a <- array(n)

# lognormal
toss <- function(x)
  ifelse(rnorm(1, 0) > 0, x * 1.01, x * 0.99)

# arithmetic
tossAr <- function(x)
  ifelse(rnorm(1) > 0, x + 1, x - 1)

for (i in 1:n) {
  x <- toss(x) 
  a[i] <- x
}

plot(a, type = "l")
