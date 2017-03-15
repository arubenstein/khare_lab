#!/bin/bash

#rename variables
pdb=$1
which_prot=$2
chain_num=$3
prot_dep=$4
bb_sampling=$5
goal_spec_prof=$6
num_pdbs=$7

filename=$which_prot'd'$prot_dep'chains'$chain_num

file_path=/home/arubenstein/mean_field/pdbs/bb_sampling_$bb_sampling/$pdb/$filename

cd $file_path

find `pwd` -name $pdb'_0???.pdb' > list
curr_num_pdbs=`wc -l list | awk '{print $1}'`

if [ "$curr_num_pdbs" -gt "$num_pdbs" ];
then
	num_to_div=$((curr_num_pdbs/num_pdbs))
	num_to_div=${num_to_div/.*}
	awk -v n=$num_to_div 'NR % n == 0' list > list_$num_pdbs
else
	cp list list_$num_pdbs
fi

path=/home/arubenstein/mean_field/mf_test/bb_sampling_$bb_sampling/$pdb/
mkdir -p $path
cd $path

/home/arubenstein/Rosetta/main/source/bin/rosetta_scripts.linuxgccrelease -ex1 -ex2 -database /home/arubenstein/Rosetta/main/database/ -parser:protocol /home/arubenstein/mean_field/xml/design_pept.xml -extrachi_cutoff 1 -nooutput -s /home/arubenstein/mean_field/pdbs/ancillary_files/$pdb'.pdb' -spec_profile /home/arubenstein/mean_field/$goal_spec_prof -bb_list $file_path/list_$num_pdbs -dump_transfac $path'/'$filename'_'$num_pdbs -run:profile -unmute core.util.prof > $path'/'$filename'_'$num_pdbs'.log'
