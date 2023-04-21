 
#import a csv file with only one column of gene names and tranlate them to gene ids

import csv
from biomart import BiomartServer

#read in the gene names from the first column in the |genes4Translate.csv| file
with open('/home/petear/MEGA/TormodGroup/genes4Translate.csv', 'r') as f:
    reader = csv.reader(f)
    genes = list(reader)
    #make genes into a list of strings
    genes = [item for sublist in genes for item in sublist]

#remove trailing spaces for every string in list
genes = [x.strip() for x in genes]


#connect to biomart and get the entrezgene_id, hgnc_symbol and ensembl_gene_id
#From https://autobencoder.com/2021-10-03-gene-conversion/
def getEnsemblMappings():
    '''Connects to Ensembl Biomart and retrieves the mapping between Entrez Gene IDs and HGNC symbols. Returns a dict with the mapping.'''
    # Set up connection to server                                               
    server = BiomartServer("http://www.ensembl.org/biomart/martservice")
    mart = server.datasets["hsapiens_gene_ensembl"]                            
    # List the types of data we want                                            
    attributes = ["entrezgene_id", "hgnc_symbol", "ensembl_gene_id"]
    # Get the mapping between the attributes                                    
    response = mart.search({'attributes': attributes})                          
    data = response.raw.data.decode('ascii')
    entrezID2Name = {}
    entrezID2Ensembl = {}
    name2entrezID = {}
    # Store the data in a dict                                                  
    for line in data.splitlines():
        line = line.split('\t')
        # The entries are in the same order as in the `attributes` variable
        entrezgene_id = line[0]
        hgnc_symbol = line[1]
        # Some of these keys may be an empty string. If you want, you can 
        # avoid having a '' key in your dict by ensuring the 
        # transcript/gene/peptide ids have a nonzero length before
        # adding them to the dict
        entrezID2Name[entrezgene_id] = hgnc_symbol
    for line in data.splitlines():
        line = line.split('\t')
        # The entries are in the same order as in the `attributes` variable
        entrezgene_id = line[0]
        ensembl_gene_id = line[2]
        # Some of these keys may be an empty string. If you want, you can 
        # avoid having a '' key in your dict by ensuring the 
        # transcript/gene/peptide ids have a nonzero length before
        # adding them to the dict
        entrezID2Ensembl[entrezgene_id] = ensembl_gene_id
    for line in data.splitlines():
        line = line.split('\t')
        # The entries are in the same order as in the `attributes` variable
        entrezgene_id = line[0]
        hgnc_symbol = line[1]
        # Some of these keys may be an empty string. If you want, you can 
        # avoid having a '' key in your dict by ensuring the 
        # transcript/gene/peptide ids have a nonzero length before
        # adding them to the dict
        name2entrezID[hgnc_symbol] = entrezgene_id
    return entrezID2Name, entrezID2Ensembl, name2entrezID

#run the function
entrezID2Name, entrezID2Ensembl, name2entrezID = getEnsemblMappings()

#translate the gene names in "genes" to entrezgene_ids using the name2entrezID dict
entrezIDs = [name2entrezID.get(x) for x in genes]

#write the entrezgene_ids as a single column to a csv file
with open('/home/petear/MEGA/TormodGroup/entrezIDs.csv', 'w') as f:
    writer = csv.writer(f)
    for item in entrezIDs:
        writer.writerow([item])


#########################################################################################
#add p value and fold change to the entrezgene_ids
#read in the p values and fold changes from TippyTopGeneDF_ALL.feather
import pandas as pd
import feather


#read in the feather file
df = feather.read_dataframe('/home/petear/MEGA/TormodGroup/InputData/TippyTopGeneDF_ALL.feather')

#read ONLY the first column of the a csv file as a list
with open('/home/petear/MEGA/TormodGroup/entrezIDs.csv', 'r') as f:
    reader = csv.reader(f)
    entrezIDs = [row[0] for row in reader]
    

#only keep rows in df where the entrezgene_id is in the entrezIDs list
df = df[df['entrezgene_id'].isin(ENTREZID)]

