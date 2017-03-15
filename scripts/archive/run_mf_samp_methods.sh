#!/bin/bash

#SBATCH -n 1
#SBATCH -c 1
#SBATCH --job-name=mean_field

# 1LVB cleaved5_sort 1 6 dun02 1 talaris2013
pdb=$1
listname=$2
num_pdbs=$3
bb_sampling=$4
samp=$5
index=$6
scorefxn=$7
extra_res_fa=$9
#sort_pdbs=$7


#setting parameters
rf='stdmfrf'$pdb'.txt'
sc=""
scorefxn_2="talaris2013"
#setting params file
if [ ! -z $extra_res_fa ];then
        extra_res_fa="-extra_res_fa $extra_res_fa"
fi

#setting sampling methods settings
if [[  $samp == dun02 ]] ; then
        extra_flags="-dun10 false"
        scorefxn_2="talaris2013_dun02"
	sc="-use_input_sc"
elif [[  $samp == no_isc ]] ; then
        sc=""
elif [[  $samp == "ex1aroex2aro" ]]; then
        extra_flags="-ex1aro -ex2aro"
	sc="-use_input_sc"
elif [[  $samp == "ex3ex4" ]] ; then
        extra_flags="-ex3 -ex4 -ex1aro -ex2aro "
	sc="-use_input_sc"
elif [[ $samp == *pp* ]] ; then
	rf='stdmfrf'$pdb$samp'.txt'
        sc="-use_input_sc"
fi

xml="design_pept.xml"

resfilepath='/home/arubenstein/mean_field/pdbs/ancillary_files/relaxed_'$scorefxn'/resfile'

filename=$listname

file_path='/home/arubenstein/mean_field/pdbs/bb_sampling_'$bb_sampling'/'$pdb'_'$index

#generating list of pdb files
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
			
			find `pwd` -name 'mut_'$sequence'_*.pdb' > list
			curr_num_pdbs=`wc -l list | awk '{print $1}'`
			
			if [ "$curr_num_pdbs" -gt "$num_pdbs" ]
			then
			#	if [ $sort_pdbs == 0 ];
			#	then
       		        #			num_to_div=$((curr_num_pdbs/num_pdbs))
        		#		num_to_div=${num_to_div/.*}
        		#		awk -v n=$num_to_div 'NR % n == 0' list >> $listfilename'_'$SLURM_JOB_ID
			#	else
					tail -n +3 mut_score.sc | awk '{print $2 " " $NF}' | sort -n | awk -v n=$num_pdbs ' NR <= n {print $2} ' > home.txt
					grep -f home.txt list >> $listfilename'_'$SLURM_JOB_ID
					rm home.txt
			#	fi
			else
        			cat list >> $listfilename'_'$SLURM_JOB_ID
			fi
			cd ..
		fi

	done

	cp $listfilename'_'$SLURM_JOB_ID $listfilename
fi

#setting paths and making them
path='/home/arubenstein/mean_field/mf_test/bb_sampling_samp_methods/'$samp'/'$pdb'_'$index'/'
mkdir -p $path
cd $path

#5/20/15 changed checking for success in home because that's the functionality I need currently
grep -sq "reported success" $path'/'$listname'_'$num_pdbs'.log'
if [ $? -gt 0 ]; then 
	'/home/arubenstein/Rosetta/main/source/bin/rosetta_scripts_boltz_per_aa_summed1_ntask.static.linuxgccrelease' -score:weights $scorefxn_2 -ex1 -ex2 $sc -database /home/arubenstein/Rosetta/main/database -parser:protocol /home/arubenstein/mean_field/xml'/'$xml -extrachi_cutoff 1 -s '/home/arubenstein/mean_field/pdbs/ancillary_files/relaxed_'$scorefxn'/'$pdb'_'$index'.pdb' -rot_norm_weight 0.8 -spec_profile '/home/arubenstein/mean_field/'$scorefxn'/'$pdb'.transfac' -bb_list $listfilename -dump_transfac $path/$listname'_'$num_pdbs -resfile $resfilepath'/'$rf -run:preserve_header -nooutput true -run:profile -unmute core.util.prof $extra_res_fa $extra_flags > $path'/'$listname'_'$num_pdbs'.log'  
fi


