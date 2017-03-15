#!/bin/bash


i=$1
pdb_path=$2
pdb=$3
af_path=$4
cat=$5
extra_res_fa=$6

if [ $cat == 1 ];then
        catcst='-enzdes::cstfile '$pdb_path'/'$pdb'cstfile.txt'
	xml=/home/arubenstein/git_repos/mean_field/xml/relaxdecoysgeneralcat.xml
	score=talaris2013_cst
else
	catcst=""
	xml="/home/arubenstein/git_repos/mean_field/xml/relaxdecoysgeneral.xml"
	score=talaris2013
fi

if [ ! -z $extra_res_fa ];then
	extra_res_fa="-extra_res_fa $extra_res_fa"
fi

resfile=$af_path'/resfile/'rfpackpept.txt
flags=/home/arubenstein/git_repos/mean_field/scripts/enzflags

/home/arubenstein/Rosetta/main/source/bin/rosetta_scripts.static.linuxgccrelease -jd2:ntrials 1 -nstruct 20  -score:weights $score -out::prefix Job_${i} -parser:protocol $xml -database /home/arubenstein/Rosetta/main/database/ $extra_res_fa -s $pdb_path'/'$pdb'.pdb' -run:preserve_header -constraints:cst_file $pdb_path'/'$pdb'_sc.cst' -resfile $resfile $catcst @$flags > design.log 2>&1
