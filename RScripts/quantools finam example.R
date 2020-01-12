library("QuantTools")
library("quantmod")

#Rcpp::evalCpp( code = '2 + 2' )
#library( QuantTools )
from = '2019-01-01'
to   = '2019-09-09'
symbol = 'USDRUB'

a <- get_finam_data( symbol, from, to )

chartSeries(a)


#http://iss.moex.com/iss/engines/futures/markets/forts/boards/RFUD/securities/SiH9/candles.json?from=2019-01-01&till=2019-03-01&interval=1&start=5000

## MOEX data storage
settings = list(
  # set MOEX data url
  moex_data_url = 'http://iss.moex.com/iss/engines/futures/markets/forts/boards/RFUD/securities/SiH9/candles.json?from=2019-01-01&till=2019-03-01&interval=1&start=0',
  # set storage path, it is perfect to use Solid State Drive for data storage
  # it is no problem to move storage folder just don't forget to set new path in settings
  moex_storage = paste( path.expand('~') , 'Market Data', 'moex', sep = '/' ),
  # and set storage start date
  moex_storage_from = '2019-01-01'
)
QuantTools_settings( settings )
# now it is time to add some data into storage. You have three options here:

# 1 update storage with data from last date available until today
# it is very convenient to create a script with this function and
# run it every time you need to update your storage
store_moex_data()

# 2 update storage with data from last date available until specified date
store_moex_data( to = format( Sys.Date() ) )

# 3 update storage with data between from and to dates,
# if data already present it will be overwritten
store_moex_data( from = format( Sys.Date() - 3 ), to = format( Sys.Date() ) )

# set local = TRUE to load from just created local market data storage
get_moex_futures_data( 'SiH9', '2019-01-01', '2019-03-01', 'tick', local = T )


get_finam_data( 'GAZP', '2015-01-01', '2016-01-01' )
