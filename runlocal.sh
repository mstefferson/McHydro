# Bash executable
#!/bin/bash

# On mac, give path to matlab
MATLAB=/Applications/MATLAB_R2015b.app/bin/matlab
echo "Starting run"
echo "In dir `pwd` "
$MATLAB -nodesktop -nosplash -logfile output.log \
  -r  "try, run_bindobs, catch, exit(1), end, exit(0);" 
echo "Finished. Matlab exit code: $?" 
exit
