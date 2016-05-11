# Bash executable
#!/bin/bash

# Give some dir names and path variables
RunDirPath=~/RunDir/McHydro
HomeDir=`pwd`
# Pick out all the dirs that begin with 'RunMe'
# When running, move then to Run
DirStrName='AnalyzeMe'
LengthDirStr=${#DirStrName}
NewDirName='Analyzed'
NumFiles=1000;

echo "Starting run"
echo "In dir `pwd` "
echo "Making all directories"

matlab -nodesktop -nosplash \
  -r  "try, SetUpAnalyzeMaster, catch, exit(1), end, exit(0);" 

echo  "Made Dirs. Matlab exit code: $?" 
cd $RunDirPath
echo "In dir `pwd` "

# For all the files that start with RunMe
for i in `ls | grep ^${DirStrName}`; do 
    # Get the file identifier
    indstr=${i:${LengthDirStr}}
    # Set new name
    newname=${NewDirName}${indstr}
    # Move file
    mv ./$i ./$newname
      
    # cd in a run
    cd ${newname} 
    echo "In dir `pwd` "
    matlab -nodesktop -nosplash \
      -r  "try, analyze_bindobs(${NumFiles}), catch, exit(1), end, exit(0);" \
      2>&1 | tee analyzelog.out

    echo "Finished. Matlab exit code: $?" 
    mv ./msdfiles/* $HomeDir/msdfiles
    mv analyzelog.out $HomeDir/analyzelog.out
    cd ../ 
    rm -rf ${newname}
done

exit
