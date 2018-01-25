# Basic sample run on local machine
1) Change parameters in initParams.m
2) To run a simulation, run run_bindobs()
  - Outputs go to runfiles
3) To analyze runs (calculate msd), analyze_bindobs(n)
  -n: # of files you want to analyze
  -Outputs go to msdfiles
(Note, you can combine steps 2) and 3) by running run_analyze_bindobs()
4) To average over grids, averageMSDgrids( ffo, bind, bDiff, sizeObs, parentpath, nameID, bindDirFlag )
  -put all the runs you want to average in the same dir,
    Figure out what filling fractions, binding energies, size, bound diffusion
    you want to average over. 
   -Say it's just ff = 0.1, be = 0, size = 1, bD = 0. 
      -If they are all in ./msdfiles, you'd run 
      >> averageMSDgrids( 0.1, 0, 0, 1, 'msdfiles/', 'test', 0 )

  -If you put them in ./msdfiles/bind00,
      >> averageMSDgrids( 0.1, 0, 0, 1, 'msdfiles/', 'test', 1 )
  -outputs go into gridAveMSDdata/
5) To calculate Diffusion coefficients, etc, run
  -[masterD, asymInfo] = getDfromGridAveAsymp( path2files, fileId, ...
  numBins, threshold, plotFlag, saveFigFlag, verbose )
  -Currently uses getHorzAsymptotes which was not what was used in the paper (findHorztlAsymp was)
  
collectjobs.sh: Goes to run directory, collects all finshed run jobs, and put
them in working directory.

submitanalysis.m: Calls  SetUpAnalysisMaster which takes all files in ./runfiles, 
  and puts them in run directories in the run directory. Next, it submits 
  analysis_bindobs jobs for them. 

SetUpAnalysisMaster: sets up run directories for analysis. It takes all files in ./runfiles,
  and puts them in run directories in the run directory. It calls
  initAnalyzeParams where you can edit the run directory path, number of files 
  in a directory, and a trial indicator for identify the job.

