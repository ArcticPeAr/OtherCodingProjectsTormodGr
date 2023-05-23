 
import sys
import requests
from urllib.parse import urlencode
import pandas as pd
import pubchempy as pcp
from chembl_webresource_client.new_client import new_client
import chemspipy 
import numpy as np

def predictBBB(smiles):
    serverURL = 'http://165.194.18.43:7020/bbb_permeability?'
    param = urlencode({'smiles': smiles})
    response = requests.get(serverURL + param)
    result = response.text.strip("\n").strip('\"')
    return result


#Import tsv file with perturbagens
importedPertDF = pd.read_csv('/home/petear/MEGA/TormodGroup/InputData/metadata.tsv', sep='\t')
#keeping extra columns for substituting later with smiles 
pertDF = importedPertDF[['Name', 'Perturbagen']]
# pertDF = pertDF.rename(columns={'p-value Bonferroni (up)': 'Smiles'})


# PertList = pertDF['Perturbagen'].tolist()

#Import txt file with smiles with pandas containing some but not all smiles
KnownSmilesDF = pd.read_csv('/home/petear/MEGA/TormodGroup/InputData/SmilesPerts.txt', sep='\t')
KnownSmilesDF2 = pd.read_excel('/home/petear/MEGA/TormodGroup/InputData/SmilesPerts2.xlsx')

#####THESE CREATE DIFFERENT SMILES FOR SAME COMPOUND!

pertDF = pd.merge(pertDF, KnownSmilesDF, left_on='Perturbagen', right_on='SM_Center_Canonical_ID', how='left')


# Split the DataFrame based on NaN values in 'Column1'
value_to_split = np.nan

# Filter rows with NaN values in 'Column1'
df1 = pertDF[pertDF['SM_SMILES_Batch'].isna()]
pertDF2 = pd.merge(pertDF, KnownSmilesDF2, left_on='Perturbagen', right_on='pert_id', how='left')


df2 = pertDF[pertDF['SM_SMILES_Batch'].notna()]


#below works better, strange error message from pandas when using above
# if pertDF['SM_SMILES_Batch'].isna().sum() > 0:
    
#     for value in df1['Perturbagen']:
#         results = pcp.get_compounds(value, 'name')
#         if len(results) > 0:
#             compound = results[0]
#             smiles = compound.canonical_smiles
#             #add smiles to df in the correct row and column SM_SMILES_Batch
#             df1.loc[df1['Perturbagen'] == value, 'SM_SMILES_Batch'] = smiles
#             print(smiles)
#         else:
#             print("Compound not found.")

 # Loop over values in 'Perturbagen' column using pubchempy
for index, value in df1['Perturbagen'].items():
    results = pcp.get_compounds(value, 'name')
    if len(results) > 0:
        compound = results[0]
        smiles = compound.canonical_smiles
        df1.at[index, 'SM_SMILES_Batch'] = smiles
 
#transfer rows not NaN from df1 to df2 
df2 = pd.concat([df2, df1[df1['SM_SMILES_Batch'].notna()]], ignore_index=True)
#drop rows that are not NaN from df1 SM_SMILES_Batch
df1 = df1[df1['SM_SMILES_Batch'].isna()]


    
# #####################################
    # CHEMBL

if res:
    compound_id = res[0]['chembl_id']
    compound = new_client.molecule.filter(chembl_id=compound_id).only('molecule_structures')
    smiles = compound[0]['molecule_structures']['canonical_smiles']
    print(smiles)
else:
    print("Compound not found.")


################################################
# ChemSpider
# #Reard API key from file
# with open('/home/petear/MEGA/TormodGroup/InputData/ChemSpiderAPIKey', 'r') as file:
#     APIKey = file.read().replace('\n', '')


# cs = ChemSpider(APIKey)

# # Loop over values in 'Perturbagen' column using chemspipy
# for index, value in df1['Perturbagen'].items():
#     res = cs.search(value)
#     if res:
#         smiles = res[0].smiles
#         df1.at[index, 'SM_SMILES_Batch'] = smiles
#         print(smiles)
#     else:
#         print("Compound not found.")



# def search_smiles(compound_name):
#     # Perform the search
#     results = cs.search(compound_name)
#     # Retrieve the first result (if available)
#     if len(results) > 0:
#         compound = results[0]
#         return compound.smiles
#     return None





############
smiles = r"Oc1ccccc1NC(=O)CCCCCCC(=O)N\N=C\c1ccc(s1)[N+]([O-])=O"
pred = predictBBB(smiles)

print(predictBBB(smiles))
CC[C@H](CO)Nc1nc(NCc2ccccc2)c3ncn(C(C)C)c3n1
CC[C@H](CO)Nc1nc(NCc2ccccc2)c3ncn(C(C)C)c3n1
