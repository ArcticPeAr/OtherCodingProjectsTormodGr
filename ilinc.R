library(htmltools)
library(knitr)
library(tinytex)
library(httr)
library(jsonlite)


#Read excel file and all sheets
library(readxl)
library(tidyverse)

#Read excel file and all sheets

myData <- read_excel("/home/petear/MEGA/TormodGroup/InputData/DFMergedAlgoSiScreen.xlsx")
myDataDF <- as.data.frame(myData)



#Add column to myDataDF named "signatureID" where all values are "LINCSCP_100"
myDataDF$signatureID <- "NA"

#Add column to myDataDF named "PROBE" where all values are NA
myDataDF$PROBE <- NA

#Remove the columns "...1", "logCPM", "F", "Versus" from myDataDF by name
myDataDF <- myDataDF[ , !(names(myDataDF) %in% c("...1", "logCPM", "F", "Versus"))]


#Rearrange columns in myDataDF SO THAT "signatureID" is the first column and "PROBE" is the second column
myDataDF <- myDataDF[, c("PROBE", setdiff(names(myDataDF), "PROBE"))]

myDataDF <- myDataDF[, c("signatureID", setdiff(names(myDataDF), "signatureID"))]

colnames(myDataDF)[colnames(myDataDF)=="ENTREZID"] <- "ID_geneid"
colnames(myDataDF)[colnames(myDataDF)=="GeneID"] <- "Name_GeneSymbol"
colnames(myDataDF)[colnames(myDataDF)=="logFC"] <- "Value_LogDiffExp"
colnames(myDataDF)[colnames(myDataDF)=="PValue"] <- "Significance_pvalue"


#myDataDF <- myDataDF[,c(1:3, 4, 5, 6)]

myDataDF <- myDataDF[,c(1:3, 7, 4, 5, 6)]

#
#read first column of csv and add to vector
genes <- read.csv("/home/petear/MEGA/TormodGroup/entrezIDs.csv", header = FALSE)
genes <- genes[,1]
genes <- as.vector(genes)

#merge the two lists into one list
#topRegulatedGenes <- c("HBEGF", "OSBPL6", "LYN", "APBB2", "DLL1", "CAMK2A", "TLR3", "TNK2", "NOD2", "LAMP3","IL12A","GPER1")


#remove rows from myDataDF where the "Name_GeneSymbol" column is not in the "genesUp" list
myDataDF <- myDataDF[myDataDF$Name_GeneSymbol %in% topRegulatedGenes,]

apiUrl<-"http://www.ilincs.org/api/SignatureMeta/upload"
write.table(myDataDF, file='myDataDF.tsv', quote=FALSE, sep='\t')
sigFile <- "myDataDF.tsv"
req <- POST(apiUrl, body=list(file=upload_file("sigFile.tsv")))
signatureFile <- httr::content(req)$status$fileName[[1]]
apiUrl <- "http://www.ilincs.org/api/ilincsR/findConcordances"
req <- (POST(apiUrl, body = list(file=signatureFile, lib="LIB_5"), encode = "form"))
output <- data.table::rbindlist(httr::content(req)$concordanceTable, use.names = TRUE, fill = TRUE)
write.csv(output, file = "ilincsUpDnConnectedSignaturesFull.csv", row.names = FALSE)

apiUrl <- paste("http://www.ilincs.org/api/ilincsR/signatureEnrichment?sigFile=",signatureFile,"&library=LIB_5&metadata=TRUE",sep="")
req <- GET(apiUrl)
json <- httr::content(req, as = "text")
iLincsConnectedCompoundPerturbations <- fromJSON(json)$enrichment
head(iLincsConnectedCompoundPerturbations)
write.csv(iLincsConnectedCompoundPerturbations, file = "FullConnectedCompoundPerturbations.csv", row.names = FALSE)

apiUrl <- paste("http://www.ilincs.org/api/ilincsR/signatureEnrichment?sigFile=",signatureFile,"&library=LIB_6",sep="")
req <- GET(apiUrl)
json <- httr::content(req, as = "text")
iLincsConnectedGeneticPerturbations <- fromJSON(json)$enrichment
head(iLincsConnectedGeneticPerturbations)
write.csv(iLincsConnectedGeneticPerturbations, file = "FullConnectedGeneticPerturbations.csv", row.names = FALSE)



############################################################################################
myDataDFP <- subset(myDataDF, select = -c(FDR))

apiUrl<-"http://www.ilincs.org/api/SignatureMeta/upload"
write.table(myDataDFP, file='myDataDFP.tsv', quote=FALSE, sep='\t')
sigFile <- "myDataDFP.tsv"
req <- POST(apiUrl, body=list(file=upload_file("sigFile.tsv")))
signatureFile <- httr::content(req)$status$fileName[[1]]
apiUrl <- "http://www.ilincs.org/api/ilincsR/findConcordances"
req <- (POST(apiUrl, body = list(file=signatureFile, lib="LIB_5"), encode = "form"))
output <- data.table::rbindlist(httr::content(req)$concordanceTable, use.names = TRUE, fill = TRUE)
write.csv(output, file = "ilincsUpDnConnectedSignaturesP-val.csv", row.names = FALSE)


apiUrl <- paste("http://www.ilincs.org/api/ilincsR/signatureEnrichment?sigFile=",signatureFile,"&library=LIB_5&metadata=TRUE",sep="")
req <- GET(apiUrl)
json <- httr::content(req, as = "text")
iLincsConnectedCompoundPerturbations <- fromJSON(json)$enrichment
head(iLincsConnectedCompoundPerturbations)
write.csv(iLincsConnectedCompoundPerturbations, file = "PvalConnectedCompoundPerturbations.csv", row.names = FALSE)

apiUrl <- paste("http://www.ilincs.org/api/ilincsR/signatureEnrichment?sigFile=",signatureFile,"&library=LIB_6",sep="")
req <- GET(apiUrl)
json <- httr::content(req, as = "text")
iLincsConnectedGeneticPerturbations <- fromJSON(json)$enrichment
head(iLincsConnectedGeneticPerturbations)
write.csv(iLincsConnectedGeneticPerturbations, file = "PvalConnectedGeneticPerturbations.csv", row.names = FALSE)



###########################################################################################
myDataFDRisPv <- myDataDF

myDataFDRisPv$Significance_pvalue <- myDataFDRisPv$FDR

myDataFDRisPv <- subset(myDataFDRisPv, select = -c(FDR))

apiUrl<-"http://www.ilincs.org/api/SignatureMeta/upload"
write.table(myDataDFP, file='myDataDFP.tsv', quote=FALSE, sep='\t')
sigFile <- "myDataFDRisPv.tsv"
req <- POST(apiUrl, body=list(file=upload_file("sigFile.tsv")))
signatureFile <- httr::content(req)$status$fileName[[1]]
apiUrl <- "http://www.ilincs.org/api/ilincsR/findConcordances"
req <- (POST(apiUrl, body = list(file=signatureFile, lib="LIB_5"), encode = "form"))
output <- data.table::rbindlist(httr::content(req)$concordanceTable, use.names = TRUE, fill = TRUE)
write.csv(output, file = "ilincsUpDnConnectedSignaturesP-val.csv", row.names = FALSE)


apiUrl <- paste("http://www.ilincs.org/api/ilincsR/signatureEnrichment?sigFile=",signatureFile,"&library=LIB_5&metadata=TRUE",sep="")
req <- GET(apiUrl)
json <- httr::content(req, as = "text")
iLincsConnectedCompoundPerturbations <- fromJSON(json)$enrichment
head(iLincsConnectedCompoundPerturbations)
write.csv(iLincsConnectedCompoundPerturbations, file = "PvalConnectedCompoundPerturbations.csv", row.names = FALSE)

apiUrl <- paste("http://www.ilincs.org/api/ilincsR/signatureEnrichment?sigFile=",signatureFile,"&library=LIB_6",sep="")
req <- GET(apiUrl)
json <- httr::content(req, as = "text")
iLincsConnectedGeneticPerturbations <- fromJSON(json)$enrichment
head(iLincsConnectedGeneticPerturbations)
write.csv(iLincsConnectedGeneticPerturbations, file = "PvalConnectedGeneticPerturbations.csv", row.names = FALSE)







###########################################################################################
myDataDFFDR <- subset(myDataDF, select = -c(Significance_pvalue))
#rename column "FDR" to "Significance_pvalue"
colnames(myDataDFFDR)[colnames(myDataDFFDR)=="FDR"] <- "Significance_pvalue"

apiUrl<-"http://www.ilincs.org/api/SignatureMeta/upload"
write.table(myDataDFFDR, file='myDataDFFDR.tsv', quote=FALSE, sep='\t')
sigFile <- "myDataDFFDR.tsv"
req <- POST(apiUrl, body=list(file=upload_file("sigFile.tsv")))
signatureFile <- httr::content(req)$status$fileName[[1]]
apiUrl <- "http://www.ilincs.org/api/ilincsR/findConcordances"
req <- (POST(apiUrl, body = list(file=signatureFile, lib="LIB_5"), encode = "form"))
output <- data.table::rbindlist(httr::content(req)$concordanceTable, use.names = TRUE, fill = TRUE)
write.csv(output, file = "ilincsUpDnConnectedSignaturesFDR.csv", row.names = FALSE)


apiUrl <- paste("http://www.ilincs.org/api/ilincsR/signatureEnrichment?sigFile=",signatureFile,"&library=LIB_5&metadata=TRUE",sep="")
req <- GET(apiUrl)
json <- httr::content(req, as = "text")
iLincsConnectedCompoundPerturbations <- fromJSON(json)$enrichment
head(iLincsConnectedCompoundPerturbations)
write.csv(iLincsConnectedCompoundPerturbations, file = "FDRConnectedCompoundPerturbations.csv", row.names = FALSE)

apiUrl <- paste("http://www.ilincs.org/api/ilincsR/signatureEnrichment?sigFile=",signatureFile,"&library=LIB_6",sep="")
req <- GET(apiUrl)
json <- httr::content(req, as = "text")
iLincsConnectedGeneticPerturbations <- fromJSON(json)$enrichment
head(iLincsConnectedGeneticPerturbations)
write.csv(iLincsConnectedGeneticPerturbations, file = "FDRConnectedGeneticPerturbations.csv", row.names = FALSE)



####



# apiUrl="http://www.ilincs.org/api/ilincsR/findConcordancesSC"

# # topUpRegulatedGenes <- list(genesUp=c("HBEGF", "OSBPL6", "LYN", "APBB2", "DLL1", "CAMK2A", "TLR3", "TNK2", "NOD2", "LAMP3"))
# # topDownregulatedGenes <- list(genesDown=c("IL12A","GPER1"))


# req <- POST("http://www.ilincs.org/api/ilincsR/findConcordancesSC", body = list(mode="UpDn",metadata=TRUE,signatureProfile = c(topUpRegulatedGenes, topDownregulatedGenes)),encode = "json")

# ilincsUpDnConnectedSignatures <- data.table::rbindlist(httr::content(req)$concordanceTable, use.names = TRUE, fill = TRUE)

# #print ilincsUpDnConnectedSignatures to excel
# write.csv(ilincsUpDnConnectedSignatures, file = "ilincsUpDnConnectedSignatures.csv", row.names = FALSE)