# Bash executable
#!/bin/bash

RunDirPath=/scratch/Users/mist7261/McHydro
HomeDir=`pwd`
DirStrName='Ran'

### Display the job context
echo "Starting run"
echo Running on host `hostname`
echo Time is `date`
echo Directory is `pwd`
echo "Collecting Data and deleting temporary directories"

cd $RunDirPath
echo "In dir `pwd` "

for i in `ls | grep ^${DirStrName}`; 
  do 
  cd $i 
  echo "In dir `pwd` "
  if [ -f StatusFinished.txt ]; then
    echo "Run finished. Collecting outputs"
    mv ./runfiles/* $HomeDir/runfiles
    cd ../ 
    rm -rf $i
  else
    echo "Still Running. Not collecting"
  cd ../
  fi
done

echo "Collected all finished data and deleted temporary directories"

exit

