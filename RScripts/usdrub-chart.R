library(timeSeries)

symbol <- 'USD000UTSTOM'
period <- 8
start.date <- as.POSIXlt('2010-01-01')
end.date <- as.POSIXlt(Sys.Date())

conn <- url(
  description = paste0(
    'http://export.finam.ru/', symbol, '_',
    as.character(start.date, format = '%Y%m%d'), '_',
    as.character(end.date, format = '%Y%m%d'), '.csv?',
    'market=0&em=182400&code=', symbol, '&apply=0&',
    'df=', start.date$mday, '&mf=', start.date$mon, '&yf=', 1900 + start.date$year, '&',
    'from=', as.character(start.date, format = '%d.%m.%Y'), '&',
    'dt=', end.date$mday, '&mt=', end.date$mon, '&yt=', 1900 + end.date$year, '&',
    'to=', as.character(end.date, format = '%d.%m.%Y'), '&p=', period, '&',
    'f=', symbol, '_', as.character(start.date, format = '%Y%m%d'), '_',
    as.character(end.date, format = '%Y%m%d'), '&e=.csv&cn=', symbol, '&',
    'dtf=1&tmf=1&MSOR=0&mstime=on&mstimever=1&sep=1&sep2=1&datf=1&at=0'
  )
)

data.raw <- read.csv(file = conn, header = FALSE, stringsAsFactors = FALSE)

plot(timeDate(as.character(data.raw[,3]), format = '%Y%m%d'), 
     data.raw[,8],
     t = 'l', xlab = 'time', ylab = 'price', col = 'darkgreen', lwd = 2
)

abline(
  h = seq(from = 10, to = 100, by = 10),
  v = timeSequence(from = '2014-01-01', to = '2020-01-01', by = 'year'),
  col = 'grey', lty = 'dashed'
)

legend('bottomright', lty = 'solid', col = 'darkgreen', lwd = 2, legend = 'USD/RUB')

