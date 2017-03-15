#!/bin/bash

pdb=$1

nohup ./run_mf_list.sh $pdb /home/arubenstein/mean_field/pdbs/backrub'/'$pdb'_1/'list_25.txt backrubpepta 1 talaris2013 talaris2013 &
nohup ./run_mf_list.sh $pdb /home/arubenstein/mean_field/pdbs/backrub'/'$pdb'_1/'list_10.txt backrubpepta 1 talaris2013 talaris2013 &

nohup ./run_mf_list.sh $pdb /home/arubenstein/mean_field/pdbs/flexpepdock'/'$pdb'_1/'list_25.txt flexpepdocka 1 talaris2013 talaris2013 &
nohup ./run_mf_list.sh $pdb /home/arubenstein/mean_field/pdbs/flexpepdock'/'$pdb'_1/'list_10.txt flexpepdocka 1 talaris2013 talaris2013 &

exit

nohup ./run_mf_list.sh $pdb /home/arubenstein/mean_field/pdbs/enum_dihedral'/'$pdb'_1/50_clusters/'list_50_clusters.txt enum_dihedrala 1 talaris2013 talaris2013 &
nohup ./run_mf_list.sh $pdb /home/arubenstein/mean_field/pdbs/enum_dihedral'/'$pdb'_1/5_clusters/'list_5_clusters.txt enum_dihedrala 1 talaris2013 talaris2013 &

exit
nohup ./run_mf_list.sh $pdb /home/arubenstein/mean_field/pdbs/backrub/protein'/'$pdb'_1/'list_backrub_50.txt backrubprota 1 talaris2013 talaris2013 &
nohup ./run_mf_list.sh $pdb /home/arubenstein/mean_field/pdbs/backrub/protein'/'$pdb'_1/'list_backrub_5.txt backrubprota 1 talaris2013 talaris2013 &
nohup ./run_mf_list.sh $pdb /home/arubenstein/mean_field/pdbs/backrub/protein'/'$pdb'_1/'list_backrub_1.txt backrubprota 1 talaris2013 talaris2013 &

