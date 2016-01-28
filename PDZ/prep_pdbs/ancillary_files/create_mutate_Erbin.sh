#!/bin/bash

out_path=$1
WT_seq=$2
mut_seqs_filename=$3
scorefxn=$4
in_pdb=$5
begin_index=$6
end_index=$7


counter=0
filecounter=0
        
while read line	
do
	filecounter=$(( $filecounter + 1 ))
	
	if [ $filecounter -ge $begin_index ] && [ $filecounter -le $end_index ];
	then
		
		filename=`echo $line | awk '{print $1}'`
		mut_seq=`echo $line | awk '{print $2}'`		

		for i in $(seq -f "%02g" 1 20)
		do
			in_pdb_curr=$in_pdb'_'$i
			base_pdb=$(basename $in_pdb_curr)

			path=$out_path'/'$filename'/'$base_pdb
			
			mkdir -p $path
			cd $path
			cp $in_pdb_curr'.pdb' $base_pdb'.pdb'     
			
			if [[ counter -lt 50 ]]
			then
				/home/arubenstein/mean_field/PDZ/prep_pdbs/ancillary_files/run_mutate_Erbin.sh $path $WT_seq $mut_seq $scorefxn $base_pdb'.pdb' &
				counter=$(( $counter + 1 ))
			else
				counter=0
				wait
				/home/arubenstein/mean_field/PDZ/prep_pdbs/ancillary_files/run_mutate_Erbin.sh $path $WT_seq $mut_seq $scorefxn $base_pdb'.pdb' &
			fi	
		done
	fi
		
done < $mut_seqs_filename
