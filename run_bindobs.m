%   MDB 9/28/15 specialized to immobile obstacles, noninteracting tracers
%   so that moves can be done in parallel
%   MDB 9/28/15 set up to loop over parameters with parfor
%  LEH vary binding energies, with each file having a different filling
%  fraction
% MWS made edits to wrapper function to avoid having to copy and paster things

%tic;
% clear all;
%close all;
try
  addpath('./src');
  rng('shuffle');
  StartTime = datestr(now);
  currentdir=pwd;
  fprintf('In dir %s\n',currentdir);
  fprintf('In run_bindobs, %s\n', StartTime);

  % Check run status
  if exist('StatusRunning.txt','file') ~= 0; 
  %     error('Code is already running in directory');
  elseif exist('StatusFinished.txt','file') ~= 0; 
      movefile('StatusFinished.txt','StatusRunning.txt');
  else
      fopen('StatusRunning.txt','w'); 
  end

  %make output directories if they don't exist
  if exist('./runfiles','dir') == 0; mkdir('./runfiles') ;end;

  %load params. check if it exists, if not, run it, then delete it
  %initparams on tracked, so make it if it's not there
  if exist('Params.mat','file') == 0;
      if exist('initparams.m','file') == 0;
          cpmatparams
      end;
      initparams
  end
  load Params.mat;

  %display everything
  fprintf('parameters read in\n');
  disp(trialmaster); disp(params); disp(const); disp(modelopt);

  %build a parameter matrix
  nbe      = length( params.bind_energy_vec );
  nffo     = length( params.ffrac_obst_vec );
  nt       = const.n_trials;
  nparams  = nbe * nffo * nt;
  %param matrix.  (:,1) = run ID (:,2) = binding (:,3) = ffrc obs
  param_mat = zeros( nparams, 3 );
  for i = 1:nt
      for j = 1:nbe
          for k = 1:nffo
              rowind = k + nffo * (j-1) + nffo * nbe * (i - 1);
              param_mat( rowind, 1 ) = (i-1) + trialmaster.runstrtind;
              param_mat( rowind, 2 ) = params.bind_energy_vec(j);
              param_mat( rowind, 3 ) = params.ffrac_obst_vec(k);
          end
      end
  end

  % For some reason, param_mat gets "sliced". Create vectors to get arround
  % this
  param_RunID = param_mat(:,1);
  param_bind  = param_mat(:,2);
  param_ffo   = param_mat(:,3);

  fprintf('Starting paramloop \n')
  fprintf('nparams = %d\n', nparams)
  RunTimeID = tic;

  if nparams > 1
    fprintf('Using parfor to run diffusion model\n');
    parfor j=1:nparams
      RunID       = param_RunID(j);
      bind_energy = param_bind(j);
      ffrac_obst  = param_ffo(j);
      
      pvec=[ffrac_obst params.ffrac_tracer params.slide_barr_height bind_energy]; %parameter vector
      
      filestring=['bar',num2str(params.slide_barr_height),'_bind',num2str(bind_energy),...
          '_fo',num2str(ffrac_obst),'_ft',num2str(params.ffrac_tracer),'_so',...
          num2str(const.size_obst),'_st',num2str(const.size_tracer),...
          '_oe',num2str(modelopt.obst_excl),'_ng',...
          num2str(const.n_gridpoints),'_nt',num2str(const.ntimesteps),...
          '_nrec', num2str(const.NrecTot),...
          '_t', num2str(trialmaster.tind),'.',num2str(RunID) ];
      filename=['data_',filestring,'.mat'];
      fprintf('%s\n',filename);
      
      %run the model!
      [tracer,obst] = diffusion_model(pvec,const,modelopt,filename);
      movefile(filename,'./runfiles');
    end
  else
    fprintf('Running diffusion model once\n');
    RunID       = param_RunID(1);
    bind_energy = param_bind(1);
    ffrac_obst  = param_ffo(1);
    
    pvec=[ffrac_obst params.ffrac_tracer params.slide_barr_height bind_energy]; %parameter vector
    
    filestring=['bar',num2str(params.slide_barr_height),'_bind',num2str(bind_energy),...
        '_fo',num2str(ffrac_obst),'_ft',num2str(params.ffrac_tracer),'_so',...
        num2str(const.size_obst),'_st',num2str(const.size_tracer),...
        '_oe',num2str(modelopt.obst_excl),'_ng',...
        num2str(const.n_gridpoints),'_nt',num2str(const.ntimesteps),...
        '_nrec', num2str(const.NrecTot),...
        '_t', num2str(trialmaster.tind),'.',num2str(RunID) ];
    filename=['data_',filestring,'.mat'];
    fprintf('%s\n',filename);
    
    %run the model!
    [tracer,obst] = diffusion_model(pvec,const,modelopt,filename);
    fprintf('Finished %s \n', filename);
    movefile(filename,'./runfiles');
  end %if nparams > 1
  RunTime = toc(RunTimeID);
  fprintf('Run time %.2g min\n', RunTime / 60);
  EndTime = datestr(now);
  fprintf('Completed run: %s\n',EndTime);
  fclose('all');
  movefile('StatusRunning.txt','StatusFinished.txt')
  movefile('Params.mat','ParamsLastRun.mat');
catch err
 fprintf('%s',err.getReport('extended') );
end % try catch


