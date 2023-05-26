import pandas as pd
import numpy as np



def getGCTFile(filePath):
    '''
    Function to open GCT file from Clue.io and get values from it
    '''
    #Import gct file with p-values
    importedGCT = pd.read_csv(filePath, sep='\t', skiprows=2)
    #keep only columns 1 and 2
    GCT = importedGCT[['pert_id', 'pert_iname', 'fdr_q_nlog10']] 
    #remove 1st row
    GCT = GCT.drop(GCT.index[0])
    #remove duplicate rows
    GCT = GCT.drop_duplicates(subset=['pert_id'])
    GCT = GCT.drop_duplicates(subset=['pert_iname'])
    GCT2 = pd.DataFrame()
    GCT2['Pert'] = [val for pair in zip(GCT['pert_id'], GCT['pert_iname']) for val in pair]
    GCT2 = GCT2.drop_duplicates(subset=['Pert'])
    return GCT2

importedGCT = pd.read_csv("/home/petear/Downloads/ClueAlgoCP.gct", sep='\t', skiprows=2)

ClueGCT = getGCTFile("/home/petear/Downloads/ClueAlgoCP.gct")

importedPertDF = pd.read_csv('/home/petear/MEGA/TormodGroup/InputData/algos.tsv', sep='\t')

#remove duplicates
ClueGCT = ClueGCT.drop_duplicates(subset=['Pert'])
pertDF = importedPertDF.drop_duplicates(subset=['Perturbagen'])

#create a new df
newDF = pd.DataFrame()
newDF['InBothClueAndSigcom'] = np.nan
newDF ['fdr_q_nlog10'] = np.nan

#change rownames in pertDF to numbers
pertDF.index = range(len(pertDF))
ClueGCT.index = range(len(ClueGCT))

#loop through all perturbagens in sigcom and add to newDF if they are in Clue 

for i in range(len(pertDF)):
    if pertDF['Perturbagen'][i] in ClueGCT['Pert'].values:
        newDF.loc[i, 'InBothClueAndSigcom'] = pertDF['Perturbagen'][i]

newDF.index = range(len(newDF))

#use importGCT to match fdr_q_nlog10  with perturbagens in newDF
for i in range(len(newDF)):
    for j in range(len(importedGCT)):
        if newDF['InBothClueAndSigcom'][i] == importedGCT['pert_id'][j]:
            newDF.loc[i, 'fdr_q_nlog10'] = importedGCT['fdr_q_nlog10'][j]

newDF["FDR2"] = np.nan

for i in range(len(newDF)):
    for j in range(len(importedGCT)):
        if newDF['InBothClueAndSigcom'][i] == importedGCT['pert_iname'][j]:
            newDF.loc[i, 'FDR2'] = importedGCT['fdr_q_nlog10'][j]


###BBB##################################################################
#####################################################################################################################################################################

def predictBBB(smiles):
    serverURL = 'http://165.194.18.43:7020/bbb_permeability?'
    param = urlencode({'smiles': smiles})
    response = requests.get(serverURL + param)
    result = response.text.strip("\n").strip('\"')
    return result


KnownSmilesDF3 = pd.read_csv('/home/petear/MEGA/TormodGroup/InputData/compoundinfo_beta.txt', sep='\t') 

perty = pd.merge(newDF, KnownSmilesDF3, left_on='InBothClueAndSigcom', right_on='cmap_name', how='left')

#remove duplicates
perty = perty.drop_duplicates(subset=['InBothClueAndSigcom'])


#iterate over column canonical_smiles and validate smiles with molvs and add to the column CannonSmiles
for index, value in perty['canonical_smiles'].items():
    #print(value)
    try:
        perty.at[index, 'CannonSmiles'] = standardize_smiles(value)
    except:
        perty.at[index, 'CannonSmiles'] = np.nan
        print("Error in smiles: ", value)
        continue

#remove Nan
perty = perty[perty['CannonSmiles'].notna()]

for index, value in perty['CannonSmiles'].items():
    perty.at[index, 'BBBPenetration'] = predictBBB(value)
    print(index, value)

#remove rows where perty BBBPenetration == 0
perty = perty[perty['BBBPenetration'] != "0"]

#save perty to excel
perty.to_excel('/home/petear/MEGA/TormodGroup/InputData/Mergedperty.xlsx')
