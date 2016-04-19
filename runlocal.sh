#!/bin/bash
MATLAB=/Applications/MATLAB_R2015b.app/bin/matlab
echo "Starting run"
echo "In dir `pwd` "
$MATLAB -nodesktop -r "run_bindobs; exit;"
echo "Finished"
exit
