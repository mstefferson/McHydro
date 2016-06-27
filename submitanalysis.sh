# Bash executable
#!/bin/bash

# submitanalysis.sh submits all the analysis jobs to the cluster.
# First, it runs SetUpAnalysisMaster which creates all the analysis directories
# under the name AnalyzeMe*. Once the job it submitted, it moves them to
# Analyzed*. An Analyzed folder can in a running or finished state.

RunDirPath=~/RunDir/McHydro
HomeDir=`pwd`
# Pick out all the dirs that begin with 'AnalyzeMe'
DirStrName='AnalyzeMe'
LengthDirStr=${#DirStrName}
NewDirName='Analyzed'

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
  newname=${NewDirName}${indstr}
  # Move file
  mv ./$i ./$newname
  # cd in and submit
  cd ${newname} 
  echo "In dir `pwd` "
  qsub analyzebindPBS.sh
  cd ../
done
echo "Submitted all jobs"

exit

