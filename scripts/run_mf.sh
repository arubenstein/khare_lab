#!/bin/bash

#rename variables
pdb=$1
listname=$2
goal_spec_prof=$3
num_pdbs=$4
bb_sampling=$5
index=$6
#sort_pdbs=$7

rf='stdmfrf'$pdb'.txt'
wts='talaris2013'

if [ $bb_sampling == "4" ]; then
	scorefxn=relaxed_score12
	const_file_arg1=""
	const_file_arg2=""
	bb_sampling_p=$bb_sampling
elif [ $bb_sampling == "4a" ]; then
	scorefxn=relaxed_score12
	const_file_arg1=""
	const_file_arg2=""
	bb_sampling_p="4"
	rf='stdmfrf'$pdb'pp.txt'
elif [ $bb_sampling == "5" ]; then
	scorefxn=relaxed_score12
        const_file_arg_1=""
        const_file_arg_2=""
	bb_sampling_p=$bb_sampling
elif [ $bb_sampling == "5a" ]; then
	scorefxn=relaxed_score12
	const_file_arg_1=""
	const_file_arg_2=""
	bb_sampling_p="5"
	rf='stdmfrf'$pdb'pp.txt'
elif [ $bb_sampling == "6" ]; then
	scorefxn=relaxed_talaris2013
	const_file_arg_1="-enzdes:cstfile"
        const_file_arg_2="/home/arubenstein/mean_field/pdbs/ancillary_files/"$scorefxn"/"$pdb"cstfile.txt"
        bb_sampling_p=$bb_sampling
fi

filename=$listname

file_path='/home/arubenstein/mean_field/pdbs/bb_sampling_'$bb_sampling_p'/'$pdb'_'$index'/'$listname

listfilename=$file_path"/list_"$num_pdbs
rm -f $listfilename
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
			#	if [ $sort_pdbs == 0 ];
			#	then
       		 			num_to_div=$((curr_num_pdbs/num_pdbs))
        				num_to_div=${num_to_div/.*}
        				awk -v n=$num_to_div 'NR % n == 0' list >> $listfilename
			#	else
			#		tail -n +3 mut_score.sc | awk '{print $2 " " $NF}' | sort -n | awk -v n=$num_pdbs ' NR == n {print $2} ' > scratch.txt
			#		grep -f scratch.txt list >> $listfilename
			#		rm scratch.txt
			#	fi
			else
        			cat list >> $listfilename
			fi
			cd ..
		fi

done

sort $listfilename -o $listfilename

path='/home/arubenstein/mean_field/mf_test/bb_sampling_'$bb_sampling'/'$pdb'_'$index
mkdir -p $path
cd $path
grep -sq "reported success" $path'/'$listname'_'$num_pdbs'.log'
if [ $? -gt 0 ]; then 
	/home/arubenstein/Rosetta/main/source/bin/rosetta_scripts.static.linuxgccrelease -score:weights $wts $const_file_arg_1 $const_file_arg_2 -ex1 -ex2 -database /home/arubenstein/Rosetta/main/database/ -parser:protocol /home/arubenstein/mean_field/xml/design_pept.xml -extrachi_cutoff 1 -s '/home/arubenstein/mean_field/pdbs/ancillary_files/'$scorefxn'/'$pdb'_'$index'.pdb' -spec_profile /home/arubenstein/mean_field/$goal_spec_prof -bb_list $listfilename -dump_transfac $path/$listname'_'$num_pdbs -resfile '/home/arubenstein/mean_field/pdbs/ancillary_files/resfile/'$rf -run:preserve_header -nooutput  > $path'/'$listname'_'$num_pdbs'.log'
fi

ga_path='/home/arubenstein/mean_field/gen_alg/bb_sampling_'$bb_sampling'/'$pdb'_'$index'_'$listname'_'$num_pdbs
mkdir -p $ga_path
cd $ga_path

seqfiles=( $( < $listfilename) )
numseqfiles=$(( ${#seqfiles[@]} ))
numloopfiles=$[$numseqfiles/20]

for i in $(seq 0 $numloopfiles)
do
	for j in $(seq 0 19)
	do
		seqfilename=${seqfiles[$[i*20+j]]}
		if ! [ -z "$seqfilename" ]; then
			~/mean_field/gen_alg/run_gen_alg.sh $pdb $seqfilename $bb_sampling $index $listname $num_pdbs 5 $rf $wts  & 
                        ~/mean_field/gen_alg/run_gen_alg.sh $pdb $seqfilename $bb_sampling $index $listname $num_pdbs 1 $rf $wts  &
		fi
	done
	wait
done
wait

/home/arubenstein/mean_field/gen_alg/extract_best_energies.sh $ga_path 5 $pdb'_'$index'_'$listname'_'$num_pdbs
/home/arubenstein/mean_field/gen_alg/extract_best_energies.sh $ga_path 1 $pdb'_'$index'_'$listname'_'$num_pdbs

find `pwd` -name "*_5_seqs.transfac" | sort > list_spec_profiles.txt
find `pwd` -name "*_5_cutoff_seqs.transfac" | sort > list_spec_profiles_cutoff.txt 
/home/arubenstein/Rosetta/main/source/bin/spec_prof_compare.static.linuxgccrelease -bb_boltz_probs $path'/'$listname'_'$num_pdbs'_boltz.txt' -dump_transfac $pdb'_'$index'_'$listname'_'$num_pdbs'_avg' -spec_profile /home/arubenstein/mean_field'/'$pdb'.transfac' -bb_list list_spec_profiles.txt > $pdb'_'$index'_'$listname'_'$num_pdbs'_avg'.log
/home/arubenstein/Rosetta/main/source/bin/spec_prof_compare.static.linuxgccrelease -bb_boltz_probs $path'/'$listname'_'$num_pdbs'_boltz.txt' -dump_transfac $pdb'_'$index'_'$listname'_'$num_pdbs'_cutoff' -spec_profile /home/arubenstein/mean_field'/'$pdb'.transfac' -bb_list list_spec_profiles_cutoff.txt > $pdb'_'$index'_'$listname'_'$num_pdbs'_cutoff'.log

echo $SECONDS
