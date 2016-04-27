# Bash executable
#!/bin/bash

nfiles=5
if [ $# -eq 1 ];then
    nfiles=$1
fi

echo "Starting analysis. Trying to analyze $nfiles"
echo "In dir `pwd` "

matlab -nodesktop -nosplash \
  -r  "try, analyze_bindobs( $((nfiles)) ), catch, exit(1), end, exit(0);" \
  2>&1 | tee runbind.out

#matlab -nodesktop -nosplash \
#-r  "try, analyze_bindobs( 2 ), catch, exit(1), end, exit(0);" \
#2>&1 | tee analyzebind.out

echo "Finished. Matlab exit code: $?" 
exit
