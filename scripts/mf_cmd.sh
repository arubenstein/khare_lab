#!/bin/bash


#rename variables
pdb=$1
listname=$2
num_pdbs=$3
bb_sampling=$4
index=$5
sc=$6
path=$7
scorefxn=$8
listfilename=$9
resfile=${10}
rn=${11}
bb_average_weight=${12}
release_name=${13}

const_file_arg_1=""
const_file_arg_2=""
 
/home/arubenstein/Rosetta/main/source/bin'/'$release_name'.static.linuxgccrelease' -score:weights talaris2013 $const_file_arg_1 $const_file_arg_2 -ex1 -ex2 $sc -database /home/arubenstein/Rosetta/main/database/ -parser:protocol $path/design_pept.xml -extrachi_cutoff 1 -s '/home/arubenstein/mean_field/pdbs/ancillary_files/relaxed_'$scorefxn'/'$pdb'_'$index'.pdb' -spec_profile /home/arubenstein/mean_field'/'$scorefxn'/'$pdb'.transfac' -bb_list $listfilename -dump_transfac $path/$listname'_'$num_pdbs -resfile $resfile -run:preserve_header -nooutput  -rot_norm_weight $rn -mean_field:bb_average_weight $bb_average_weight > $path'/'$listname'_'$num_pdbs'.log'
