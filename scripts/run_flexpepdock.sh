#!/bin/bash

path=$1
sequence=$2
pdb=$3
index=$4
extra_res_fa=$5

if [ ! -z $extra_res_fa ];then
        extra_res_fa="-extra_res_fa $extra_res_fa"
fi

scorefxn=relaxed_talaris2013

#CREATEXML
cp /home/arubenstein/mean_field/xml'/mut'$pdb'dummy.xml' $path/$sequence".xml"
cp '/home/arubenstein/mean_field/pdbs/ancillary_files/'$scorefxn'/'$pdb'_'$index'dummy.pdb' $path/$sequence".pdb"
cd $path

declare -A protein_alph=(["A"]="ALA" ["C"]="CYS" ["D"]="ASP" ["E"]="GLU" ["F"]="PHE" ["G"]="GLY" ["H"]="HIS" ["I"]="ILE" ["K"]="LYS" ["L"]="LEU" ["M"]="MET" ["N"]="ASN" ["P"]="PRO" ["Q"]="GLN" ["R"]="ARG" ["S"]="SER" ["T"]="THR" ["V"]="VAL" ["W"]="TRP" ["Y"]="TYR")

replace_string='sed -i "s/DM1/${protein_alph[${sequence:0:1}]}/g'

for i in $(seq 2 ${#sequence})
do
	index_zero=$((i-1))
	replace_string+=';s/DM'$i'/${protein_alph[${sequence:'$index_zero':1}]}/g'
done 

replace_string+='"'
replace_string_xml="$replace_string $sequence.xml"
replace_string_pdb="$replace_string $sequence.pdb"

eval $replace_string_xml
eval $replace_string_pdb

#THREADRUN
cd $path
nohup nice /home/arubenstein/Rosetta/main/source/bin/rosetta_scripts.static.linuxgccrelease -nstruct 1  -jd2:ntrials 1 -parser:protocol $path/$sequence.xml -database /home/arubenstein/Rosetta/main/database/ -out::prefix mut_ -s $path/$sequence".pdb" -run:preserve_header @/home/arubenstein/mean_field/pdbs/ancillary_files/enzflags $extra_res_fa -enzdes:cstfile /home/arubenstein/mean_field/pdbs/ancillary_files'/relaxed_talaris2013/'$pdb'cstfile.txt' > design.log


#SAMPRUN
if [ ! `ls samp_*.pdb 2>/dev/null | wc -l` -eq 10 ]
then
	cd $path
	nohup /home/arubenstein/Rosetta/main/source/bin/rosetta_scripts.static.linuxgccrelease -parser:protocol ~/mean_field/xml/flexpepdock.xml -database /home/arubenstein/Rosetta/main/database/ -s $path'/mut_'$sequence'_0001.pdb' -ex1 -ex2 -ex1aro -ex2aro -extrachi_cutoff 0 -nstruct 10 -enzdes:cstfile /home/arubenstein/mean_field/pdbs/ancillary_files'/relaxed_talaris2013/'$pdb'cstfile.txt' -score:weights talaris2013_cst -run:preserve_header $extra_res_fa -packing:use_input_sc > $path'/'flexpepdock.log
fi	
