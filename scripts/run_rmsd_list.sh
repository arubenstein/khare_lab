#!/bin/bash

bb_sampling_p=$1
list=$2
pdb=$3

path="/home/arubenstein/mean_field/pdbs/"$bb_sampling_p"/"$pdb'_1/'

cd $path

nativefile=( $( < '/home/arubenstein/mean_field/pdbs/ancillary_files/lists/list'$pdb'cleaved1.txt') )
nativeseq=${nativefile[0]}

nativedir=$path'/'$nativeseq

pattern="*_*_*.pdb"
score="mut_score.sc"
col_subt=1

if [ $bb_sampling_p == "flexpepdock" ]; then
        score="score.sc"
        pattern="*_*_*_*.pdb"
elif [ $bb_sampling_p == "backrub" ]; then
        score="mut_score.sc"
        pattern="*_*_*_*_*_00??.pdb"
	col_subt=3
fi

cd $nativedir
find `pwd` -maxdepth 1 -name "$pattern" > list
tail -n +3 $score | awk '{print $2 " " $NF}' | sort -n | awk ' NR <= 1 {print $2} ' > scr.txt
nativefullfile=$(grep -f scr.txt list)
rm scr.txt
cd ../

/home/arubenstein/Rosetta/main/source/bin/rosetta_scripts.static.linuxgccrelease -nstruct 1  -jd2:ntrials 1 -in:file:native $nativefullfile -parser:protocol /home/arubenstein/mean_field/xml/rmsd.xml -database /home/arubenstein/Rosetta/main/database/ -l $list -run:preserve_header @/home/arubenstein/mean_field/pdbs/ancillary_files/enzflags -overwrite > $list'.log'

filenames=( $( < $list ) )
numfiles=$(( ${#filenames[@]} ))
n=`expr $numfiles - 1`

rmsd=($(awk '$2 == "RMSD:" {print $NF}' $list'.log'))


rm -f $list'_rmsd_hamm.txt'

for i in $( seq 0 $n) 
do

	sequence=$(echo ${filenames[$i]} | awk -v c=$col_subt -F/ '{print $(NF-c)}' )
	hamm=0

	for (( ind=0; ind<${#sequence}; ind++ )); do
		if [ ${nativeseq:$ind:1} != ${sequence:$ind:1} ]
		then
			hamm=`expr $hamm + 1`
		fi
	done

	echo ${rmsd[$i]} $hamm >> $list'_rmsd_hamm.txt'
done
