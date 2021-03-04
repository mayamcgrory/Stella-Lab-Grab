# Stella-Lab-Grab
Grab Data Analysis in Matlab

There are currently two parts to this program that analyzes data from a Flourescence Plate Reader.
To get started you will need your raw data output, the pre and post - reading for each experiment. This format is 
how we analyze the data with an output that is appropriate for PRISM and also export excel files 
that include data with associated basil and SEM.

Part 1 - PlateV5.m
With raw data usually we analyze the text files by importing into Excel, doing column math and creating Prism Graphs 
tediously and manually. Plate V5 will do this but for all your experiments at once creating analysis more efficiently. 

Some necessary steps:
1. Make sure your folder contains PlateV5 and all the conditons names in an excel file for each experiment 
I.E. excel file - has 20 rows 1 column, each row contains the condition that was placed in the plate reader
2. Make sure the folder contains all the txt files/raw data files from the plate reader
3. The conditon file and the raw data files will start with the date i.e. 210310 (YYMMDD) You'll see in the code 
how the files we read in are formatted

Part 2 - Count2.m
This will count the conditions from your excel condition files you created in step 2 ^^^. This is to check to make sure
you didn't have any small human errors in creating the file. A space or typo will result in data not accounted for!

You're set to analyze your plate reader data. Email me mmcgrory@uw.edu with any questions! Hope this is helpful.
