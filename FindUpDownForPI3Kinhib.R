library(readxl)  # Load the package 
setwd("/home/petear/MEGA/TormodGroup/InputData")  # Set the working directory
df <- read_excel("/home/petear/MEGA/TormodGroup/InputData/PI3K IL18 IL1B gene expression 3 doses.xlsx")

df <- as.data.frame(df)

# Assuming your dataframe is called df

# Create a new function to modify the column names
modify_column_names <- function(names) {
  # Initialize a list to keep track of the counts
  counts <- list()
  # Initialize a vector to store the new names
  new_names <- character(length(names))
  
  # Loop through each name
  for (i in seq_along(names)) {
    # Extract the first two characters
    prefix <- substr(names[i], 1, 2)
    # Check if the prefix is numeric and process
    if (grepl("^[0-9]{2}", prefix)) {
      # Increment the count for this prefix
      if (!is.null(counts[[prefix]])) {
        counts[[prefix]] <- counts[[prefix]] + 1
      } else {
        counts[[prefix]] <- 1
      }
      # Assign the new name based on the count
      if (counts[[prefix]] == 1) {
        new_names[i] <- paste0(prefix, "_1")
      } else if (counts[[prefix]] == 2) {
        new_names[i] <- paste0(prefix, "_10")
      } else if (counts[[prefix]] == 3) {
        new_names[i] <- paste0(prefix, "_100")
      } else {
        new_names[i] <- names[i]  # Keep original if more than three occurrences
      }
    } else {
      new_names[i] <- names[i]  # Keep original if not starting with two digits
    }
  }
  return(new_names)
}

# Apply the function to your dataframe's column names
colnames(df) <- modify_column_names(colnames(df))


cols_100 <- grep("_100$", names(df), value = TRUE)

# Initialize vectors
IL18_high <- c()
IL18_low <- c()
IL1B_high <- c()
IL1B_low <- c()

# Loop through the identified columns
for (col in cols_100) {
    # For the first row (IL18)
    cat("col: ", col, " value: ", df[1, col], "\n")
    if (df[1, col] > 1.2) {
        IL18_high <- c(IL18_high, col)
    } else if (df[1, col] < 0.9) {
        IL18_low <- c(IL18_low, col)
    }
    
    # For the second row (IL1B)
    if (df[2, col] > 1.2) {
        IL1B_high <- c(IL1B_high, col)
    } else if (df[2, col] < 0.9) {
        IL1B_low <- c(IL1B_low, col)
    }
}

# Remove '_100' from the names in each vector
IL18_high <- sub("_100$", "", IL18_high)
IL18_low <- sub("_100$", "", IL18_low)
IL1B_high <- sub("_100$", "", IL1B_high)
IL1B_low <- sub("_100$", "", IL1B_low)

codelist <- read_excel("/home/petear/MEGA/TormodGroup/InputData/Kodeliste substanser 100-50.xlsx")
codelist <- as.data.frame(codelist)

#match the gene names with the codelist
IL18_high_df <- codelist[match(IL18_high, codelist$ID_kode),]
IL18_low_df <- codelist[match(IL18_low, codelist$ID_kode),]
IL1B_high_df <- codelist[match(IL1B_high, codelist$ID_kode),]
IL1B_low_df <- codelist[match(IL1B_low, codelist$ID_kode),]

#Remove NA from the dataframes column Navn
IL18_high_df <- IL18_high_df[!is.na(IL18_high_df$Navn),]
IL18_low_df <- IL18_low_df[!is.na(IL18_low_df$Navn),]
IL1B_high_df <- IL1B_high_df[!is.na(IL1B_high_df$Navn),]
IL1B_low_df <- IL1B_low_df[!is.na(IL1B_low_df$Navn),]

############################################
#collecting PNG of the chemical structures
############################################
library(httr)
library(jpeg)


# Function to download chemical structure as PNG
download_chemical_structure <- function(chemical_names, folder_name) {
  # Create a new folder for the vector
  dir.create(file.path("/home/petear/", folder_name))
  
  for (chemical_name in chemical_names) {
    # Sanitize chemical name for file path
    safe_chemical_name <- gsub("[[:punct:]]", "", gsub(" ", "_", chemical_name))
    file_path <- file.path("/home/petear/", folder_name, paste0(safe_chemical_name, ".png"))
    
    # Build the API request URL for PubChem
    url <- paste0("https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/name/", URLencode(chemical_name), "/PNG")
    
    # Make the API request and save the image if successful
    response <- GET(url)
    if (status_code(response) == 200) {
      writeBin(content(response, "raw"), file_path)
      cat("Downloaded image for", chemical_name, "to", file_path, "\n")
    } else {
      cat("Failed to download image for", chemical_name, "\n")
    }
  }
}

# Download images for each vector
download_chemical_structure(IL18_high_df$Navn, "IL18_high")
download_chemical_structure(IL18_low_df$Navn, "IL18_low")
download_chemical_structure(IL1B_high_df$Navn, "IL1B_high")
download_chemical_structure(IL1B_low_df$Navn, "IL1B_low")

############################################
#Finding IC50 values for the chemical structures in relation to subunuites of PI3K
############################################
IC50_file <- read_excel("/home/petear/MEGA/TormodGroup/InputData/IC50.xlsx")
IC50_file <- as.data.frame(IC50_file)

df_IL18_high <- IC50_file[IC50_file$candidate %in% IL18_high, ]
df_IL18_low <- IC50_file[IC50_file$candidate %in% IL18_low, ]
df_IL1B_high <- IC50_file[IC50_file$candidate %in% IL1B_high, ]
df_IL1B_low <- IC50_file[IC50_file$candidate %in% IL1B_low, ]

list_of_dfs <- list(IL18_high = df_IL18_high, IL18_low = df_IL18_low, IL1B_high = df_IL1B_high, IL1B_low = df_IL1B_low)

library(openxlsx)

wb <- createWorkbook()

for (sheet_name in names(list_of_dfs)) {
  addWorksheet(wb, sheet_name)
  writeData(wb, sheet_name, list_of_dfs[[sheet_name]])
}

# Save the workbook to a file
saveWorkbook(wb, "IC50_sorted_to_IL1B_or_IL18_High_and_Low.xlsx", overwrite = TRUE)
