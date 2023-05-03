##################################################
#MUST BE RUN WITH SUDO
#Creates folder
##################################################

library("pathfindR")
library("openxlsx")
library("tidyverse")
#This module will be used for pathway analysis using the KEGG database
#The input file is a list of genes that are differentially expressed

#read excel file
DF <- read.xlsx("fullGeneVsDF.xlsx")



#remove the columns: "logCPM", "F", 
DF <- DF %>% select(-logCPM, -F)


#remove the rows that do not have either "C_1-T_5" or "T_5-C_1 or "C_7-T_11" or "T_11-C_7" in the Versus column
DF <- DF %>% filter(Versus == "C_1-T_2" | Versus == "T_2-C_1" | Versus == "C_7-T_8" | Versus == "T_8-C_7")


DF <- DF %>% select(-Versus, -PValue)


library(org.Hs.eg.db)
DF$SYMBOL <- mapIds(org.Hs.eg.db, keys = DF$ENTREZID, column = "SYMBOL", keytype = "ENTREZID")

#load text document and read line by line into a vector
genesList <- readLines("/home/petear/MEGA/TormodGroup/InputData/311Genes")

#Get entrezID for genesList
genesListE <- mapIds(org.Hs.eg.db, keys = genesList, column = "ENTREZID", keytype = "SYMBOL")

# make vector of entrezID
genesList <- as.vector(genesListE)


#Remove rows from DF[SYMBOL] that are not in genesList
DF <- DF %>% filter(ENTREZID %in% genesList)

#sort DF by logFC
DF <- DF[order(DF$logFC),]

#Remove rows that already have the same symbol
DF <- DF %>% distinct(SYMBOL, .keep_all = TRUE)

#remove ENTREZID column 
DF <- DF[,-1]

#set SYMBOL as the first column
DF <- DF[,c(3,1,2)]



output_df <- run_pathfindR(DF)
##################################################
#For algosiscreeener
##################################################

#Read last and second last sheet of excel file
DF <- read.xlsx("AlgoSiScreener.xlsx", sheet = 16)
DF2 <- read.xlsx("AlgoSiScreener.xlsx", sheet = 17) 
#combine the two sheets
DF <- rbind(DF, DF2)

DF <- DF[,c(9, 3, 7)]
#sort DF by logFC
DF <- DF[order(DF$logFC),]

DF <- DF %>% distinct(GeneID, .keep_all = TRUE)

output_df <- run_pathfindR(DF)
