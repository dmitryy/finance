library("QuantTools")
library("quantmod")

#Rcpp::evalCpp( code = '2 + 2' )
#library( QuantTools )
from = '2019-01-01'
to   = '2019-09-09'
symbol = 'USDRUB'

a <- get_finam_data( symbol, from, to )

chartSeries(a)