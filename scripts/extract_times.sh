#!/bin/bash

path=$1


tail -n 4 $path'/'cleaved1_1'.log' | head -n 1 | awk '{print $1}' 
tail -n 4 $path'/'cleaved5_sort_1'.log' | head -n 1 | awk '{print $1}'
tail -n 4 $path'/'cleaved10_sort_1'.log' | head -n 1 | awk '{print $1}'
tail -n 4 $path'/'cleaved_1'.log' | head -n 1 | awk '{print $1}'

