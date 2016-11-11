% run_analyze_bindobs()
% Description: executeable that calls main body of model diffusion_model
% Program calls loads parameter file or calls initial parameter file if one
% doesn't exist yet, sets up parallelization, and moves outputs
% Runs analysis immeditaly after running
%
% Authors: LEH, MDB, MWS

function run_bindobs()
try
  addpath('./src');
  StartTime = datestr(now);
  currentdir=pwd;
  fprintf('In dir %s\n',currentdir);
  fprintf('In run_bindobs, %s\n', StartTime);

  % Allocate params
  params = struct();
  trialmaster = struct();
  const = struct();
  modelopt = struct();
  
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
    initParams
  end
  load Params.mat;
  
  % Scramble and shift the seed
  s = rng('shuffle');
  rng( s.Seed + trialmaster.seedShift );

  %display everything
  fprintf('parameters read in\n');
  disp(trialmaster); disp(params); disp(const); disp(modelopt);
  
  %build a parameter matrix
  nbe      = length( params.bind_energy_vec );
  nffo     = length( params.ffrac_obst_vec );
  nsizeobs = length( params.size_obst );
  nt       = const.n_trials;
  nparams  = nbe * nffo * nsizeobs * nt;
  %param matrix.  (:,1) = run ID (:,2) = binding (:,3) = ffrc obs
  param_mat = zeros( nparams, 4 );
  for i = 1:nt
    for j = 1:nbe
      for k = 1:nffo
        for l = 1:nsizeobs
          rowind = 1 + (i-1) + (j-1) * nt + (k-1) * nt * nbe + ...
            (l-1) * nt * nbe * nffo;
          param_mat( rowind, 1 ) = (i-1) + trialmaster.runstrtind;
          param_mat( rowind, 2 ) = params.bind_energy_vec(j);
          param_mat( rowind, 3 ) = params.ffrac_obst_vec(k);
          param_mat( rowind, 4 ) = params.size_obst(l);
        end
      end
    end
  end
  
  % For some reason, param_mat gets "sliced". Create vectors to get arround
  % this
  param_RunID   = param_mat(:,1);
  param_bind    = param_mat(:,2);
  param_ffo     = param_mat(:,3);
  param_sizeobs = param_mat(:,4);
  
  fprintf('Starting paramloop \n')
  fprintf('nparams = %d\n', nparams)
  RunTimeID = tic;
  
  if nparams > 1
    fprintf('Using parfor to run diffusion model\n');
    % Set-up a parpool that's cluster safe
    % No pool yet
    if isempty(gcp('nocreate') )
      fprintf('Creating pool\n')
      % Initiate a parcluster
      c = parcluster();
      % Create temporary directory to parpool data to go
      clustdir = tempname();
      mkdir(clustdir)
      c.JobStorageLocation = clustdir;
      % Pause for parpool (preventing race conditions) just in case
      tpause = 1 + 60*rand();
      fprintf( 'Pausing for %f \n', tpause );
      pause( tpause );
      parobj = parpool(c);
    else % Already pool
      fprintf('Pool exists\n')
      parobj = gcp;
      clustdir = parobj.Cluster.JobStorageLocation;
      mkdir(clustdir);
    end
    
    fprintf('I have hired %d workers\n',parobj.NumWorkers);
    fprintf('Temp cluster dir: %s\n', clustdir);
    
    parfor j=1:nparams
      RunID       = param_RunID(j);
      bind_energy = param_bind(j);
      ffrac_obst  = param_ffo(j);
      size_obst   = param_sizeobs(j);
      
      pvec=[params.ffrac_tracer, ...
        params.tr_unbnd_hop_energy, params.tr_bnd_hop_energy,...
        ffrac_obst, bind_energy, size_obst]; %parameter vector
      
      filestring=['unBbar',num2str(params.tr_unbnd_hop_energy),...
        '_Bbar',num2str(params.tr_bnd_hop_energy),...
        '_bind',num2str(bind_energy),...
        '_fo',num2str(ffrac_obst,'%.2f'),'_ft',num2str(params.ffrac_tracer,'%.2f'),...
        '_so',num2str(size_obst),'_st',num2str(const.size_tracer),...
        '_oe',num2str(modelopt.obst_excl),'_ng',...
        num2str(const.n_gridpoints),'_nt',num2str(const.ntimesteps),...
        '_nrec', num2str(const.NrecTot),...
        '_t', num2str(trialmaster.tind,'%.2d'),'.',num2str(RunID,'%.2d') ];
      filename=['data_',filestring,'.mat'];
      fprintf('%s\n',filename);
      
      %run the model!
      [~,~] = diffusion_model(pvec,const,modelopt,filename);
      movefile(filename,'./runfiles');
    end
    % Clean up tmp
    delete( [clustdir '/*.mat' ] );
    delete( [clustdir '/*.txt' ] );
    if ~isempty( ls(clustdir) )
      tempDir = ls(clustdir);
      tempDir = tempDir( ~isspace( tempDir ) );
      delete( [clustdir '/' tempDir '/*' ] );
      rmdir( [clustdir '/' tempDir ] );
    end
    rmdir(clustdir);
  else
    fprintf('Running diffusion model once\n');
    RunID       = param_RunID(1);
    bind_energy = param_bind(1);
    ffrac_obst  = param_ffo(1);
    size_obst   = param_sizeobs(1);
    
    pvec=[params.ffrac_tracer, ...
      params.tr_unbnd_hop_energy, params.tr_bnd_hop_energy,...
      ffrac_obst, bind_energy, size_obst]; %parameter vector
    
    filestring=['unBbar',num2str(params.tr_unbnd_hop_energy),...
      '_Bbar',num2str(params.tr_bnd_hop_energy),...
      '_bind',num2str(bind_energy),...
      '_fo',num2str(ffrac_obst,'%.2f'),'_ft',num2str(params.ffrac_tracer,'%.2f'),...
      '_so',num2str(size_obst),'_st',num2str(const.size_tracer),...
      '_oe',num2str(modelopt.obst_excl),'_ng',...
      num2str(const.n_gridpoints),'_nt',num2str(const.ntimesteps),...
      '_nrec', num2str(const.NrecTot),...
      '_t', num2str(trialmaster.tind,'%.2d'),'.',num2str(RunID,'%.2d') ];
    
    filename=['data_',filestring,'.mat'];
    fprintf('%s\n',filename);
    
    %run the model!
    [~,~] = diffusion_model(pvec,const,modelopt,filename);
    fprintf('Finished %s \n', filename);
    movefile(filename,'./runfiles');
  end %if nparams > 1
  runTime = toc(RunTimeID);
  runTimeSave = runTime;
  runHr = floor( runTime / 3600); runTime = runTime - runHr*3600;
  runMin = floor( runTime / 60);  runTime = runTime - runMin*60;
  runSec = floor(runTime);
  EndTime = datestr(now);
  fprintf('Completed run: %s\n',EndTime);
  fclose('all');
  movefile('Params.mat','ParamsLastRun.mat');

  % Now analyze
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
  fprintf('RunTime: %.2d:%.2d:%.2d (hr:min:sec)\n', runHr, runMin, runSec);
  fprintf('AnalyzeTime: %.2d:%.2d:%.2d (hr:min:sec)\n', analyzeHr, analyzeMin, analyzeSec);
  fprintf('TotalTime: %.2d:%.2d:%.2d (hr:min:sec)\n', totHr, totMin, totSec);
  movefile('StatusRunning.txt','StatusFinished.txt')
 
catch err
  fprintf('%s',err.getReport('extended') );
end % try catch
