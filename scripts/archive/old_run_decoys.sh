#!/bin/bash

pdb=$1
index=$2
scorefxn=$3

af_path=/home/arubenstein/mean_field/relax_decoys/ancillary_files/

path=/home/arubenstein/mean_field/relax_decoys/$pdb'_'$index'/'$scorefxn
mkdir -p $path
cd $path

if [ $scorefxn == "soft_rep_design" ]; then
	xml=relaxdecoys$pdb'srd.xml'
elif [ $scorefxn == "soft_rep" ]; then
	xml=relaxdecoys$pdb'sr.xml'
else
	xml=relaxdecoys$pdb'.xml'
fi
	
for i in {1..50}
        do
        mkdir -p Job_${i}
        cd Job_${i}

	nohup nice /home/arubenstein/Rosetta/main/source/bin/rosetta_scripts.static.linuxgccrelease -jd2:ntrials 1 -nstruct 20  -score:weights $scorefxn -parser:protocol /home/arubenstein/mean_field/xml'/'$xml -database /home/arubenstein/Rosetta/main/database/ -out::prefix Job_${i} -s $af_path'/'orig_pdbs/$pdb'_'$index'.pdb'  -run:preserve_header -enzdes::cstfile $af_path'/orig_pdbs/'$pdb'cstfile.txt'  -constraints:cst_file $af_path'/orig_pdbs/'$pdb'_'$index'_sc.cst' -resfile $af_path'/resfile/'rfpack$pdb.txt @/home/arubenstein/mean_field/pdbs/ancillary_files/enzflags > design.log 2>&1 &


	cd ..   
done
