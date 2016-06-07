collectjobs.sh: Goes to run directory, collects all finshed run jobs, and put
them in working directory.

submitanalysis.m: Calls  SetUpAnalysisMaster which takes all files in ./runfiles, 
  and puts them in run directories in the run directory. Next, it submits 
  analysis_bindobs jobs for them. 

SetUpAnalysisMaster: sets up run directories for analysis. It takes all files in ./runfiles,
  and puts them in run directories in the run directory. It calls
  initAnalyzeParams where you can edit the run directory path, number of files 
  in a directory, and a trial indicator for identify the job.

