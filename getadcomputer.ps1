get-adcomputer -filter * -searchbase "OU=Computers, OU=Users and Computers, DC=Test, DC=com" | export-CSV .\winPC.csv
