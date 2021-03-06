#!/bin/bash

#numstruct must be less than number of processors available!!!
#GraB 1 peptide cleaved5_sort
pdb=$1
index=$2
over_res=$3
listname=$4

cd /home/arubenstein/mean_field/pdbs

sort ancillary_files/lists'/list'$pdb$listname'.txt' | uniq > scr.txt
seqs=( $( < scr.txt ) )

numseqs=$(( ${#seqs[@]} ))
numloops=$[$numseqs/40]

echo $numseqs
echo $numloops

for i in $(seq 0 $numloops)
do
	echo "Outer " $i
        for j in $(seq 0 39) # {0..47}
        do
		echo "Inner " $j
                line=${seqs[$[i*40+j]]}

		if ! [ -z "$line" ]
		then
		    sequence=$line
		    path='/home/arubenstein/mean_field/pdbs/backrub/'$pdb'_'$index'/'$sequence'/'$over_res'/'
		    mkdir -p $path
		    
		    /home/arubenstein/mean_field/pdbs/ancillary_files/run_backrub.sh $path $sequence $pdb $index $over_res $extra_res_fa &
		fi
	done
	wait
done
wait
