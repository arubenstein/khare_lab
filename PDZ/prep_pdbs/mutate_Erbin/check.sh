#!/bin/bash

for dir in $(ls -l | awk '$1 ~ /d/ {print $9}')
do
	cd $dir
	n_pdbs=$(ls */*_0001.pdb | wc -l)
	if [ 20 -gt $n_pdbs ]
	then
              for i in $(seq -f "%02g" 1 20)
	      do
		cd 1N7T_$i
		n_p=$(ls *_0001.pdb | wc -l)
		if [ 1 -gt $n_p ]
		then
			echo $dir
			echo $i
		fi
		cd ../
	      done
	fi
	cd ../
done
