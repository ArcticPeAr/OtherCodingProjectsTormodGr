 
import sys
import requests
from urllib.parse import urlencode
import pandas as pd
import pubchempy as pcp
from chembl_webresource_client.new_client import new_client
import chemspipy 
import numpy as np
from molvs import standardize_smiles
#for timing and connection is up
import time 
import socket
import urllib.error

max_retries = 10  # Maximum number of retry attempts
retry_delay = 10  # Delay between retries in seconds

#############################################################################
#Functions
#############################################################################
def predictBBB(smiles):
    '''
    Function to predict BBB penetration from smiles by LightBBB
    '''
    serverURL = 'http://165.194.18.43:7020/bbb_permeability?'
    param = urlencode({'smiles': smiles})
    response = requests.get(serverURL + param)
    result = response.text.strip("\n").strip('\"')
    return result

def getGCTFile(filePath):
    '''
    Function to open GCT file from Clue.io and get values from it
    '''
    #Import gct file with p-values
    importedGCT = pd.read_csv(filePath, sep='\t', skiprows=2)
    #keep only columns 1 and 2
    GCT = importedGCT[['pert_id', 'pert_iname']] 
    #remove 1st row
    GCT = GCT.drop(GCT.index[0])
    #remove duplicate rows
    GCT = GCT.drop_duplicates(subset=['pert_id'])
    GCT = GCT.drop_duplicates(subset=['pert_iname'])
    GCT2 = pd.DataFrame()
    GCT2['Pert'] = [val for pair in zip(GCT['pert_id'], GCT['pert_iname']) for val in pair]
    GCT2 = GCT2.drop_duplicates(subset=['Pert'])
    return GCT2

     
def check_network_connection():
    '''
    Function to check if network is connected
    '''
    while True:
        try:
            # Attempt to connect to a reliable host
            socket.create_connection(("google.com", 80))
            print("Network is connected.")
            break
        except OSError:
            # Network is unreachable
            print("Network is unreachable. Retrying in 5 seconds...")
            time.sleep(5)

def pubchemSmiles(pert):
    '''
    Function to get smiles from pubchempy and add to dataframe in new column
    '''
    try:
        compound = pcp.get_compounds(pert, 'name')
        smiles = compound[0].canonical_smiles
        return smiles
    except:
        return np.nan
    
###########################

#Import xlsx file with perturbagens to find BBB penetration for
pertDF = pd.read_excel('/home/petear/MEGA/TormodGroup/InputData/BBBFirstGroup.xlsx')

#importedPertDF = pd.read_csv('/home/petear/MEGA/TormodGroup/InputData/algos.tsv', sep='\t')
#pertDF = importedPertDF[['Name', 'Perturbagen']]
#pertDF = pertDF.rename(columns={'p-value Bonferroni (up)': 'Smiles'})


# PertList = pertDF['Perturbagen'].tolist()

# #Import txt file with smiles with pandas containing some but not all smiles
# KnownSmilesDF = pd.read_csv('/home/petear/MEGA/TormodGroup/InputData/SmilesPerts.txt', sep='\t')
# KnownSmilesDF2 = pd.read_excel('/home/petear/MEGA/TormodGroup/InputData/SmilesPerts2.xlsx')
############################################################################
#3 will be used because it looks the most right!
############################################################################

KnownSmilesDF3 = pd.read_csv('/home/petear/MEGA/TormodGroup/InputData/compoundinfo_beta.txt', sep='\t')  
#####THESE CREATE DIFFERENT SMILES FOR SAME COMPOUND!


# pertDF1 = pd.merge(pertDF, KnownSmilesDF, left_on='Perturbagen', right_on='SM_Center_Canonical_ID', how='left')
# naCount1 = pertDF1['SM_Center_Canonical_ID'].isna().sum()





# pertDF2 = pd.merge(pertDF, KnownSmilesDF2, left_on='Perturbagen', right_on='pert_id', how='left')
# naCount2 = pertDF2['pert_id'].isna().sum()
# #print column names 
# print(pertDF2.columns)

# #remove column "predicted","Known", Prediction Probability and "Name_Y" from pertDF2
# pertDF2 = pertDF2.drop(columns=['Predicted','Known', 'Prediction Probability', 'Name_y'])




pertDF3 = pd.merge(pertDF, KnownSmilesDF3, left_on='Perts', right_on='cmap_name', how='left')
naCount3 = pertDF3['cmap_name'].isna().sum()

#remove column 'target', 'moa', 'inchi_key', 'compound_aliases
pertDF3 = pertDF3.drop(columns=['target', 'moa', 'inchi_key', 'compound_aliases'])

#remove duplicate rows
pertDF3 = pertDF3.drop_duplicates(subset=['Perts'])

#add empty column for smiles
pertDF3['CannonSmiles'] = np.nan




#iterate over column canonical_smiles and validate smiles with molvs and add to the column CannonSmiles
for index, value in pertDF3['canonical_smiles'].items():
    #print(value)
    try:
        pertDF3.at[index, 'CannonSmiles'] = standardize_smiles(value)
    except:
        pertDF3.at[index, 'CannonSmiles'] = np.nan
        print("Error in smiles: ", value)
        continue
    
#remove rows with NaN values in CannonSmiles column
pertDF3 = pertDF3[pertDF3['CannonSmiles'].notna()]
#remove first row
pertDF3 = pertDF3.drop(pertDF3.index[0])
   ############
pertDF3['BBBPenetration'] = np.nan

#save pertDF3 to excel
pertDF3.to_excel('/home/petear/MEGA/TormodGroup/InputData/BBB_Predictions.xlsx')


#use predictBBB function to predict BBB penetration
for index, value in pertDF3['canonical_smiles'].items():
    pertDF3.at[index, 'BBBPenetration'] = predictBBB(value)
    print(index, value)

#set BBBPenetration column to numeric
pertDF3['BBBPenetration'] = pd.to_numeric(pertDF3['BBBPenetration'])

#export to excel
pertDF3.to_excel('/home/petear/MEGA/TormodGroup/InputData/BBB_Predictions.xlsx')


#############################################################################
#Clue
#############################################################################

ClueGCT = getGCTFile("/home/petear/Downloads/ClueAlgoCP.gct")
ClueGCTMerged = pd.merge(ClueGCT, KnownSmilesDF3, left_on='Pert', right_on='cmap_name', how='left')

ClueGCT['CannonSmiles'] = np.nan

#iterate over column canonical_smiles and validate smiles with molvs and add to the column CannonSmiles
for index, value in ClueGCTMerged['canonical_smiles'].items():
    #print(value)
    try:
        ClueGCTMerged.at[index, 'CannonSmiles'] = standardize_smiles(value)
    except:
        ClueGCTMerged.at[index, 'CannonSmiles'] = np.nan
        print("Error in smiles: ", value)
        continue


#split ClueGCTMerged into two dataframes, one with smiles and one without
ClueGCTMergedSmiles = ClueGCTMerged[ClueGCTMerged['canonical_smiles'].notna()]
ClueGCTMergedNoSmiles = ClueGCTMerged[ClueGCTMerged['canonical_smiles'].isna()]
#save to excel
ClueGCTMergedSmiles.to_excel('/home/petear/MEGA/TormodGroup/InputData/ClueGCTMergedSmiles.xlsx')

#############################################################################
#For fast BBB prediction
#############################################################################
ClueGCTMerged['BBBPenetration'] = np.nan
ClueGCTMerged['BBBPenetrationFromNonCannon'] = np.nan

for index, value in ClueGCTMerged['canonical_smiles'].items():
    ClueGCTMerged.at[index, 'BBBPenetrationFromNonCannon'] = predictBBB(value)
    print(index, value)

#remove rows after row 200
ClueGCTMerged = ClueGCTMerged.iloc[0:200]
ClueGCTMerged.to_excel('/home/petear/MEGA/TormodGroup/InputData/ClueBBB.xlsx')

#create empty dataframe for smiles found from pubchempy
ClueGCTPubchemSmiles = pd.DataFrame(columns=['Pert', 'canonical_smiles'])

def make_network_request():
    for index, value in ClueGCTMergedNoSmiles['Pert'].items():
        check_network_connection()  # Check network connection before each iteration
        results = pcp.get_compounds(value, 'name')
        print(value)
        if len(results) > 0:
            compound = results[0]
            smiles = compound.canonical_smiles
            print(smiles)
            ClueGCTMergedNoSmiles.at[index, 'canonical_smiles'] = smiles
            #remove the row from ClueGCTMergedNoSmiles and add it to ClueGCTPubchemSmiles
            ClueGCTPubchemSmiles = ClueGCTPubchemSmiles.append(ClueGCTMergedNoSmiles.loc[index])
            ClueGCTMergedNoSmiles = ClueGCTMergedNoSmiles.drop(index)
            
        time.sleep(0.5)  # Pause for 0.5 seconds between iterations

ClueGCTMergedNoSmiles.to_excel('/home/petear/MEGA/TormodGroup/InputData/ClueGCTMergedNoSmiles.xlsx')

# # Split the DataFrame based on NaN values in 'Column1'
# value_to_split = np.nan

# Filter rows with NaN values in 'Column1'
# df1 = pertDF[pertDF['SM_SMILES_Batch'].isna()]

# df2 = pertDF[pertDF['SM_SMILES_Batch'].notna()]


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

def make_network_request():
    # Your network request code goes here
    # For example, using the pubchempy library:
    # results = pubchempy.get_compounds(...)
    # return results

retry_count = 0
while retry_count < max_retries:
    try:
        response = make_network_request()
        # Process the response or do whatever you need to do
        break  # If the request is successful, exit the loop
    except (urllib.error.URLError, ConnectionError):
        print("Network error occurred. Retrying in {} seconds...".format(retry_delay))
        retry_count += 1
        time.sleep(retry_delay)

if retry_count == max_retries:
    print("Max retry attempts reached. Network is still unreachable.")
else:
    print("Network request successful!")

# loop over rows 

# #####################################
    # CHEMBL

# if res:
#     compound_id = res[0]['chembl_id']
#     compound = new_client.molecule.filter(chembl_id=compound_id).only('molecule_structures')
#     smiles = compound[0]['molecule_structures']['canonical_smiles']
#     print(smiles)
# else:
#     print("Compound not found.")


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





