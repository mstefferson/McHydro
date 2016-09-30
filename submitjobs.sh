# Bash executable
#!/bin/bash

# On mac, give path to matlab
RunDirPath=/scratch/Users/mist7261/McHydro
HomeDir=`pwd`
# Pick out all the dirs that begin with 'RunMe'
DirStrName='RunMe'
LengthDirStr=${#DirStrName}
NewDirName='Ran'

### Display the job context
echo Running on host `hostname`
echo Time is `date`
echo Directory is `pwd`

module load matlab_R2015b

echo "Starting run"
echo "In dir `pwd` "
echo "Making all directories"

# Run matlab program
matlab -nodesktop -nosplash \
  -r  "try, SetUpRunMaster, catch, exit(1), end, exit(0);"\
  2>&1 | tee makedir.out
 

echo  "Made Dirs. Matlab exit code: $?" 
cd $RunDirPath
echo "In dir `pwd` "
echo "Submitting jobs"

# For all the files that start with RunMe
for i in `ls | grep ^${DirStrName}`; do 
  # Get the file identifier
  indstr=${i:${LengthDirStr}}
  # Set new name
  newname=${NewDirName}${indstr}
  # Move file
  mv ./$i ./$newname
  # cd in and submit
  cd ${newname} 
  echo "In dir `pwd` "
  qsub runbindPBSpando.sh
  cd ../
done
echo "Submitted all jobs"

exit

