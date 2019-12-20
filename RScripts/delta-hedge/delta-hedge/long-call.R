source('C:/Work Home/finance/RScripts/delta-hedge/delta-hedge/common.R')
source('C:/Work Home/finance/RScripts/delta-hedge/delta-hedge/data.R')

n = length(Close)
days = CallDays
optCount = 10

ivCalls = array(n)
deltas = array(n)
counts = array(n)
balance = array(n)

for (i in 1:n) {
  expiry = 1 / 252 * days[i]
  asset = Close[i]
  
  #if (CallClose[i] == 0)
  #{
  #  balance[i] = balance[i - 1]
  #}
  #else
  #{
  ivCalls[i] = IvCall(CallClose[i], strike, expiry, asset, rate, error)
  
  sd1 = d1(asset, strike, rate, ivCalls[i], expiry)
  deltas[i] = DeltaCall(sd1)
  count = round(deltas[i] * optCount)
  counts[i] = count
  
  if (i == 1) {
    count = round(deltas[i] * optCount)
    balance[i] = -CallClose[i] * optCount + count * Close[i]
  }
  else {
    count = round((deltas[i] - deltas[i - 1]) * optCount)
    balance[i] = balance[i - 1] + count * Close[i]
  }
  #}
}

profit = balance[n] + CallClose[n] * optCount - deltas[n] * Close[n]
print(profit)

par(mfrow=c(2,2))

plot(ivCalls)
plot(deltas)
plot(counts)
plot(balance)