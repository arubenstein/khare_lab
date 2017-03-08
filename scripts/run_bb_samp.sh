#!/bin/bash

path=$1
sequence=$2
pdb=$3
scorefxn=$4
xml=$5
index=$6
extra_res_fa=$7

if [ ! -z $extra_res_fa ];then
        extra_res_fa="-extra_res_fa $extra_res_fa"
fi


if [[ $index != "-1" ]]
then
        suffix="_"$index
else
        suffix=""
fi

#CREATEXML
cp /home/arubenstein/git_repos/mean_field/xml'/mutrelax'$xml$pdb'dummy.xml' $path/$sequence".xml"
cp '/home/arubenstein/git_repos/mean_field/input/pdbs/'$pdb$suffix'dummy.pdb' $path/$sequence".pdb"
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

if [ $xml == "cat" ]; then
                const_file_arg_1="-enzdes:cstfile"
                const_file_arg_2="/home/arubenstein/git_repos/mean_field/input/pdbs/"$pdb"cstfile.txt"
elif [ $xml == "coo" ]; then
                const_file_arg_1="-constraints:cst_file"
                const_file_arg_2="/home/arubenstein/git_repos/mean_field/input/pdbs/"$pdb$suffix"_sc.cst"
else
                const_file_arg_1="-constraints:cst_file /home/arubenstein/git_repos/mean_field/input/pdbs/"$pdb_$suffix"_sc.cst"
                const_file_arg_2="-enzdes:cstfile /home/arubenstein/git_repos/mean_field/input/pdbs/"$pdb"cstfile.txt"
fi

#MUTATERUN
if [ ! `ls mut_*.pdb 2>/dev/null | wc -l` -eq 10 ]
then
	nohup nice /home/arubenstein/Rosetta/main/source/bin/rosetta_scripts.static.linuxgccrelease -nstruct 10  -jd2:ntrials 1 -parser:protocol $path/$sequence.xml -database /home/arubenstein/Rosetta/main/database/ $const_file_arg_1 $const_file_arg_2 -out::prefix mut_ -s $path/$sequence".pdb" -run:preserve_header -overwrite @/home/arubenstein/git_repos/mean_field/scripts/enzflags $extra_res_fa -score::weights talaris2013 > design.log
fi

find `pwd` -name "mut_$sequence_00*pdb" > relaxed_list
