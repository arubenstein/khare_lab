#!/bin/bash

path=$1

cd $path

for dir in $(ls -l | grep '^d' | awk '{print $9}')
do
	cd $dir
	if ! grep -q 'constraint' mut_score.sc; then
		cd ../
		rm  -r $dir
	else
		cd ../
	fi

done
