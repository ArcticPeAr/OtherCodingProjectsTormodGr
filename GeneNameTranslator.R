#import csv file

csv <- read.csv("/home/petear/MEGA/TormodGroup/genes4Translate.csv" , header = FALSE, sep = ",")

csvVec <- as.vector(csv$V1)
