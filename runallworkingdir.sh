# Bash executable
#!/bin/bash

# On mac, give path to matlab
RunDirPath=~/RunDir/McHydro
HomeDir=`pwd`

echo "Starting run"
echo "In dir `pwd` "
echo "Making all directories"

matlab -nodesktop -nosplash -logfile diroutput.log \
-r  "try, SetUpRunMaster, catch, exit(1), end, exit(0);" 

echo "Made Directories running executeables"
cd $RunDirPath
echo "In dir `pwd` "

for i in `ls`; 
  do 
  cd $i 
  echo "In dir `pwd` "
  matlab -nodesktop -nosplash -logfile runoutput.log \
  -r  "try, run_bindobs, catch, exit(1), end, exit(0);" 
  echo "Finished. Matlab exit code: $?" 
  cp ./runfiles/* $HomeDir/runfiles
  cd ../ 
  rm -rf $i
done

exit
