# Bash executable
#!/bin/bash

# On mac, give path to matlab
RunDirPath=~/RunDir/McHydro
HomeDir=`pwd`

### Display the job context
echo "Starting run"
echo Running on host `hostname`
echo Time is `date`
echo Directory is `pwd`
echo "Collecting Data and deleting temporary directories"

cd $RunDirPath
echo "In dir `pwd` "

for i in `ls`; 
  do 
  cd $i 
  echo "In dir `pwd` "
  mv ./runfiles/* $HomeDir/runfiles
  cd ../ 
  rm -rf $i
done
echo "Collected all data and deleted temporary directories"

exit

