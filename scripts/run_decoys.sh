#!/bin/bash

pdb=$1
cat=$2
extra_res_fa=$3

af_path=/home/arubenstein/git_repos/mean_field/input/
pdb_path=/home/arubenstein/git_repos/mean_field/input/xtal_pdbs

cd $af_path

python /home/arubenstein/git_repos/mean_field/scripts/constraint_chain1.py $pdb_path'/'$pdb'.pdb' 0.1 0.5

path=/home/arubenstein/git_repos/mean_field/relax_decoys/$pdb

if [ -d "$path" ]; then
	exit
fi

mkdir -p $path
cd $path

for i in {1..50}
do
        mkdir -p Job_${i}
        cd Job_${i} 
         
	/home/arubenstein/git_repos/mean_field/scripts/relax_cmd.sh $i $pdb_path $pdb $af_path $cat $extra_res_fa &
             

        cd ..   
done
wait
