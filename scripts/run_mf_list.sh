#!/bin/bash

#SBATCH -n 1
#SBATCH -c 1
#SBATCH --job-name=mean_field

# 5/11/15 configured script to take path of list as a n argument to use for running enumerate dihedrals
# 1LVB /home/arubenstein/mean_field/pdbs/backrub/peptide/1LVB_1/list_backrub.txt backruba 1 talaris2013 talaris2013
pdb=$1
listpath=$2
bb_sampling=$3
index=$4
scorefxn=$5
scorefxn_2=$6

rf='stdmfrf'$pdb'.txt'
sc=""

if [[  $bb_sampling =~ ^.*a$ ]] ; then
        #scorefxn=talaris2013
        const_file_arg_1=""
        const_file_arg_2=""
        bb_sampling_p="${bb_sampling%?}"
        sc="-use_input_sc"
elif [[  $bb_sampling =~ ^.*b$ ]] ; then
        #scorefxn=talaris2013
        const_file_arg_1=""
        const_file_arg_2=""
        bb_sampling_p="${bb_sampling%?}"
        rf='stdmfrf'$pdb'pp.txt'
elif [[  $bb_sampling =~ ^.*c$ ]] ; then
        #scorefxn=talaris2013
        const_file_arg_1=""
        const_file_arg_2=""
        bb_sampling_p="${bb_sampling%?}"
        rf='stdmfrf'$pdb'pp.txt'
        sc="-use_input_sc"
elif [[  $bb_sampling =~ ^.*$ ]] ; then
        #scorefxn=talaris2013
        const_file_arg_1=""
        const_file_arg_2=""
        bb_sampling_p=$bb_sampling
        sc=""
fi

if [ $scorefxn_2 == "talaris2013" ]; then
	xml="design_pept.xml"
elif [ $scorefxn_2 == "soft_rep_design" ]; then
	xml="design_pept_soft_rep_design.xml"
elif [ $scorefxn_2 == "soft_rep" ]; then
	xml="design_pept_soft_rep.xml"
fi

resfilepath='/home/arubenstein/mean_field/pdbs/ancillary_files/relaxed_'$scorefxn'/resfile'

listname=$(basename "$listpath")        
listname="${listname%.*}"


path='/home/arubenstein/mean_field/mf_test/bb_sampling_'$bb_sampling'/'$scorefxn'/'$pdb'_'$index'/'$scorefxn_2
homepath='/home/arubenstein/mean_field/mf_test/bb_sampling_'$bb_sampling'/'$scorefxn'/'$pdb'_'$index'/'$scorefxn_2
mkdir -p $path
mkdir -p $homepath
cd $path
grep -sq "reported success" $homepath'/'$listname'.log'
if [ $? -gt 0 ]; then 
	/home/arubenstein/Rosetta/main/source/bin/rosetta_scripts_boltz_per_aa_summed1_ntask.static.linuxgccrelease -score:weights $scorefxn_2 $const_file_arg_1 $const_file_arg_2 -ex1 -ex2 $sc -database /home/arubenstein/Rosetta/main/database -parser:protocol /home/arubenstein/mean_field/xml'/'$xml -extrachi_cutoff 1 -s '/home/arubenstein/mean_field/pdbs/ancillary_files/relaxed_'$scorefxn'/'$pdb'_'$index'.pdb' -spec_profile '/home/arubenstein/mean_field/'$scorefxn'/'$pdb'.transfac' -bb_list $listpath -dump_transfac $path/$listname -resfile $resfilepath'/'$rf -run:preserve_header -rot_norm_weight 0.8 -nooutput true > $path'/'$listname'.log' 
fi

#rsync -av $path'/*' $homepath'/'

exit
ga_path='/home/arubenstein/mean_field/gen_alg/bb_sampling_'$bb_sampling'/'$pdb'_'$index'_'$listname'_'$num_pdbs
mkdir -p $ga_path

cd $ga_path

finallistfname=$path'/'$listname'_'$num_pdbs'_list.txt'

sed -i "s/\/home\/arubenstein/\/home\/arubenstein/g" $finallistfname

seqfiles=( $( < $finallistfname) )
numseqfiles=$(( ${#seqfiles[@]} ))
numloopfiles=$[$numseqfiles/120]

for i in $(seq 0 $numloopfiles)
do
#	for j in $(seq 0 119)
#	do
#		seqfilename=${seqfiles[$[i*120+j]]}
#		if ! [ -z "$seqfilename" ]; then
#			command="sbatch /home/arubenstein/mean_field/gen_alg/run_gen_alg_curr.sbatch $pdb $seqfilename $bb_sampling $index $listname $num_pdbs 1 $resfilepath $rf $sc $scorefxn" 
#			job_id=$($command | awk ' {print $4} ')
#		fi
#	done

        for j in $(seq 0 119)
        do
                seqfilename=${seqfiles[$[i*120+j]]}
                if ! [ -z "$seqfilename" ]; then
                        command="sbatch /home/arubenstein/mean_field/gen_alg/run_gen_alg_curr.sbatch $pdb $seqfilename $bb_sampling $index $listname $num_pdbs 25 $resfilepath $rf $sc $scorefxn"
			if [ -n "$job_id" ];then
				job_id=$job_id':'$($command | awk ' {print $4} ')
			else
				job_id=$($command | awk ' {print $4} ')
			fi			
                fi
        done
done

cd $ga_path

sbatch --dependency=afterok:$job_id /home/arubenstein/mean_field/mf_test/run_mf_postproc.sbatch $pdb $listname $num_pdbs $bb_sampling $index $scorefxn
