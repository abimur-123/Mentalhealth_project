#!/usr/bin/env python

# coding: utf-8

# # Data Import

# Author - Abishek Murali
# Written - December 2017
# This script take reads data from a URL and writes it into a csv file in the system
# 1. URL to retrieve data from and
# 2. Destination of raw data file

import pandas as pd
import os
import sys

def import_file(URL, output_file):
    '''
    This function imports data from a specified URL and stores it as a CSV file

    Args: URL - URL to obtain data from
          output_file - location to save raw data
    '''
    df = pd.read_csv(URL) #URL obtained from https://data.world/kittybot/osmi-mental-health-tech-2016

    fn = "../" + output_file # location of raw data file
    di = fn.rsplit('/',1)[0]

    if(df.shape[0] > 0):
        if not os.path.exists(di):#checks if data directory exists, creates one otherwise
            os.makedirs(di)
        # os.remove(fn) if os.path.exists(fn) else None # Remove file if already exists. Previous files get overwritten by newer version

    print("Writing file to data folder as raw_data.csv")
    df.to_csv(fn)
    print("Successfully created file")

if __name__ == '__main__':
    URL = sys.argv[1] if len(sys.argv) > 1 else 'https://query.data.world/s/S5I_aMQV9aJMq2_o3qMmrvOMru1Sss'
    output_file = sys.argv[2] if len(sys.argv) > 2 else 'data/raw_data.csv'
    import_file(URL, output_file)
    print("End of program")
