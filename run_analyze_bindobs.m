% run_bindobs()
% Description: executeable that calls main body of model diffusion_model
% Program calls loads parameter file or calls initial parameter file if one
% doesn't exist yet, sets up parallelization, and moves outputs
%
% Authors: LEH, MDB, MWS

function run_analyze_bindobs()
try
  run_bindobs
  % Now analyze
  nparams = 1000;
  analyzeTimeID = tic;
  analyze_bindobs(nparams)
  analyzeTime = toc(analyzeTimeID);
  analyzeTimeSave = analyzeTime;
  analyzeHr = floor( analyzeTime / 3600); analyzeTime = analyzeTime - analyzeHr*3600;
  analyzeMin = floor( analyzeTime / 60);  analyzeTime = analyzeTime - analyzeMin*60;
  analyzeSec = floor(analyzeTime);

  totTime =  analyzeTimeSave + runTimeSave;
  totHr = floor( totTime / 3600); totTime = totTime - totHr*3600;
  totMin = floor( totTime / 60);  totTime = totTime - totMin*60;
  totSec = floor(totTime);
  % time times
  fprintf('AnalyzeTime: %.2d:%.2d:%.2d (hr:min:sec)\n', analyzeHr, analyzeMin, analyzeSec);
  movefile('StatusRunning.txt','StatusFinished.txt')
catch err
  fprintf('%s',err.getReport('extended') );
end % try catch
