#!/usr/bin/env python

# coding: utf-8

# # Data cleansing

# Author - Abishek Murali
# Written - December 2017
# This script reads data from the raw data file, cleanses the data, creates a codebook and then
# writes the codebook and cleansed data into a csv
# 1. Raw data file to retrieve data and
# 2. Destination of codebook file
# 3. Destination of cleansed data file

import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt
import os
import sys


def cleanse_data(raw_file,codebook_dest,cleansed_dest,str_summ_dest,num_summ_dest):
    '''
    This function cleans a raw file and saves it in a specified location.
    It also generates summary of string and numeric values.

    Args: raw_file - file with raw data
          codebook_dest - location of where codebook needs to be stoed
          cleansed_dest - destination specifying where the cleansed data needs to be stored
          str_summ_dest - destination for string summaries
          num_summ_dest - destination for numeric summaries
    '''

    # # Prepare codebook
    fn = raw_file
    data = pd.read_csv(fn, encoding='latin-1')
    df = data.copy()
    df.columns = ['C'+ str(i + 1) for i in range(len(df.columns))] #encode column names with prefix 'C' followed by number
    d = zip(data.columns,df.columns)
    pd.options.display.max_rows = 65
    codebook = pd.DataFrame([dict(d)]).T.reset_index().rename(columns = {"index":"Old_names",0:"New_names"})

    cb_fn = codebook_dest
    di = cb_fn.rsplit('/',1)[0]
    if not os.path.exists(di):#checks if data directory exists, creates one otherwise
        os.makedirs(di)
    # os.remove(cb_fn) if os.path.exists(cb_fn) else None # Remove file if already exists. Previous files get overwritten by newer version

    codebook.sort_values(by = ['New_names']).to_csv(cb_fn,index=False)

    df.columns = ['C'+ str(i + 1) for i in range(len(data.columns))]
    cb = pd.read_csv(cb_fn, encoding='latin-1')


    # # Cleansing data

    # ### Classifying gender into 3 groups for ease of analysis - Male, Female and NB

    #df.C58.unique()

    # clean the genders by grouping the genders into 3 categories: Female, Male, Genderqueer/Other
    # sourced from https://www.kaggle.com/jchen2186/data-visualization-with-python-seaborn

    df['C58'] = df['C58'].replace([
        'male', 'Male ', 'M', 'm', 'man', 'Cis male',
        'Male.', 'Male (cis)', 'Man', 'Sex is male',
        'cis male', 'Malr', 'Dude', "I'm a man why didn't you make this a drop down question. You should of asked sex? And I would of answered yes please. Seriously how much text can this take? ",
        'mail', 'M|', 'male ', 'Cis Male', 'Male (trans, FtM)',
        'cisdude', 'cis man', 'MALE'], 'Male')
    df['C58'] = df['C58'].replace([
        'female', 'I identify as female.', 'female ',
        'Female assigned at birth ', 'F', 'Woman', 'fm', 'f',
        'Cis female', 'Transitioned, M2F', 'Female or Multi-Gender Femme',
        'Female ', 'woman', 'female/woman', 'Cisgender Female',
        'mtf', 'fem', 'Female (props for making this a freeform field, though)',
        ' Female', 'Cis-woman', 'AFAB', 'Transgender woman',
        'Cis female '], 'Female')
    df['C58'] = df['C58'].replace([
        'Bigender', 'non-binary,', 'Genderfluid (born female)',
        'Other/Transfeminine', 'Androgynous', 'male 9:1 female, roughly',
        'nb masculine', 'genderqueer', 'Human', 'Genderfluid',
        'Enby', 'genderqueer woman', 'Queer', 'Agender', 'Fluid',
        'Genderflux demi-girl', 'female-bodied; no feelings about gender',
        'non-binary', 'Male/genderqueer', 'Nonbinary', 'Other', 'none of your business',
        'Unicorn', 'human', 'Genderqueer'], 'Non-binary')

    # replace the one null with Male, the mode gender, so we don't have to drop the row
    df['C58'] = df['C58'].replace(np.NaN, 'Male')

    # ### Removing self employed professionals from analysis for tech companies

    #Removing self employed professionals for the sake of this analysis
    df = df.query('C2 == 0')

    a = df.applymap(np.isreal).all()

    # df.iloc[:,-np.where(a)[0]].head()
    # # Summary tables

    str_fn = str_summ_dest
    di = str_fn.rsplit('/',1)[0]
    if not os.path.exists(di):#checks if data directory exists, creates one otherwise
        os.makedirs(di)

    string_sum = df.describe(include = [np.object])
    string_sum.to_csv(str_fn)

    num_fn = num_summ_dest
    di = num_fn.rsplit('/',1)[0]
    if not os.path.exists(di):#checks if data directory exists, creates one otherwise
        os.makedirs(di)

    num_sum = df.describe(include = [np.number])
    num_sum.to_csv(num_fn)

    # # Write cleansed data to file
    clean_fn = cleansed_dest
    di = clean_fn.rsplit('/',1)[0]
    if not os.path.exists(di):#checks if data directory exists, creates one otherwise
        os.makedirs(di)
    df.to_csv(clean_fn)

if __name__ == '__main__':
    raw_file = sys.argv[1] if len(sys.argv) > 1 else 'data/raw_data.csv'
    codebook_dest = sys.argv[2] if len(sys.argv) > 2 else 'docs/codebook.csv'
    cleansed_dest = sys.argv[3] if len(sys.argv) > 3 else 'data/cleansed_data.csv'
    str_summ_dest = sys.argv[4] if len(sys.argv) > 4 else 'results/Summary_strings.csv'
    num_summ_dest = sys.argv[5] if len(sys.argv) > 5 else 'results/Summary_numeric.csv'
    cleanse_data(raw_file, codebook_dest,cleansed_dest,str_summ_dest,num_summ_dest)
    print("End of program")
