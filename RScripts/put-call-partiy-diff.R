# asset: SiU9, expires in 67 days, price: 63616, Trade date: 12.07.2019 0:00:00
# asset: SiU9, expires in 66 days, price: 63165, Trade date: 15.07.2019 0:00:00
asset = 63165
expiry = 1 / 252 * 66
callStrikes = c(62500,63000,63250,63500,63750,64000,64250,64500,64750,65000,65250,65500,65750,66000,66500,67000,68000)
callPrices = c(680,300,203,100,56,45,25,16,12,7,21,6,6,6,7,7,5)
putStrikes = c(60000,60500,61000,61750,62000,62500,62750,63000,63250,63500,63750,64000,64250,64500,65000,65500,65750,67000)
putPrices = c(3,12,4,10,8,30,44,115,231,430,562,842,950,1340,1700,2212,2542,3682)

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