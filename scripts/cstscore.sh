#!/bin/bash

pdb=$1
index=$2 #if no index exists make this "-1"
extra_res_fa=$3

af_path=/home/arubenstein/git_repos/mean_field/input/xtal_pdbs/

if [[ $index != "-1" ]]
then
	suffix="_"$index
else
	suffix=""
fi


path=/home/arubenstein/git_repos/mean_field/relax_decoys/$pdb$suffix'/'
cd $path

xml=cstscore.xml

if [ ! -z $extra_res_fa ];then
        extra_res_fa="-extra_res_fa $extra_res_fa"
fi

#hacky way to run ly104
if [[ $pdb =~ "ly104" ]]
then
        catcst='-enzdes::cstfile /home/arubenstein/git_repos/deep_seq/discrim_sim/input/pdbs/ly104cstfile.txt'
        score=talaris2014_cst
        flags=/home/arubenstein/git_repos/general_src/enzflags
else
	catcst='-enzdes::cstfile '$af_path'/'$pdb'cstfile.txt'
        score=enzdes
	flags=/home/arubenstein/git_repos/mean_field/scripts/enzflags
fi

for i in {1..50}
do

	cd Job_${i}
	find `pwd` -name "Job_*.pdb" > list
	
	nohup nice /home/arubenstein/Rosetta/main/source/bin/rosetta_scripts.static.linuxgccrelease -nstruct 1  -parser:protocol /home/arubenstein/git_repos/mean_field/xml'/'$xml -database /home/arubenstein/Rosetta/main/database/ $extra_res_fa -out::prefix Cstscored_ -l $path'/Job_'${i}'/list'  -run:preserve_header $catcst @$flags -overwrite -score:weights $score > cst.log &

cd ..
done
wait
