

#read feather file tippy top genes
library(feather)

library(tidyverse)

dfF <- read_feather("/home/petear/MEGA/TormodGroup/InputData/TippyTopGeneDF_ALL.feather")
dfF <- as.data.frame(dfF)

#VEGF-A = 7422
#VEGF-C = 7424

geneVec <- c(7422)

#remove from the column ENTREZID rows not in geneVec
dfF <- dfF[dfF$ENTREZID %in% geneVec,]

#remove columns "logCPM", "PValue" and "F" from dfF
dfF <- dfF[,c(1,2,3, 6,7)]

#remove rows from "Versus" column that does not contain "T2" or "T8" as part of the string either before or after the -
dfF <- dfF[grepl("T_2|T_8", dfF$Versus),]

#go through each row of dfF and split the Versus column into two columns to the left and right of the -
dfF <- dfF %>% separate(Versus, into = c("Left", "Right"), sep = "-")

#go through each row and if the value in the Right column is T_2 OR T_8 then change the sign of the logFC column
dfF$logFC <- ifelse(dfF$Right == "T_2", -dfF$logFC, dfF$logFC)
dfF$logFC <- ifelse(dfF$Right == "T_8", -dfF$logFC, dfF$logFC)

# Check which rows meet the condition
condition <- dfF$Right == "T_2" | dfF$Right == "T_8"

# Create a new data frame with the values switched for the rows that meet the condition
new_data <- dfF
new_data[condition, "Left"] <- dfF[condition, "Right"]
new_data[condition, "Right"] <- dfF[condition, "Left"]

#if the value in the Left column is T_2 then change the value in the column named "logCPM" to "LPS"
new_data$logCPM <- ifelse(new_data$Left == "T_2", "LPS", new_data$logCPM)


#if the value in the Left column is T_2 then change the value in the column named "logCPM" to "Ab+LPS"
new_data$logCPM <- ifelse(new_data$Left == "T_8", "Ab+LPS", new_data$logCPM)

#sort the data frame by the values in logCPM 
new_data <- new_data[order(new_data$logCPM),]

#rename the column "logCPM" to "Treatment"
colnames(new_data)[colnames(new_data) == "logCPM"] <- "Treatment"

#switch the columns "Treatment" and "FDR
new_data <- new_data[,c(1,2,4,3,5,6)]

#Unwanted samples T_3, T_4, T_5 and T_6: 
#remove rows from the data frame where the value in the column "Right" is T_3, T_4, T_5 or T_6
new_data <- new_data[!grepl("T_3|T_4|T_5|T_6", new_data$Right),]


#write to excel
library(openxlsx)
write.xlsx(new_data, file = "/home/petear/MEGA/TormodGroup/InputData/VEGF-A.xlsx", sheetName = "Sheet1", append = TRUE)