# Bash executable
#!/bin/bash

# On mac, give path to matlab
MATLAB=/Applications/MATLAB_R2015b.app/bin/matlab
DIR=Dir1
PATH2DIR=~/WorkingDir/McHydro/$DIR/

echo "Starting run"
mkdir $PATH2DIR
cp ~/McHydro/*.m  $PATH2DIR
cd $PATH2DIR
echo "In dir `pwd` "
$MATLAB -nodesktop -nosplash -logfile matoutput.log \
  -r  "try, run_bindobs, catch, exit(1), end, exit(0);" 
echo "Finished. Matlab exit code: $?" 
echo "Moving files over"
mv ./runfiles/*.mat ~/McHydro/runfiles
mv ./*.log ~/McHydro/
cd ~/McHydro
echo "Deleting temp run directoty"
rm -r $PATH2DIR
exit
