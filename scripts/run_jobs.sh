#!/bin/bash

bb_samp_dir=$1

nohup ./run_rmsd_list.sh ..'/'$bb_samp_dir'/'GraB_1/ list_cleaved_1 GraB &
nohup ./run_rmsd_list.sh ..'/'$bb_samp_dir'/'GraB_1/ list_50.txt GraB &
nohup ./run_rmsd_list.sh ..'/'$bb_samp_dir'/'HIVn_1/ list_cleaved_1 HIVn &
nohup ./run_rmsd_list.sh ..'/'$bb_samp_dir'/'HIVn_1/ list_50.txt HIVn &
nohup ./run_rmsd_list.sh ..'/'$bb_samp_dir'/'1LVB_1/ list_cleaved_1 1LVB &
nohup ./run_rmsd_list.sh ..'/'$bb_samp_dir'/'1LVB_1/ list_50.txt 1LVB &
nohup ./run_rmsd_list.sh ..'/'$bb_samp_dir'/'3M5L_1/ list_cleaved_1 3M5L &
nohup ./run_rmsd_list.sh ..'/'$bb_samp_dir'/'3M5L_1/ list_50.txt 3M5L &
