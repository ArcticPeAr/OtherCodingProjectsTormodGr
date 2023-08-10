library(readxl)
library(grid)

# Read in data
data <- read_excel("/home/petear/MEGA/TormodGroup/InputData/List for sending up2.xlsx")
data <- as.data.frame(data)

#change ↑ to up and ↓ to down for column u-d
data$'u-d' <- gsub("↑", "up", data$'u-d')
data$'u-d' <- gsub("↓", "down", data$'u-d')

#sorting data into columns starting with 1, 2, 3 and 4. Ie 1.1.1 and 1.1.2 and 1.1.3 and 1.1.4
df1 <- data[, c("...1", "1.1.1", "1.1.2", "1.2.1", "1.2.2", "u-d")]
df2 <- data[, c("...1", "2.1.1", "2.1.2", "2.2.1", "2.2.2", "u-d")]
df3 <- data[, c("...1", "3.1.1", "3.1.2", "3.2.1", "3.2.2", "u-d")]
df4 <- data[, c("...1", "4.1.1", "4.1.2", "4.2.1", "4.2.2", "u-d")]
dfAll <- data[, c("...1", "1.1.1", "1.1.2", "1.2.1", "1.2.2", "2.1.1", "2.1.2", "2.2.1", "2.2.2", "3.1.1", "3.1.2", "3.2.1", "3.2.2", "4.1.1", "4.1.2", "4.2.1", "4.2.2", "u-d")]

#for each dataframe remove rows where all columns, except first and last, are NA
df1 <- df1[!apply(is.na(df1[, c("1.1.1", "1.1.2", "1.2.1", "1.2.2")]), 1, all), ]
df2 <- df2[!apply(is.na(df2[, c("2.1.1", "2.1.2", "2.2.1", "2.2.2")]), 1, all), ]
df3 <- df3[!apply(is.na(df3[, c("3.1.1", "3.1.2", "3.2.1", "3.2.2")]), 1, all), ]
df4 <- df4[!apply(is.na(df4[, c("4.1.1", "4.1.2", "4.2.1", "4.2.2")]), 1, all), ]
dfAll <- dfAll[!apply(is.na(dfAll[, c("1.1.1", "1.1.2", "1.2.1", "1.2.2", "2.1.1", "2.1.2", "2.2.1", "2.2.2", "3.1.1", "3.1.2", "3.2.1", "3.2.2", "4.1.1", "4.1.2", "4.2.1", "4.2.2")]), 1, all), ]

#sort values in u-d column alphabetically
df1 <- df1[order(df1$`u-d`, df1$`1.1.1`), ]
df2 <- df2[order(df2$`u-d`, df2$`2.1.1`), ]
df3 <- df3[order(df3$`u-d`, df3$`3.1.1`), ]
df4 <- df4[order(df4$`u-d`, df4$`4.1.1`), ]
dfAll <- dfAll[order(dfAll$`u-d`, dfAll$`1.1.1`), ]

#save as xlsx file with sheet names
library(xlsx)

wb <- createWorkbook()
sheet1 <- createSheet(wb, sheetName = "1")
sheet2 <- createSheet(wb, sheetName = "2")
sheet3 <- createSheet(wb, sheetName = "3")
sheet4 <- createSheet(wb, sheetName = "4")
sheetAll <- createSheet(wb, sheetName = "All")


addDataFrame(df1, sheet1, row.names = FALSE)
addDataFrame(df2, sheet2, row.names = FALSE)
addDataFrame(df3, sheet3, row.names = FALSE)
addDataFrame(df4, sheet4, row.names = FALSE)
addDataFrame(dfAll, sheetAll, row.names = FALSE)

saveWorkbook(wb, "/home/petear/MEGA/TormodGroup/SortedData.xlsx")
