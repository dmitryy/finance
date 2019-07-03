library(timeSeries)
library(kohonen)
# src https://wilmott.com/data-and-code-for-r-tutorial-on-machine-learning-how-to-visualize-option-like-hedge-fund-returns-for-risk-analysis/

# This R code is to accompany the article "R Tutorial on Machine Learning: How to Visualize Option-Like Hedge Fund Returns for Risk Analysis", published in Wilmott Magazine, January 2019.
# Created in 2018 by Rodex Risk Advisers LLC, Altendorf SZ, Switzerland.
# The information contained in this file is for general information purposes only. Rodex Risk Advisers assumes no responsibility for errors or omissions in the contents of the Service.

# Download CSV file and save on your local drive. Set working drive:
#setwd("myDrive")

s_data_file <- "Data-Tutorial.csv"                       # Name of CSV-file with data.
no_units <- 25                                   # Set the number of units of the SOM.
d_start_INS <- "1994-01-31"                          # Set start and ...
d_end_INS <- "2017-12-31"                            # ... end date for in-sample period.

s_dd <- read.table(s_data_file, sep = ",", header = TRUE)        # Read SPX index data.
s_date <- as.Date(s_dd[ , 1], format="%d/%m/%Y")         # Convert column 1 to date format.
z <- timeSeries(s_dd[ , 2], s_date)                      # Create z as timeSeries.
z <- apply(z, 2, as.numeric)                         # Convert z to numeric.
x_ret <- returns(z, method = "discrete")                 # Calculate returns from indices.
x_SPX <- matrix(NA, nrow = nrow(x_ret), ncol = 2)            # Create new matrix to hold variables.
x_SPX[ , 1] <- x_ret[ , 1]
x_SPX[ , 2] <- abs(x_SPX[ , 1])                      # ABS function mimics a long straddle.
colnames(x_SPX) <- c("SPX", "ABS_SPX")
x_SPX_TS <- timeSeries(x_SPX, time(x_ret))               # Create timeSeries for later analysis.

x_INS <- window(x_SPX_TS, d_start_INS, d_end_INS)            # Cut window for training data (= in-sample).
y <- match(as.Date(d_end_INS), as.Date(time(x_SPX_TS)))      # Determine row number of last in-sample data point.
x_OOS <- x_SPX_TS[(1 + y):nrow(x_ret), ]                 # Cut window for prediction data (=out-of-sample).

# Prepare scatterplot:
s_dd <- rep("black", nrow(x_INS))                        # Paint in-sample data points in black.
s_dd <- c(s_dd, rep("red", nrow(x_OOS)))                 # Paint out-of-sample data points in red.
s_cex <- rep(1, nrow(x_INS))                         # Draw in-sample data points in small size.
s_cex <- c(s_cex, rep(3, nrow(x_OOS)))                   # Draw out-of-sample data points in larger size.

plot(x_SPX, main = "Scatterplot", col = s_dd, cex = s_cex)
cor(x_INS)                                      # Print linear correlation matrix.

x <- scale(embed(x_INS, 1))                          # Scale variable to mean 0 and variance 1; embed eliminates the dates from the the timeSeries x_INS (needed for processing with function som later).

set.seed(7)                                     # Setting the seed for random generator leads to reproducible results. SOMs will change if seed is not set (try and run the next 7 lines with commenting this line out).
# Create a 5 x 5 SOM with hexagonal units and a bubble neighbourhood function:
x.grid = somgrid(sqrt(no_units), sqrt(no_units), topo = "hexagonal", neighbourhood.fct = "bubble")
x.som <- som(x, x.grid, rlen = 10000, alpha = c(0.05, 0.01), keep.data = TRUE, mode = "online", dist.fcts = "euclidean")
summary(x.som)
plot(x.som, type="changes", main = "Training Progress")
plot(x.som, type= "counts", main = "Mapping Frequencies", shape = "straight")   # Plot the SOM with the number of monthly returns mapped onto each unit.
plot(x.som, type ="quality", shape = "straight")            # Mapping quality.

y <- which(x.som$unit.classif == 20)     # Which monthly returns were mapped onto unit 20?
x_SPX_TS[y, ]                   # Output monthly returns mapped onto unit 1.

plot(x.som, type = "codes", main = "Codebook Vectors", shape = "straight")
som_cluster <- cutree(hclust(object.distances(x.som, "codes")), 5)   # Separate 5 areas on the SOM.
add.cluster.boundaries(x.som, som_cluster)                  # Draw cluster boundaries on SOM.
# Try set.seed(10) and compare results!

# Analyse clusters:
x.som$unit.classif      # Show onto which units the monthly returns were mapped.

# Variable x_units determines which units are shown:

x_units <-  25           # Change this to analyse the other clusters described below.

# Cluster 5: x_units <- 25; SPX v.lo (< -15%), ABS_SPX v.hi (> +15%)
# Cluster 4: x_units <- c(22, 23); SPX v.hi (+7 to +11%), ABS_SPX v.hi (+7 to +11%)
# Cluster 3: x_units <- c(14, 15, 20, 24); SPX lo (-5 to -8%), ABS_SPX hi (+5 to +8%)
# Cluster 2: x_units <- c(12, 13, 16, 17, 18, 19, 21); SPX hi (+3 to +7%), ABS_SPX hi (+3 to +7%)
# Cluster 1: x_units <- c(1:11); SPX mid (-4 to +2%), ABS_SPX mid (+2 to +4%)

# Print the monthly returns mapped onto cluster as defined above:
y <- x.som$unit.classif %in% x_units # Creates vector with TRUE if month is mapped onto x_units, FALSE otherwise.
y <- y * 1:NROW(x_INS)               # Convert TRUE/FALSE vector to vector with index for TRUE, 0 otherwise.
y <- y[y > 0]                 # Eliminate all 0s from index.
x_SPX_TS[y, ]                   # Print months based on index.

##########
# Place unknown data on the map (prediction):

zz_OOS <- embed((x_OOS - apply(x_INS, 2, mean)) / apply(x_INS, 2, sd), 1)    # Scale out-of-sample returns with in-sample mean and st.dev.
# These scaled data points can then be applied to generate the out-of-sample predictions:
x_pred <- predict(x.som, newdata = zz_OOS, x)    # Out-of-sample prediction.
x_pred$unit.classif             # Print to which units the out-of-sample monthly returns are mapped.