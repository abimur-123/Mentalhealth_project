#! /usr/bin/env/Rscript
# FIle_import.R
# Abishek Murali, Nov 2017
#
# This script reads in the data set

main <- function(){
  tables_df <- read.csv("https://raw.githubusercontent.com/PLBMR/mentalHealthDataAnalysis/master/osmiMentalHealthInTech/data/raw/osmi-survey-2016_data.csv"
                        ,sep = ","
                        ,stringsAsFactors = FALSE)
  
  if (nrow(tables_df) > 0) {
    #Remove file
    file_name <- "../data/raw_data.csv"
    if (file.exists(file_name)) file.remove(fn)
    
    print("Writing file to data folder as raw_data.csv")
    #Writing file to folder
    write.csv(tables_df, file = "../data/raw_data.csv")
    print("Successfully created file")
    print("Printing head of the first column of the imported file")
    print(head(tables_df[1]))
    print("End of program")
  }
}
main()
