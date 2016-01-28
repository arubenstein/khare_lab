#!/bin/bash

out_path=$1
WT_seq=$2
mut_seq=$3
scorefxn=$4
in_pdb=$5
offset=14
chain="A"

#CREATEXML
cd $out_path

echo "NATRO" > resfile.txt
echo "start" >> resfile.txt

offset_exc=$(( $offset - 1))
for i in $(seq 1 $offset_exc)
do
        echo "$i $chain NATAA" >> resfile.txt
done

for (( i=0; i<${#WT_seq}; i++ ))
do
    if [ ${WT_seq:$i:1} != ${mut_seq:$i:1} ]
    then
	pdb_pos=$(( offset + i ))
        echo "$pdb_pos $chain PIKAA ${mut_seq:$i:1}" >> resfile.txt
    else
        pdb_pos=$(( offset + i ))
        echo "$pdb_pos $chain NATAA" >> resfile.txt
    fi	

done

for i in $(seq 98 103)
do
	echo "$i $chain NATAA" >> resfile.txt
done

for i in $(seq 301 307)
do
	echo "$i B NATAA" >> resfile.txt
done

#MUTATERUN
grep -sq "reported success" mutate_Erbin.log
if [ $? -gt 0 ]; then

	nohup nice /home/arubenstein/Rosetta/main/source/bin/rosetta_scripts.static.linuxgccrelease -jd2:ntrials 1 -parser:protocol /home/arubenstein/mean_field/PDZ/xml/mutate_Erbin.xml -database /home/arubenstein/Rosetta/main/database/ -s $in_pdb -overwrite @/home/arubenstein/mean_field/PDZ/prep_pdbs/ancillary_files/enzflags -resfile resfile.txt > mutate_Erbin.log
fi
