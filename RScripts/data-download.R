
getMoexData <- function () {
  data = NULL
  start = 0
  
  repeat {
    conn <- url(
      description = paste0(
        'http://iss.moex.com/iss/engines/futures/markets/forts/boards/RFUD/securities/',
        'SiH9/candles.csv?from=2019-01-01&till=2019-03-21&interval=60&start=',
        start
      )
    )
    
    data.raw <- try(read.csv(file = conn, header = FALSE, stringsAsFactors = FALSE, sep = ";", skip = 3))
    
    if (inherits(data.raw, 'try-error')){
      break
    }
   
    if (is.null(data)) {
      data = data.raw
    }
    else {
      data = rbind(data, data.raw)
    }
    
    row = nrow(data.raw)
    start = start + 500
  }
  
  data
}

data = getMoexData()

plot(data[,3])