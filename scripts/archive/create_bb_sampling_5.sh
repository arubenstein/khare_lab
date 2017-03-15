#!/bin/bash

listname=$1
pdb=$2
index=$3

cd /home/arubenstein/mean_field/pdbs
seqs=( $( < ancillary_files/lists/list$pdb$listname.txt) )
numseqs=$(( ${#seqs[@]} ))
numloops=$[$numseqs/48]
for i in $(seq 0 $numloops)
do
        for j in $(seq 0 47) # {0..47}
        do
                line=${seqs[$[i*48+j]]}
                if ! [ -z "$line" ]
                then
                    sequence=$line
		    path='/home/arubenstein/mean_field/pdbs/bb_sampling_5/'$pdb'_'$index'/'$listname'/'$sequence
			mkdir -p $path
		    nohup /home/arubenstein/mean_field/pdbs/ancillary_files/run_bb_samp.sh $path $sequence $pdb relaxed_score12 cat $index &
                fi

        done
        wait
done
wait

