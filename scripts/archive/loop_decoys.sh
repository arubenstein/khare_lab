#!/bin/bash

cd ~/mean_field/xtal_pdbs/

for file in $(ls *.pdb)
do
	pdbname=`expr substr $file 1 4`
	~/mean_field/relax_decoys/ancillary_files/run_decoys.sh $pdbname
done
