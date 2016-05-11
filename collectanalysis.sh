# Bash executable
#!/bin/bash

# collectanalysis.sh:
# Collects analysis jobs form run directory. 
#
# Note: Currently doesn't check if they are done!

RunDirPath=~/RunDir/McHydro
HomeDir=`pwd`
DirStrName='Analyzed'

### Display the job context
echo "Starting run"
echo Running on host `hostname`
echo Time is `date`
echo Directory is `pwd`
echo "Collecting Data and deleting temporary directories"

cd $RunDirPath
echo "In dir `pwd` "

# Enable nullglob to short files in an array to see in
# ./runfiles is empty
for i in `ls | grep ^${DirStrName}`; 
  do 
  cd $i 
  echo "In dir `pwd` "
  # Check is there are files in ./runfiles.
  # if there are it's, not done
  # Store them in an array
  filesinrun=(./runfiles/*.mat);
  #If there is nothing in there, collect
  if [ "${#files[@]}" -eq "0" ]; then
    echo "Run finished. Collecting outputs"
    mv ./msdfiles/* $HomeDir/msdfiles
    cd ../
    rm -rf $i
  else
    echo "Still Running. Not collecting"
  fi
  #mv ./msdfiles/* $HomeDir/msdfiles
  cd ../ 
done

echo "Collected all finished data and deleted temporary directories"

exit

