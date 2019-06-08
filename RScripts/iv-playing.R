library(readxl)

riData <- read_excel("D:/Work/finance/RScripts/data/RIZ8-ru.xlsx")
ri <- riData[!is.na(riData$`Цена последней сделки`), ]$`Цена первой сделки`

par(mfrow=c(3,1)) 
plot(ri, type = "line")

ri <- rev(ri)

size = 2
count = length(ri) - size
sigmas = array(count)

for (i in 1:count) {
  sigmas[i] = sd(ri[1:size])
  size = size + 1
}

plot(sigmas, type = "line")

ssize = 2
scount = length(sigmas) - ssize
ssigmas = array(scount)

for (i in 1:scount) {
  ssigmas[i] = sd(sigmas[1:ssize])
  ssize = ssize + 1
}

plot(ssigmas, type = "line")
