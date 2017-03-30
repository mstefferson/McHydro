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

# Variables from inputs
if [ $# -le 0 ]
then
  echo "no jobname or mail flag given"
  jobFlag=0;
  mailFlag=0;
  jobName=rb;
elif [ $# -eq 1 ]
then
  jobFlag=1;
  mailFlag=0;
  jobName=$1;
  echo "jobname is $jobName"
  echo "no mail flag given"
else
  jobFlag=1;
  jobName=$1;
  mailFlag=$2;
  # Make sure you don't duplicate directories
  echo "jobname is $jobName"
  echo "mail flag=$mailFlag;"
fi

echo "Starting run"
echo "In dir `pwd` "
echo "Making all directories"

# Run matlab program
module load matlab_R2015b
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
  newname=${NewDirName}_${jobName}_${indstr}
  # Move file
  mv ./$i ./$newname
  # cd in and submit
  cd ${newname} 
  echo "In dir `pwd` "
  # pause for random number generator
  sleep 1
  # submit!
  if [ $jobFlag -eq 1 ]
  then
    if [ $mailFlag -eq 0 ]
    then
      echo "qsub -N $jobName rbPBSpando.sh"
      qsub -N $jobName rbabPBSpando.sh
    else
      echo "qsub -N $jobName rbMailPBSpando.sh"
      qsub -N $jobName rbabMailPBSpando.sh
    fi
  else
    echo "qsub rbPBSpando.sh"
    qsub rbabPBSpando.sh
  fi
  cd ../
done
echo "Submitted all jobs"

exit
