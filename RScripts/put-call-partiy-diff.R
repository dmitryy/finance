# asset: RIU9, expires in 56 days, price: 134110, Trade date: 24.07.2019 0:00:00
asset = 134110
expiry = 1 / 252 * 56
callStrikes = c(130000,132500,135000,137500,140000,142500,145000,150000,152500,155000,160000)
callPrices = c(6900,5450,3710,2560,1720,1200,670,230,170,90,40)
putStrikes = c(60000,100000,112500,115000,117500,120000,122500,125000,127500,130000,132500,135000,137500,140000)
putPrices = c(10,70,230,320,500,690,950,1320,1750,2560,3470,4600,6000,7620)

###############################################################################

callIndexes = match(putStrikes, callStrikes)
callIndexes = callIndexes[!is.na(callIndexes)]

n = length(callIndexes)
diff = array(n)
cPrices = array(n)
pPrices = array(n)
strikes = array(n)
S = asset

for (i in 1:length(callIndexes))
{
  i_call = callIndexes[i]
  E_call = callStrikes[i_call]
  C = callPrices[i_call]
  i_put = match(c(E_call), putStrikes)
  E_put = putStrikes[i_put]
  P = putPrices[i_put]
  
  #s[i] - calls[i] + puts[i]
  cPrices[i] = callPrices[i_call]
  pPrices[i] = putPrices[i_put]
  strikes[i] = E_call
  #s[i] - calls[i] + puts[i]
  diff[i] = S - C + P - E_call
}

xrange = range(strikes)
yrange = range(pPrices, cPrices, diff)

plot(xrange, yrange, type = "n", xlab = "Strike", ylab = "Price")

#plot(diff, type = "o")
#points(cPrices, col = "red3", type = "o")
#points(pPrices)

points(strikes, cPrices, type = "o", col = "forestgreen")
points(strikes, pPrices, type = "o", col = "red3")
points(strikes, diff, type = "o")
abline(v=S, col="blue")
abline(h=0, col="black")