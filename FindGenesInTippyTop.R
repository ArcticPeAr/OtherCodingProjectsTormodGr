#read feather file
library(feather)
df <- read_feather("/home/petear/MEGA/TormodGroup/InputData/TippyTopGeneDF_ALL.feather")
df2 <- as.data.frame(df)

#Get integers from a text file
geneVector <- c("AXL","IL18","IL1B","ADAM10","PSEN1","IFITM3","BACE1","BIN1","CLU","LRP3","LILRB2","TREM2","SQSTM1")


#convert entrezid to symbol
library(org.Hs.eg.db)
entrez_ids <- select(org.Hs.eg.db, keys = geneVector, columns = "ENTREZID", keytype = "SYMBOL")
#remove NA
valid_entrez_ids <- na.omit(entrez_ids$ENTREZID)

# Assuming df2 is your data frame with the ENTREZID column
filtered_df2 <- subset(df2, ENTREZID %in% valid_entrez_ids)

merged_df <- merge(filtered_df2, entrez_ids, by.x = "ENTREZID", by.y = "ENTREZID")
write_xlsx(merged_df, path = "filtered_df2.xlsx")

#save as ods
library(readODS)
write_ods(merged_df, path = "TestGenesEntrez.ods")


#save as csv
write.csv(merged_df, file = "TestGenesEntrez.csv", row.names = FALSE)

#
library(writexl)