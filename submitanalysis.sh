# Bash executable
#!/bin/bash

# submitanalysis.sh submits all the analysis jobs to the cluster.
# First, it runs SetUpAnalysisMaster which creates all the analysis directories
# under the name AnalyzeMe*. Once the job it submitted, it moves them to
# Analyzed*. An Analyzed folder can in a running or finished state.

RunDirPath=/scratch/Users/mist7261/McHydro
HomeDir=`pwd`
# Pick out all the dirs that begin with 'AnalyzeMe'
DirStrName='AnalyzeMe'
LengthDirStr=${#DirStrName}
NewDirName='Analyzed'

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
  jobName=ab;
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
  -r  "try, SetUpAnalyzeMaster, catch, exit(1), end, exit(0);"\
  2>&1 | tee analdir.out

echo  "Made Analysis dirs. Matlab exit code: $?" 
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
    # submit!
  if [ $jobFlag -eq 1 ]
  then
    if [ $mailFlag -eq 0 ]
    then
      echo "qsub -N $jobName abPBSpando.sh"
      qsub -N $jobName abPBSpando.sh
    else
      echo "qsub -N $jobName abMailPBSpando.sh"
      qsub -N $jobName abMailPBSpando.sh
    fi
  else
    echo "qsub abPBSpando.sh"
    qsub abPBSpando.sh
  fi
  cd ../
done
echo "Submitted all jobs"

exit
