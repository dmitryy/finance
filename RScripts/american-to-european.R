###################################################################################################

# Copyrights https://smart-lab.ru/blog/538016.php

#install.packages('fOptions')

library(fOptions)

###################################################################################################

Implied.Volatility <- function (C, S, K, r, T, type = c('call', 'put')) {
  stopifnot(require('fOptions'))
  type <- match.arg(type)
  
  GBSVolatility(
    price = C, S = S, X = K, Time = T,
    TypeFlag = switch(type, call = 'c', put = 'p'),
    r = r, b = r
  )
}

Implied.Volatilities <- function (C, P, S, K, r, T) {
  sigma.C <- sapply(
    1 : length(K),
    function (i) {
      Implied.Volatility(C = C[i], S = S, K = K[i], r = r, T = T, type = 'call')
    }
  )
  sigma.P <- sapply(
    1 : length(K),
    function (i) {
      Implied.Volatility(C = P[i], S = S, K = K[i], r = r, T = T, type = 'put')
    }
  )
  list(
    K = K,
    sigma.C = sigma.C, sigma.P = sigma.P,
    sigma.OTM = ifelse(K < (S * exp(r * T)), sigma.P, sigma.C),
    sigma.ITM = ifelse(K > (S * exp(r * T)), sigma.P, sigma.C)
  )
}

###################################################################################################

# Parameters:
#   C - option price
#   S - base asset price
#   K - strike
#   r - annualized interest rate, decimal
#   T - time to expiry, in years
#   num.steps - number of steps for binomial model
#   opt.type - type of option to convert from American to European
#   tree.type - binomial pricing model
#     CRR - Cox-Ross-Rubinstein (equal jump)
#     JR - Jarrow-Rudd (equal probabilities)
#     TIAN - Tian (3-moments matching)
# Output:
#   Price of European option, that corresponds binomial
#   model fitted to given price of American option.
De.Americanize <- function (C, S, K, r, T, num.steps,
                            opt.type = c('call', 'put'), tree.type = c('CRR', 'JR', 'TIAN')) {
  
  stopifnot(require('fOptions'))
  
  opt.type <- match.arg(opt.type)
  src.opt.type.flag <- switch(opt.type, call = 'ca', put = 'pa')
  dst.opt.type.flag <- switch(opt.type, call = 'ce', put = 'pe')
  
  tree.type <- match.arg(tree.type)
  pricing.func <- switch(
    tree.type,
    CRR = CRRBinomialTreeOption,
    JR = JRBinomialTreeOption,
    TIAN = TIANBinomialTreeOption
  )
  
  sigma.guess <- Implied.Volatility(
    C = C, S = S, K = K, r = r, T = T, type = opt.type
  )
  opt.res <- optim(
    par = log(sigma.guess),
    fn = function (log.sigma) {
      C.hat <- pricing.func(
        TypeFlag = src.opt.type.flag,
        S = S, X = K, Time = T,
        r = r, b = r,
        sigma = exp(log.sigma),
        n = num.steps
      )
      (C - C.hat@price) ^ 2
    },
    method = 'BFGS'
  )
  
  if (opt.res$convergence != 0) {
    warning('Failed to fit binomial model to option price')
    return (NA)
  }
  
  pricing.func(
    TypeFlag = dst.opt.type.flag,
    S = S, X = K, Time = T,
    r = r, b = r,
    sigma = exp(opt.res$par),
    n = num.steps
  )@price
}

###################################################################################################