#!/bin/bash


#1LVB cleaved6 10 6a 1 rosetta_scripts

#rename variables
#default is to use talaris2013
pdb=$1
listname=$2
num_pdbs=$3
bb_sampling=$4
index=$5
release_name=$6
#sort_pdbs=$7

rf='stdmfrf'$pdb'.txt'
sc="-use_input_sc"
scorefxn=talaris2013

resfilepath='/home/arubenstein/mean_field/pdbs/ancillary_files/relaxed_'$scorefxn'/resfile'

filename=$listname
#todo - change bb_sampling_7 to parameter

bb_samp=$(echo $bb_sampling | awk '{print substr($1,1,1)}')

file_path='/home/arubenstein/mean_field/pdbs/bb_sampling_'$bb_samp'/'$pdb'_'$index

listfilename=$file_path"/list_"$listname'_'$num_pdbs
if [ ! -f $listfilename ]; then

	cd /home/arubenstein/mean_field/pdbs
	seqs=( $( < ancillary_files/lists/list$pdb$listname.txt) )
	numseqs=$(( ${#seqs[@]}-1 ))

	for i in $(seq 0 $numseqs)
	do
                sequence=${seqs[$[i]]}
	        if ! [ -z "$sequence" ]
                then
                	seqfilepath=$file_path'//'$sequence
			cd $seqfilepath

			find `pwd` -name 'mut_'$sequence'_0???.pdb' > list
			curr_num_pdbs=`wc -l list | awk '{print $1}'`

			if [ "$curr_num_pdbs" -gt "$num_pdbs" ];
			then
       		 		num_to_div=$((curr_num_pdbs/num_pdbs))
        			num_to_div=${num_to_div/.*}
        			awk -v n=$num_to_div 'NR % n == 0' list >> $listfilename'_'$SLURM_JOB_ID
			else
        			cat list >> $listfilename'_'$SLURM_JOB_ID
			fi
			cd ..
		fi

	done

	mv $listfilename'_'$SLURM_JOB_ID $listfilename
fi

temp=(0.4 0.6 0.8)
bb_average_weight=(0.0 0.8 1.0)
#lambda=(0.25 0.5 0.75) 
threshold=(5 10 100 500)
rot_norm=(0.0 0.8 1.0)


counter=0
for thr in ${threshold[@]}; do
	for t in ${temp[@]}; do
		for l in ${bb_average_weight[@]}; do
			for rn in ${rot_norm[@]}; do
				counter=$((counter + 1))
				if ! (( counter % 45 )); then
					wait
				fi
				path='/home/arubenstein/mean_field/mf_test/bb_sampling_'$bb_sampling'/'$scorefxn'/'$pdb'_'$index'/param_sweep/'$release_name'/'$thr'_'$t'_'$l'_'$rn
				homepath='/home/arubenstein/mean_field/mf_test/bb_sampling_'$bb_sampling'/'$scorefxn'/'$pdb'_'$index'/param_sweep/'$release_name'/'$thr'_'$t'_'$l'_'$rn		
				mkdir -p $path
				cd $path
				
				cp /home/arubenstein/mean_field/xml/design_pept_dummy.xml $path/design_pept.xml

				sed -i "s/REPL_TEMP/$t/g;s/REPL_LAMBDA/0.5/g;s/REPL_THR/$thr/g" $path/design_pept.xml
	 
				grep -sq "reported success" $path'/'$listname'_'$num_pdbs'.log'
				if [ $? -gt 0 ]; then 
					/home/arubenstein/mean_field/mf_test/mf_cmd.sh $pdb $listname $num_pdbs $bb_sampling $index $sc $path $scorefxn $listfilename $resfilepath'/'$rf $rn $l $release_name &
				fi
			done
		done
	done
done

