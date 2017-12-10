#!/usr/bin/env python

# coding: utf-8

# # Data EDA
# Author - Abishek Murali
# Written - December 2017
# This script take cleansed data from a csv file and writes figures to a results folder
# Parameters required -
# 1. Cleansed csv file
# 2. Codebook csv file
# 3. Destination folder for figures

import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt
import os
import sys

#%matplotlib inline
sns.set_style("dark")

def plotBar(var, data,title,filename,directory):
    '''
    This function takes in a pandas data frame and a column and prints/saves count of instances in a categorical variable
    Users can specify where this file needs to be saved

    Args: var - variable to plot
          data - input data
          title - Graph title
          filename - File name for plot
          directory - Folder location for plot
    '''
    bar_df = data[[var]].groupby([var]).size().reset_index(name='count')
    bar_plot = sns.barplot(x = var,y = "count",data = bar_df)
    plt.ylabel("count")
    plt.xlabel(" ")
    plt.title("{0}".format(title))
    fig = bar_plot.get_figure()

    if(filename is not None):
        di = "../" + directory
        if not os.path.exists(di):#checks if data directory exists, creates one otherwise
            os.makedirs(di)
        fig.savefig(di + "/" + filename + ".png")

def plot_data(cleansed_file,codebook_src,results_dest):
    '''
    This function takes in a cleansed file,the codebook and saves images of bar plots to the specified folder

    Args: cleansed_file - file with cleansed data
          codebook_src - variable codebook
         results_dest - destination specifying where the images need to be stored
    '''
    # Read cleansed data and codebook
    clean_fn = "../" + cleansed_file
    di = clean_fn.rsplit('/',1)[0]
    if not os.path.exists(di):#checks if data directory exists, creates one otherwise
        os.makedirs(di)
    df = pd.read_csv(clean_fn, encoding='latin-1')

    code_fn = "../" + codebook_src
    di = code_fn.rsplit('/',1)[0]
    if not os.path.exists(di): #checks if data directory exists, creates one otherwise
        os.makedirs(di)
    cb = pd.read_csv(code_fn, encoding='latin-1')

    a = cb.loc[cb['Old_names'] == 'Have you been diagnosed with a mental health condition by a medical professional?','New_names']
    plotBar(a.values[0],df,"Have you been diagnosed for mental disorder by a professional?","diag_prof",results_dest)

    b = cb.loc[cb['Old_names'] == 'Do you currently have a mental health disorder?','New_names']
    plotBar(b.values[0],df,"Do you have mental disorder?","have_disorder",results_dest)

    c = cb.loc[cb['Old_names'] == 'What is your gender?','New_names']
    plotBar(c.values[0],df,"Gender breakdown","gender_breakdown",results_dest)

    d = cb.loc[cb['Old_names'] == 'Does your employer provide mental health benefits as part of healthcare coverage?','New_names']
    plotBar(d.values[0],df,"Does your employee provide Mental health benefits?","employee_benefits",results_dest)

    e = cb.loc[cb['Old_names'] == 'Would you feel comfortable discussing a mental health disorder with your coworkers?','New_names']
    plotBar(e.values[0],df,"Comfortable with discussing about mental health condition with coworkers?","coworker_comfort",results_dest)

    f = cb.loc[cb['Old_names'] == 'Do you feel that your employer takes mental health as seriously as physical health?','New_names']
    plotBar(f.values[0],df,"Do you feel that your employer takes mental health as seriously as physical health?","mental_physical",results_dest)

    g = cb.loc[cb['Old_names'] == 'Does your employer offer resources to learn more about mental health concerns and options for seeking help?','New_names']
    plotBar(g.values[0],df,"Does employee offer resources to learn about mental health?","emp_resources",results_dest)

    h = cb.loc[cb['Old_names'] == 'Do you think that discussing a mental health disorder with your employer would have negative consequences?','New_names']
    plotBar(h.values[0],df,"Do you think discussing mental health would have a negative consequence?","disc_negative",results_dest)

    i = cb.loc[cb['Old_names'] == 'Is your anonymity protected if you choose to take advantage of mental health or substance abuse treatment resources provided by your employer?','New_names']
    plotBar(i.values[0],df,"Anonymity when one opens up about mental health?","anonymity",results_dest)

if __name__ == '__main__':
    cleansed_file = sys.argv[1] if len(sys.argv) > 1 else 'data/cleansed_data.csv'
    codebook_src = sys.argv[2] if len(sys.argv) > 2 else 'docs/codebook.csv'
    results_dest = sys.argv[3] if len(sys.argv) > 3 else 'results/figures'
    plot_data(cleansed_file,codebook_src,results_dest)
    print("End of program")
