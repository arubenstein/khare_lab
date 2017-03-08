#!/bin/bash

pdb=$1
index=$2
listname=$3
extra_res_fa=$4

cd /home/arubenstein/mean_field/pdbs

sort ancillary_files/lists'/list'$pdb$listname'.txt' | uniq > 'scr'$pdb'.txt'
seqs=( $( < 'scr'$pdb'.txt' ) )
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
		    path='/home/arubenstein/mean_field/pdbs/flexpepdock/'$pdb'_'$index'/'$sequence'/'
		    mkdir -p $path

		    /home/arubenstein/mean_field/pdbs/ancillary_files/run_flexpepdock.sh $path $sequence $pdb $index $extra_res_fa &
		fi
	done
	wait
done
wait

