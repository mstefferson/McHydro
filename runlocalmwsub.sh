# Bash executable
#!/bin/bash

# On mac, give path to matlab

echo "Starting run"
echo "In dir `pwd` "
matlab -nodesktop -nosplash \
  -r  "try, run_bindobs, catch, exit(1), end, exit(0);" \
  2>&1 | tee runbind.out

echo "Finished. Matlab exit code: $?" 
exit
