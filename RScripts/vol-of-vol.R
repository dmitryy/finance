volatility = vClose[!is.na(vClose)]

volatility.changes = diff(volatility)
volatility.log = array(length(volatility))
volatility.log[1:length(volatility)] = 0

block.size = 20
block.count = floor(length(volatility.changes) / block.size)

volatility.mean = array(block.count - 1)
volatility.var = array(block.count - 1)

for (i in 1:(block.count - 1)) {
  start = (i - 1) * block.size + 1
  end = start + block.size

  volatility.mean[i] = mean(volatility.changes[start:end])
  volatility.var[i] = var(volatility.changes[start:end])
  volatility.log[start:end] = log(volatility.var[i])
}

linear_model <- lm(log(volatility.var) ~ log(volatility))
#plot(volatility.mean)
#plot(log(volatility), volatility.log, xlab = 'log(sigma)', ylab = 'log(sigma.bucket.variance)')
plot(volatility.log ~ log(volatility))

abline(linear_model) 
