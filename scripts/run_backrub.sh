#!/bin/bash

path=$1
sequence=$2
pdb=$3
index=$4
over_res=$5
extra_res_fa=$6

if [ ! -z $extra_res_fa ];then
        extra_res_fa="-extra_res_fa $extra_res_fa"
fi

scorefxn=relaxed_talaris2013

if [ $pdb == "1LVB" ]; then
        piv="-backrub:pivot_residues 215 216 217 218 219 220 221 222 223 224"
elif [ $pdb == "3M5L" ]; then
        piv="-backrub:pivot_residues 200 201 202 203 204 205 206 207 208 209"
elif [ $pdb == "HIVn" ]; then
        piv="-backrub:pivot_residues 199 200 201 202 203 204 205 206 207 208"
elif [ $pdb == "GraB" ]; then
        piv="-backrub:pivot_residues 227 228 229 230 231 232 233 234 235 236"
fi

if [ $over_res == "protein" ]; then
        piv=""
fi

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
nohup nice /home/arubenstein/Rosetta/main/source/bin/rosetta_scripts.static.linuxgccrelease -nstruct 1  -jd2:ntrials 1 -parser:protocol $path/$sequence.xml -database /home/arubenstein/Rosetta/main/database/ -out::prefix mut_ -s $path/$sequence".pdb" -run:preserve_header @/home/arubenstein/mean_field/pdbs/ancillary_files/enzflags $extra_res_fa -enzdes:cstfile /home/arubenstein/mean_field/pdbs/ancillary_files'/'relaxed_talaris2013'/'$pdb'cstfile.txt' > design.log


#SAMPRUN
for ((i=1; i<=10; i++)); do
        outpath=$path'/Job_'$i 
        mkdir -p $outpath
        cd $outpath

        nohup /home/arubenstein/Rosetta/main/source/bin/backrub_cst.linuxgccrelease -run:preserve_header -score:weights talaris2013_cst -database /home/arubenstein/Rosetta/main/database/ -s $path'/mut_'$sequence'_0001.pdb' -ex1 -ex2 -ex1aro -ex2aro -extrachi_cutoff 0 -backrub:minimize_movemap /home/arubenstein/mean_field/pdbs/ancillary_files/backrub_movemap.mm -backrub:ntrials 10000 $piv -out:prefix "Job_"$i"_" -enzdes:cstfile /home/arubenstein/mean_field/pdbs/ancillary_files'/'relaxed_talaris2013'/'$pdb'cstfile.txt' -packing:use_input_sc > backrub.log

done

