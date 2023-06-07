 
library(readxl)
library(grid)

# Read in data
data <- read_excel("/home/petear/MEGA/TormodGroup/GeneArrows.xlsx")
data <- as.data.frame(data)

#Change name of column u-d to UpDown
colnames(data)[colnames(data) == "u-d"] <- "UpDown"


# change ↑ to up and ↓ to down for column u-d
data$UpDown <- gsub("↑", "up", data$UpDown)
data$UpDown <- gsub("↓", "down", data$UpDown)

#rplace NA from column u-d and replace with 0
data$UpDown[is.na(data$UpDown)] <- 0

# create a new column called Clearance and fill it with 0
data$Clearance <- 0

# if the value in column 

# UpGeneVec <- c()
# DownGeneVec <- c()

# #for column u-d, if the value is up, add the value in the column ENTREZID to the vector UpGeneVec
# for (i in 1:nrow(data)){
#   if (data$UpDown[i] == "up"){
#     UpGeneVec <- c(UpGeneVec, data$Genes[i])
#   }
# }

# #for column u-d, if the value is down, add the value in the column ENTREZID to the vector DownGeneVec
# for (i in 1:nrow(data)){
#   if (data$UpDown[i] == "down"){
#     DownGeneVec <- c(DownGeneVec, data$Genes[i])
#   }
# }

#Write UpGeneVec and DownGeneVec to csv files
# write.csv(UpGeneVec, file = "UpGeneVec.csv")
# write.csv(DownGeneVec, file = "DownGeneVec.csv")

# # If a column named "Autophagy" does not exist, create it and fill it with 0
# if (!"Autophagy" %in% colnames(data)){
#   data$Autophagy <- 0
#   # set the column next to Degradation
#     data <- data[,c(1:25, 26, 28, 27)]
#     }

# # If a column named "AD Risk" does not exist, create it and fill it with 0
# if (!"AD Risk" %in% colnames(data)){
#   data$`AD Risk` <- 0
#   # set the column next to Degradation
#     data <- data[,c(1:25, 26, 27, 29,28)]
#     }

# change +/x to 1 for the whole dataframe
data[data == "+"] <- 1
data[data == "x"] <- 1
data[data == "?"] <- 0

# change NA to 0 for the whole dataframe
data[is.na(data)] <- 0


# If any value in column 1 to 4 is 1, change the value in column Uptake to 1
data$Uptake[data$`1.1.1` == 1] <- 1
data$Uptake[data$`1.1.2` == 1] <- 1
data$Uptake[data$`1.2.1` == 1] <- 1
data$Uptake[data$`1.2.2` == 1] <- 1

# If any value in column 5 to 8 is 1, change the value in column Degradation to 1
data$Degradation[data$`2.1.1` == 1] <- 1
data$Degradation[data$`2.1.2` == 1] <- 1
data$Degradation[data$`2.2.1` == 1] <- 1
data$Degradation[data$`2.2.2` == 1] <- 1

# If any value in column 3.1.1 , 3.1.2 , 3.2.1 , 3.2.2 is 1, change the value in column Autophagy to 1  
data$Autophagy[data$`3.1.1` == 1] <- 1
data$Autophagy[data$`3.1.2` == 1] <- 1
data$Autophagy[data$`3.2.1` == 1] <- 1
data$Autophagy[data$`3.2.2` == 1] <- 1

# If any value in column 4.1.1 , 4.1.2 , 4.2.1 , 4.2.2 is 1, change the value in column A to 1
data$A[data$`4.1.1` == 1] <- 1
data$A[data$`4.1.2` == 1] <- 1
data$A[data$`4.2.1` == 1] <- 1
data$A[data$`4.2.2` == 1] <- 1


#If both Uptake and Degradation is 1, change the value in column Clearance to 1
data$Clearance[data$Uptake == 1 & data$Degradation == 1] <- 1

#If both Uptake and Autophagy is 1, change the value in column AutoClear to 1
#data$AutoClear[data$Uptake == 1 & data$Autophagy == 1] <- 1


#set first column as rownames
rownames(data) <- data[,1]

#remove first column
data <- data[,-1]

#make data[1:21] numeric
data[1:16] <- lapply(data[1:16], as.numeric)


############################################################################################
# Column removal
############################################################################################
# remove column 16
#data <- subset(data, select = -AutoClear)

#remove columns with all 0 in column 1:16
data <- data[,colSums(data[1:16]) != 0]

############################################################################################
# Saving data
############################################################################################

#
df <- data.frame(data)

#remove rows where UpDown is 0
df <- df[df$UpDown != 0,]
dfUP <- df[df$UpDown == "up",]
dfDOWN <- df[df$UpDown == "down",]


# create a vector of rownmanes where the value of column Uptake is 1
UptakeVecUp <- rownames(dfUP[dfUP$Uptake == 1,])
UptakeVecUp <- UptakeVecUp[!(UptakeVecUp == "NA" | grepl("^NA\\.", UptakeVecUp))]
UptakeVecDown <- rownames(dfDOWN[dfDOWN$Uptake == 1,])
UptakeVecDown <- UptakeVecDown[!(UptakeVecDown == "NA" | grepl("^NA\\.", UptakeVecDown))]
DegradationVecUP <- rownames(dfUP[dfUP$Degradation == 1,])
DegradationVecUP <- DegradationVecUP[!(DegradationVecUP == "NA" | grepl("^NA\\.", DegradationVecUP))]
DegradationVecDown <- rownames(dfDOWN[dfDOWN$Degradation == 1,])
DegradationVecDown <- DegradationVecDown[!(DegradationVecDown == "NA" | grepl("^NA\\.", DegradationVecDown))]
AutophagyVecUP <- rownames(dfUP[dfUP$Autophagy == 1,])
AutophagyVecUP <- AutophagyVecUP[!(AutophagyVecUP == "NA" | grepl("^NA\\.", AutophagyVecUP))]
AutophagyVecDown <- rownames(dfDOWN[dfDOWN$Autophagy == 1,])
AutophagyVecDown <- AutophagyVecDown[!(AutophagyVecDown == "NA" | grepl("^NA\\.", AutophagyVecDown))]
ClearanceVecUP <- rownames(dfUP[dfUP$Clearance == 1,])
ClearanceVecUP <- ClearanceVecUP[!(ClearanceVecUP == "NA" | grepl("^NA\\.", ClearanceVecUP))]
ClearanceVecDown <- rownames(dfDOWN[dfDOWN$Clearance == 1,])
ClearanceVecDown <- ClearanceVecDown[!(ClearanceVecDown == "NA" | grepl("^NA\\.", ClearanceVecDown))]

library(openxlsx)

filename <- "ForClueSigCom.xlsx"
wb <- createWorkbook()

# Create sheets and write vectors
addWorksheet(wb, "UptakeUP")
addWorksheet(wb, "UptakeDown")
writeData(wb, "UptakeUP", UptakeVecUp)
writeData(wb, "UptakeDown", UptakeVecDown)

addWorksheet(wb, "DegradationUP")
addWorksheet(wb, "DegradationDown")
writeData(wb, "DegradationUP", DegradationVecUP)
writeData(wb, "DegradationDown", DegradationVecDown)

addWorksheet(wb, "AutophagyUP")
addWorksheet(wb, "AutophagyDown")
writeData(wb, "AutophagyUP", AutophagyVecUP)
writeData(wb, "AutophagyDown", AutophagyVecDown)

addWorksheet(wb, "ClearanceUP")
addWorksheet(wb, "ClearanceDown")
writeData(wb, "ClearanceUP", ClearanceVecUP)
writeData(wb, "ClearanceDown", ClearanceVecDown)


saveWorkbook(wb, file = filename, overwrite = TRUE)
############################################################################################
# PLOTTING
############################################################################################
# library(ggplot2)
# pdf("hm1.pdf", width = 10, height = 10)
# my_palette <- colorRampPalette(c("#FF0000", "#0000FF"))(2)
# my_scale <- scale_fill_manual(values = my_palette)

# subset_df <- data[, c(1:12)]
# newnames <- lapply(
#   rownames(data),
#   function(x) bquote(italic(.(x))))

# cols <- list(AD = c("1" = "green", "0"="orange"), PD = c("1" = "white", "0"="black"), ALS = c("1" = "red", "0"="blue"), C = c("1" = "red", "0" = "black"), GR = c("1" = "red", "0" = "black" ), PA = c("1" = "red", "0" = "black" ) )
# colcol = data.frame(data[13], data[14], data[15], data[16], data[17], data[18])

# pheatmap(subset_df, cluster_rows = TRUE, cluster_cols = FALSE, show_rownames = TRUE, labels_row = as.expression(newnames), show_colnames = TRUE, annotation_row = colcol, annotation_colors = cols, legend = FALSE, drop_levels = TRUE)



# dev.off()

#print column 1-15
# print(data[,1:15])


library("ComplexHeatmap")
library(colorRamp2)


#Clearance
#Extra steps created to make it similar to the other three here. BUt maybe a difference is better.
dataCLvec <- data.frame(data["Clearance"])
#dataCLvec[dataCLvec == 0] <- NA
dataCLvec <- as.vector(dataCLvec[,1])

#AD
dataADvec <- data.frame(data["A"])
dataADvec <- as.vector(dataADvec[,1])

#UpDown
dataUDvec <- data.frame(data["UpDown"])
dataUDvec <- as.vector(dataUDvec[,1])

#Uptake
dataUPTvec <- data.frame(data["Uptake"])
dataUPTvec <- as.vector(dataUPTvec[,1])

#Degradation
dataDGvec <- data.frame(data["Degradation"])
dataDGvec <- as.vector(dataDGvec[,1])

#Autophagy
dataAUTvec <- data.frame(data["Autophagy"])
dataAUTvec <- as.vector(dataAUTvec[,1])





#add row at the bottom of the dataframe with values 
data1_9 <- c("Autophagy","Autophagy","Autophagy","Autophagy", "Degradation","Degradation","Degradation","Degradation","Endocytosis","Endocytosis", "Endocytosis")



dForHM <- data[,1:11]



# #if the column-name in 1 change 1 to "UP"

# #CHange 1 to "UP" for column 1, 3, 4, 7 and 9
# dForHM[,1][dForHM[,1] == 1] <- "UP" #111
# dForHM[,3][dForHM[,3] == 1] <- "UP" #121
# dForHM[,4][dForHM[,4] == 1] <- "UP" #211
# dForHM[,7][dForHM[,7] == 1] <- "UP"
# dForHM[,9][dForHM[,9] == 1] <- "UP"

# #CHange 1 to "DOWN" for column 2, 5, 6, and 8
# dForHM[,2][dForHM[,2] == 1] <- "DOWN"
# dForHM[,5][dForHM[,5] == 1] <- "DOWN"
# dForHM[,6][dForHM[,6] == 1] <- "DOWN"
# dForHM[,8][dForHM[,8] == 1] <- "DOWN"

pdf("hm5.pdf", width = 10, height = 14)


# Create HeatmapAnnotation from data[16]
ha_row = rowAnnotation(
    AD = dataADvec,
    col = list(AD = c("1" = "#238b45", "0" = "white")
    ),
    gp = gpar(col = "black"),border = FALSE
    )

rowright = rowAnnotation(
   Uptake = dataUPTvec, Degradation = dataDGvec, Autophagy = dataAUTvec, Clearance = dataCLvec, 
    col = list(
               Uptake = c("1" = "#238b45", "0" = "white"),
               Degradation = c("1" = "#238b45", "0" = "white"),
               Clearance = c("1" = "#FF5722", "0" = "white"),
                Autophagy = c("1" = "#238b45", "0" = "white")
    ),
    gp = gpar(col = "black"),border = FALSE
    )
    
ha_col = HeatmapAnnotation(
    "  " = data1_9, 
    col = list("Gene Function" = c("Autophagy" = "#081d58", "Degradation" = "#ffffd9", "Endocytosis" = "#41b6c4"),
    show_legend = FALSE
    ) 
)
#textt= c("Autophagy","Autophagy","Autophagy", "Degradation","Degradation","Degradation", "Endocytosis","Endocytosis","Endocytosis")
#ha_col = HeatmapAnnotation(foo = anno_text(textt, gp = gpar(fontsize = 8+4)))

#colors = structure(1:3, names = c("UP", "0", "DOWN")) # black, red, green, blue
colors <- c("white","#253494", "#ce1256")

# Draw the heatmap with heatmap annotations
Heatmap(dForHM, name = "Genes", cluster_rows = TRUE, row_dend_side = "right", left_annotation = ha_row, row_names_gp = gpar(fontface = "italic"),  cluster_columns=FALSE,show_row_dend = FALSE, rect_gp = gpar(col = "black", lwd = 0.5), col = colors, na_col = "white",right_annotation =rowright)



dev.off()