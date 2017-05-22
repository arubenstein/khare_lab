#!/bin/bash

#SBATCH -n 1
#SBATCH -c 1
#SBATCH --job-name=mean_field

# 1LVB cleaved5_sort 1 bb_sampling_7a -1 talaris2013 talaris2013 rosetta_scripts PDZ 0.6
pdb=$1
listname=$2
num_pdbs=$3
bb_sampling=$4
index=$5
scorefxn=$6
scorefxn_2=$7
release_name=$8
pdb_class=$9
temp=${10}
extra_res_fa=${11}
#sort_pdbs=$7

if [[ $index != "-1" ]]
then
        suffix="_"$index
else
        suffix=""
fi

if [[ $pdb_class == "PDZ" ]]; then
	rf=stdmfrfPDZ.txt
else
	rf='stdmfrf'$pdb'.txt'
fi

sc=""

if [ ! -z $extra_res_fa ];then
        extra_res_fa="-extra_res_fa $extra_res_fa"
fi

if [[  $bb_sampling =~ ^.*a$ ]] ; then
        #scorefxn=talaris2013
        const_file_arg_1=""
        const_file_arg_2=""
        bb_sampling_p="${bb_sampling%?}"
        sc="-use_input_sc"
elif [[  $bb_sampling =~ ^.*b$ ]] ; then
        #scorefxn=talaris2013
        const_file_arg_1=""
        const_file_arg_2=""
        bb_sampling_p="${bb_sampling%?}"
        rf='stdmfrf'$pdb'pp.txt'
elif [[  $bb_sampling =~ ^.*c$ ]] ; then
        #scorefxn=talaris2013
        const_file_arg_1=""
        const_file_arg_2=""
        bb_sampling_p="${bb_sampling%?}"
        rf='stdmfrf'$pdb'pp.txt'
        sc="-use_input_sc"
elif [[  $bb_sampling =~ ^.*$ ]] ; then
        #scorefxn=talaris2013
        const_file_arg_1=""
        const_file_arg_2=""
        bb_sampling_p=$bb_sampling
        sc=""
fi

if [ $scorefxn_2 == "talaris2013" ]; then
	xml="design_pept"$temp".xml"
elif [ $scorefxn_2 == "soft_rep_design" ]; then
	xml="design_pept_soft_rep_design"$temp".xml"
elif [ $scorefxn_2 == "soft_rep" ]; then
	xml="design_pept_soft_rep"$temp".xml"
fi

pattern="*_*_*.pdb"
score="mut_score.sc"

if [ $bb_sampling_p == "flexpepdock" ]; then
	score="score.sc"
	pattern="*_*_*_*.pdb"
elif [ $bb_sampling_p == "backrub" ]; then
	score="mut_score.sc"
	pattern="*_*_*_*_*_*.pdb"
fi

xml="design_pept"$temp".xml"

resfilepath='/home/arubenstein/git_repos/mean_field/input/resfile'

filename=$listname

file_path='/home/arubenstein/git_repos/mean_field/thread/'$bb_sampling_p'/'$pdb$suffix

listfilename=$file_path"/list_"$listname'_'$num_pdbs
if [ ! -f $listfilename ]; then

	cd /home/arubenstein/git_repos/mean_field/
	seqs=( $( < input/lists/list$pdb$listname.txt) )
	numseqs=$(( ${#seqs[@]}-1 ))
	
	for i in $(seq 0 $numseqs)
	do
                sequence=${seqs[$[i]]}
	        
		if ! [ -z "$sequence" ]
                then
                	seqfilepath=$file_path'//'$sequence
			cd $seqfilepath
			
			find `pwd` -maxdepth 1 -name "$pattern" > list
			curr_num_pdbs=`wc -l list | awk '{print $1}'`
			
			if [ "$curr_num_pdbs" -gt "$num_pdbs" ]
			then
			#	if [ $sort_pdbs == 0 ];
			#	then
       		        #			num_to_div=$((curr_num_pdbs/num_pdbs))
        		#		num_to_div=${num_to_div/.*}
        		#		awk -v n=$num_to_div 'NR % n == 0' list >> $listfilename'_'$SLURM_JOB_ID
			#	else
					tail -n +3 $score | awk '{print $2 " " $NF}' | sort -n | awk -v n=$num_pdbs ' NR <= n {print $2} ' > home.txt
					grep -f home.txt list >> $listfilename
					rm home.txt
			#	fi
			else
        			cat list >> $listfilename
			fi
			cd ..
		fi

	done

fi

path='/home/arubenstein/git_repos/mean_field/mf/'$bb_sampling'/'$scorefxn'/'$temp'/'$pdb$suffix'/'$scorefxn_2'/'$release_name
homepath='/home/arubenstein/git_repos/mean_field/mf/'$bb_sampling'/'$scorefxn'/'$temp'/'$pdb$suffix'/'$scorefxn_2'/'$release_name
mkdir -p $path
mkdir -p $homepath
cd $path

#5/20/15 changed checking for success in home because that's the functionality I need currently
grep -sq "reported success" $path'/'$listname'_'$num_pdbs'.log'
if [ $? -gt 0 ]; then 
	nohup '/home/arubenstein/Rosetta/main/source/bin/'$release_name'.static.linuxclangrelease' -score:weights $scorefxn_2 $const_file_arg_1 $const_file_arg_2 -ex1 -ex2 $sc -database /home/arubenstein/Rosetta/main/database -parser:protocol /home/arubenstein/git_repos/mean_field/xml'/'$xml -extrachi_cutoff 1 -s '/home/arubenstein/git_repos/mean_field/input/pdbs/'$pdb$suffix'.pdb' -rot_norm_weight 0.8 -spec_profile '/home/arubenstein/git_repos/mean_field/input/transfacs/'$pdb'.transfac' -bb_list $listfilename -dump_transfac $path/$listname'_'$num_pdbs -resfile $resfilepath'/'$rf -run:preserve_header -nooutput true -run:profile -unmute core.util.prof $extra_res_fa -bb_average_weight 0.8 > $path'/'$listname'_'$num_pdbs'.log'  
fi


