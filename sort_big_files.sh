#!/bin/bash
# Script to combine and restructure files 
#
# I have a number of files, that can be divided into 5 groups based on their file names.
# The files in each group must be combined, creating 5 new files.
#
# The original files contain a number of columns, structured (x,y,t1,t2,t3....tn) where x and y
# are spatial coordinates and t1, t2, t3 etc is a variable at sample time 1, 2, 3 etc.
# Each file contains a different variable. 
#
# The time samples for each of the groups are stored in separate files
#
# The 5 new files should be structured y, t, v1, v2, v3....vn, where t is time and
# v1, v2, v3....vn are the different files. n in this case is the number of files in a group. 
#
# The files in each group have the same number of columns (and time intervals), but the groups
# do not neccessarily have the same number of columns as each other. 

#-------------

# Common suffix for each of the 5 groups
declare -a arr=("H2Oc_High" "No_Gas_Loss" "Pex0" "Pex20" "Gamma_Low")

path=/nfs/a116/eelhm/Output_Files/Data_Archive

#------
# Firstly sorting each file in group to y,t,v

for fn_common in "${arr[@]}"; do # Looping over each group in turn
  echo "$fn_common"
  time_file="$path"/Time_"$fn_common".txt # Time intervals common for the files in the group

  for i in "$path"/"$fn_common"*.txt; do # Looping over each file in the group
    echo "$i"
    f=${i::${#i}-4} # Variable name extracted from file name, to be used in sorted file for each variable file
    echo "$f"
    outfn="$f"_sort.txt
    echo "$outfn"
    tail -n +10 "$i" > tmp.txt # Removing headers
    awk '{$1=""; print $0}' tmp.txt > tmp2.txt # Removing first column (x coordinate - not required)

    ncols="$(awk '{print NF}' tmp2.txt | sort -nu | tail -n 1)" # Number of columns
    echo "$ncols"
    ntimes=$((ncols-1)) # Number of time samples
    echo "$ntimes"
    ntimesm1=$((ntimes-1)) # Number of time samples minus 1
    echo "$ntimesm1"
    nrows="$(wc -l < tmp2.txt)" # Number of rows
    echo "$nrows"

    rm "$outfn" # File will be created later (line 58), removing if it already exists
    for i in `seq 1 1 "$nrows"`; do # Looping over each row in file
      y="$(sed "$i q;d" tmp2.txt | awk '{print $1}')" # Y coordinate is the first column, storing value for the row
      k=1 # counter
      while read t; do # Looping over each time sample, stored in file
        k=$((k+1)) # loop count
        var="$(sed "$i q;d" tmp2.txt | awk -v k=$k '{print $k}')" # sed prints row, awk prints column from that row, corresponding to the loop count 
        echo "$y" "$t" "$var" >> "$outfn" # Adding data to sorted output file, individual file for each variable, sorted y,t,v
      done < "$time_file"
    done
  done

#--------

# Combining sorted files for each variable to create one file per group.
# 'Crystal_Content' is the first filename alphabetically in each group. 
# Copying first two columns (y,t) to create final file to output. These columns should be common in each file in group
  awk '{print $1, $2}' "$path"/"$fn_common"_Crystal_Content_sort.txt > "$path"/"$fn_common"_Archive.txt 
  for i in "$path"/"$fn_common"*sort.txt; do # Looping through sorted files
    echo "$i"
    awk 'NR==FNR{a[NR]=$0;next}{print a[FNR],$3}' "$path"/"$fn_common"_Archive.txt "$i" > tmp.txt # Appending column with variable to output file
    mv tmp.txt "$path"/"$fn_common"_Archive.txt
  done
done

rm tmp.txt tmp2.txt # Removing temporary files
