# sorting_big_files
Script to combine and restructure files  

I have a number of files, that can be divided into 5 groups based on their file names. The files in each group must be combined, creating 5 new files. 

The original files contain a number of columns, structured (x,y,t1,t2,t3....tn) where x and y are spatial coordinates and t1, t2, t3 etc is a variable at sample time 1, 2, 3 etc. Each file contains a different variable.  The time samples for each of the groups are stored in separate files 

The 5 new files should be structured y, t, v1, v2, v3....vn, where t is time and v1, v2, v3....vn are the different files. n in this case is the number of files in a group.

The files in each group have the same number of columns (and time intervals), but the groups do not neccessarily have the same number of columns as each other. 
