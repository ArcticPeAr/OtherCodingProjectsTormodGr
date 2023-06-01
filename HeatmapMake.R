 
library(readxl)
library(grid)

# Read in data
data <- read_excel("/home/petear/MEGA/TormodGroup/InputData/GenesPlussArrow.xlsx")
data <- as.data.frame(data)

#change name of column 3 to 1.1.2
# colnames(data)[3] <- "1.1.2"
# colnames(data)[4] <- "1.2.1"
# colnames(data)[5] <- "1.2.2"


# change ↑ to up and ↓ to down for column u-d
data$UpDown <- gsub("↑", "up", data$UpDown)
data$UpDown <- gsub("↓", "down", data$UpDown)

#rplace NA from column u-d and replace with 0
data$UpDown[is.na(data$UpDown)] <- 0



UpGeneVec <- c()
DownGeneVec <- c()

#for column u-d, if the value is up, add the value in the column ENTREZID to the vector UpGeneVec
for (i in 1:nrow(data)){
  if (data$UpDown[i] == "up"){
    UpGeneVec <- c(UpGeneVec, data$Genes[i])
  }
}

#for column u-d, if the value is down, add the value in the column ENTREZID to the vector DownGeneVec
for (i in 1:nrow(data)){
  if (data$UpDown[i] == "down"){
    DownGeneVec <- c(DownGeneVec, data$Genes[i])
  }
}

#Write UpGeneVec and DownGeneVec to csv files
write.csv(UpGeneVec, file = "UpGeneVec.csv")
write.csv(DownGeneVec, file = "DownGeneVec.csv")




# change +/x to 1 for the whole dataframe
data[data == "+"] <- 1
data[data == "x"] <- 1
data[data == "?"] <- 0

# change NA to 0 for the whole dataframe
data[is.na(data)] <- 0


# If any value in column 1 to 4 is 1, change the value in column 20 to 1
data$Uptake[data$`1.1.1` == 1] <- 1
data$Uptake[data$`1.1.2` == 1] <- 1
data$Uptake[data$`1.2.1` == 1] <- 1
data$Uptake[data$`1.2.2` == 1] <- 1

# If any value in column 5 to 11 is 1, change the value in column 21 to 1
data$Degradation[data$`2.1.1` == 1] <- 1
data$Degradation[data$`2.1.2` == 1] <- 1
data$Degradation[data$`2.1.3` == 1] <- 1
data$Degradation[data$`2.2.1` == 1] <- 1
data$Degradation[data$`2.2.2` == 1] <- 1
data$Degradation[data$`2.2.3` == 1] <- 1
data$Degradation[data$`2.2.4` == 1] <- 1


#set first column as rownames
rownames(data) <- data[,1]

#remove first column
data <- data[,-1]

#make data[1:21] numeric
data[1:18] <- lapply(data[1:18], as.numeric)

#set 0 in column 19 to NA (for the heatmap)
data[19][data[19] == 0] <- "NA"

#set column 13 as string
data[13] <- lapply(data[13], as.character)
data[14] <- lapply(data[14], as.character)
data[15] <- lapply(data[15], as.character)
data[16] <- lapply(data[16], as.character)
data[17] <- lapply(data[17], as.character)
data[18] <- lapply(data[18], as.character)

############################################################################################
# Column removal
############################################################################################
# remove column 16
data <- data[,-16]

# remove columns with only 0 as values
data <- data[,colSums(data != 0) > 0]


# add a row at the bottom of the dataframe with values 



# Make the heatmap with rownames being the names on the y-axis and the column names being the names on the x-axis
library(pheatmap)



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


data16vec <- data.frame(data[16])
data16vec <- as.vector(data16vec[,1])

data11vec <- data.frame(data[11])
data11vec <- as.vector(data11vec[,1])

data12vec <- data.frame(data[12])
data12vec <- as.vector(data12vec[,1])

data13vec <- data.frame(data[13])
data13vec <- as.vector(data13vec[,1])

data10vec <- data.frame(data[10])
data10vec <- as.vector(data10vec[,1])

data16vec <- data.frame(data[16])
data16vec <- as.vector(data16vec[,1])


data17vec <- data.frame(data[17])
data17vec <- as.vector(data17vec[,1])

#remove NA from vector 16 and replace with 0   
data16vec[is.na(data16vec)] <- 0
#remove "NA" from vector 16 and replace with 0
data16vec[data16vec == "NA"] <- 0






#add row at the bottom of the dataframe with values 
data1_9 <- c("Autophagy","Autophagy","Autophagy", "Degradation","Degradation","Degradation","Endocytosis","Endocytosis","Endocytosis")



dForHM <- data[,1:9]

#CHange 1 to "UP" for column 1, 3, 4, 7 and 9
dForHM[,1][dForHM[,1] == 1] <- "UP" #111
dForHM[,3][dForHM[,3] == 1] <- "UP" #121
dForHM[,4][dForHM[,4] == 1] <- "UP" #211
dForHM[,7][dForHM[,7] == 1] <- "UP"
dForHM[,9][dForHM[,9] == 1] <- "UP"

#CHange 1 to "DOWN" for column 2, 5, 6, and 8
dForHM[,2][dForHM[,2] == 1] <- "DOWN"
dForHM[,5][dForHM[,5] == 1] <- "DOWN"
dForHM[,6][dForHM[,6] == 1] <- "DOWN"
dForHM[,8][dForHM[,8] == 1] <- "DOWN"

#convert 0 in dForHM to string
dForHM[dForHM == 0] <- "0"



pdf("hm27.pdf", width = 10, height = 14)


# Create HeatmapAnnotation from data[16]
ha_row = rowAnnotation(
    ALS= data13vec,
    PD = data12vec,
    AD = data11vec,
    col = list(ALS = c("1" = "#238b45", "0" = "white"),
               PD = c("1" = "#238b45", "0" = "white"),
               AD = c("1" = "#238b45", "0" = "white")
    ),
    gp = gpar(col = "black"),border = FALSE
    )

rowright = rowAnnotation(
   Uptake = data16vec, Degradation = data17vec,  
    col = list(
               Uptake = c("1" = "#238b45", "0" = "white"),
               Degradation = c("1" = "#238b45", "0" = "white")
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
Heatmap(dForHM, name = "Genes", cluster_rows = TRUE, row_dend_side = "right", left_annotation = ha_row, row_names_gp = gpar(fontface = "italic"), bottom_annotation = ha_col, cluster_columns=FALSE,show_row_dend = FALSE, rect_gp = gpar(col = "black", lwd = 0.5), col = colors, na_col = "white",right_annotation =rowright)



dev.off()