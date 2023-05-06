 
library(readxl)
library(grid)

# Read in data
data <- read_excel("/home/petear/MEGA/TormodGroup/InputData/GenesPlussArrow.xlsx")
data <- as.data.frame(data)

#change name of column 3 to 1.1.2
colnames(data)[3] <- "1.1.2"
colnames(data)[4] <- "1.2.1"
colnames(data)[5] <- "1.2.2"

data <- as.data.frame(data)

# change ↑ to up and ↓ to down for column u-d
data$UpDown <- gsub("↑", "up", data$UpDown)
data$UpDown <- gsub("↓", "down", data$UpDown)

# change +/x to 1 for the whole dataframe
data[data == "+"] <- 1
data[data == "x"] <- 1
data[data == "?"] <- 0

# change NA to 0 for the whole dataframe
data[is.na(data)] <- 0

#set first column as rownames
rownames(data) <- data[,1]

#remove first column
data <- data[,-1]

#make data[1:21] numeric
data[1:21] <- lapply(data[1:21], as.numeric)




# Make the heatmap with rownames being the names on the y-axis and the column names being the names on the x-axis
library(pheatmap)

pdf("test.pdf")

pheatmap(data[1:14])

