#!/bin/bash
#cleaved 1SPS 1 7
#/scratch/alizarub/mean_field/pdbs/bb_sampling_7/1TP3_1/YRETSV/
#/scratch/alizarub/mean_field/pdbs/bb_sampling_7/1TP3_1/YRETSV/ YRETSV 1TP3 relaxed_talaris2013 coo 1 talaris2013 10
listname=$1
pdb=$2
index=$3
bb_samp=$4
fen=$5
extra_res_fa=$6

scorefxn_2='talaris2013'
numrelax=10

if [ $bb_samp == '6' ];then
	xml='cat'
elif [ $bb_samp == '7' ];then
	xml='coo'
elif [ $bb_samp == '8' ];then
	xml='catcoo'
elif [ $bb_samp == '9' ];then
	xml='cat'
	scorefxn_2='soft_rep_design'
elif [ $bb_samp == '5' ];then
	xml='cat'
	numrelax=100
fi

if [[ $index != "-1" ]]
then
        suffix="_"$index
else
        suffix=""
fi

if [[ $fen == 1 ]]; then
	counter=-1
	out_prefix="/scratch/alizarub"
        in_prefix="/home/alizarub"
        command="sbatch $in_prefix/mean_field/pdbs/ancillary_files/run_bb_samp_fen.sh"
	bg=""
else
	counter=0
	out_prefix="/home/arubenstein"
        in_prefix="/home/arubenstein"
        command="bash $in_prefix/git_repos/mean_field/scripts/run_bb_samp.sh"
	bg=" & "
fi

cd $in_prefix'/git_repos/mean_field/'
sort input/lists'/list'$pdb$listname'.txt' | uniq > scr.txt
seqs=( $( < scr.txt ) )
numseqs=$(( ${#seqs[@]} ))
for j in $(seq 0 $numseqs)
do
                line=${seqs[$[j]]}
                if ! [ -z "$line" ]
                then
                    sequence=$line
		    path=$out_prefix'/git_repos/mean_field/thread/bb_sampling_'$bb_samp'/'$pdb$suffix'/'$sequence
		    mkdir -p $path
		    cmd="$command $path $sequence $pdb relaxed_talaris2013 $xml $index $extra_res_fa $bg"
		    eval $cmd
		fi
                if [[ $counter != -1 ]]; then
                        counter=$((counter+1))
                fi
		if ! (( $counter % 40 )); then
			wait
		fi
done

