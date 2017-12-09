#! /usr/bin/env/Rscript
# FIle_import.R
# Abishek Murali, Nov 2017
#
# This script reads in the data set

main <- function(){
  df <- readr::read_csv("https://query.data.world/s/I9KG-0l-HO-HwXVBXuiBbDfQCFxp6A");
  
  if (nrow(tables_df) > 0) {
  
    dir.create("../data", showWarnings = FALSE)
    dir.create("../data/Raw_data", showWarnings = FALSE)
    #Remove file   
    file_name <- "../data/Raw_data/raw_data.csv"
    
    if (file.exists(file_name)) file.remove(fn)
    
    print("Writing file to data folder as raw_data.csv")
    #Writing file to folder
    write.csv(tables_df, file = file_name)
    print("Successfully created file")
    print("Printing head of the first column of the imported file")
    print(head(tables_df[1]))
    print("End of program")
  }
}
main()
