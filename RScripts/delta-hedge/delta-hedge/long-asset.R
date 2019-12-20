source('C:/Work Home/finance/RScripts/delta-hedge/delta-hedge/common.R')
source('C:/Work Home/finance/RScripts/delta-hedge/delta-hedge/data.R')

n = length(Close)
days = CallDays
count = 10

profitLong = (Close[n] - Close[1]) * count
print(profitLong)

profitShort = (Close[1] - Close[n]) * count
print(profitShort)
