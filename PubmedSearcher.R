library(easyPubMed)

#read xlsx file
library(readxl)

excel <- "/home/petear/AlgoSiScreener.xlsx"
sheetNames <- excel_sheets(excel)
excel_data <- lapply(sheetNames, function(sheet) read_excel(excel, sheet))

#To use sheet 4 as data frame
df <- as.data.frame(excel_data[[4]])

#remove values below 2 for column 3
df <- df[df$"logFC" >= 2,]

#create a vector of gene names in column 9
genes <- df$"geneID"

#genes <- c("BRCA1", "BRCA2", "TP53")

search_terms <- paste0("(", paste(genes, collapse = "[Title/Abstract] OR "), "[Title/Abstract]) AND (Alzheimer's[Title/Abstract] OR Parkinson's[Title/Abstract])")

pubmed_results <- get_pubmed_ids(search_terms)


pmlist <- list()
empPMlist <- list()

for (gene in genes) {
  search_terms <- paste0("(", gene, "[Title/Abstract]) AND (Alzheimer's[Title/Abstract] OR Parkinson's[Title/Abstract])")
  pubmed_results <- get_pubmed_ids(search_terms)
  #new list where gene is the name of the list
 if (length(pubmed_results$IdList) == 0) {
   empPMlist[[gene]] <- "No results"
 } else {
   pmlist[[gene]] <- pubmed_results$IdList
 }
}


#
df <- ldply(pmlist, data.frame)



# pmlist_concat <- lapply(pmlist, function(x) paste(x, collapse = "/"))

# df <- data.frame(pmlist_concat)
# dfT <- t(df)

# write.csv(df, file = "pmlist.csv")