# Bash executable
#!/bin/bash

# On mac, give path to matlab
RunDirPath=~/RunDir/McHydro
HomeDir=`pwd`

### Display the job context
echo Running on host `hostname`
echo Time is `date`
echo Directory is `pwd`

module load matlab_R2015b
cd /Users/mist7261/McHydro

echo "Starting run"
echo "In dir `pwd` "
echo "Making all directories"

# Run matlab program
matlab -nodesktop -nosplash \
  -r  "try, SetUpRunMasterDirInpt('$RunDirPath'), catch, exit(1), end, exit(0);" \
2>&1 | tee makedir.out

echo "Made Directories running executeables"
cd $RunDirPath
echo "In dir `pwd` "

for i in `ls`; 
  do 
  cd $i 
  echo "In dir `pwd` "
  qsub runbindPBS.sh
  cd ../
done
echo "Submitted all jobs"

exit

