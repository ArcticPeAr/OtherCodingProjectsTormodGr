#read feather file
library(feather)
df <- read_feather("/home/petear/MEGA/TormodGroup/InputData/TippyTopGeneDF_ALL.feather")
df2 <- as.data.frame(df)

#Get integers from a text file
path <- "TestGenesEntrez"
my_data <- readLines(path)
my_data <- as.integer(my_data)

#start subset
keep <- df2$ENTREZID %in% my_data
my_subset <- df2[keep, ]

#convert entrezid to symbol
library(org.Hs.eg.db)
my_subset$SYMBOL <- mapIds(org.Hs.eg.db, keys = my_subset$ENTREZID, column = "SYMBOL", keytype = "ENTREZID")


#save as csv
write.csv(my_subset, file = "TestGenesEntrez.csv", row.names = FALSE)

#