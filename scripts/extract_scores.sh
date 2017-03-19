#!/bin/bash

pdb=$1
index=$2

if [[ $index != "-1" ]]
then
        suffix="_"$index
else
        suffix=""
fi

path=/home/arubenstein/git_repos/mean_field/relax_decoys/$pdb$suffix'/'

cd $path

rm -f cstscores.txt
rm -f totalscores.txt

for i in {1..50}
do
	cd Job_${i}
	awk ' NR > 2 {print $NF,$7}' Cstscored_score.sc >> ../cstscores.txt
	awk ' NR > 2 {print $NF,$2} ' Job_${i}score.sc >> ../totalscores.txt
	cd ..
done

sort cstscores.txt -o cstscores.txt
sort totalscores.txt -o totalscores.txt

paste cstscores.txt totalscores.txt > scores.txt

sort -nk 2 cstscores.txt -o cstscores.txt
sort -nk 2 totalscores.txt -o totalscores.txt
