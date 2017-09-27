% run_bindobs()
% Description: executeable that calls main body of model diffusion_model
% Program calls loads parameter file or calls initial parameter file if one
% doesn't exist yet, sets up parallelization, and moves outputs
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
  
  %  Run status
  !touch StatusRunning.txt
  
  %make output directories if they don't exist
  if exist('./runfiles','dir') == 0; mkdir('./runfiles') ;end
  
  %load params. check if it exists, if not, run it, then delete it
  %initparams on tracked, so make it if it's not there
  if exist('Params','file') == 0
    if exist('initParams','file') == 0
      cpmatparams
    end
    initParams
  end
  load Params.mat;
  movefile('Params.mat','ParamsRunning.mat');
  
  % Scramble and shift the seed
  % first, paused base on input seed, then scramble
  if trialmaster.parforFlag
    rng( trialmaster.seedShift );
    rand1 = rand();
    tpause = 10 .* rand1;
    pause( tpause );
    fprintf('Pausing for %f before shuffling\n', tpause );
    rng('shuffle');
    rand2 = rand();
    const.rand1 = rand1;
    const.rand2 = rand2;
    fprintf('rand1 = %f rand2 = %f (before after shuffle)\n', rand1, rand2 );
  end
  
  %display everything
  fprintf('parameters read in\n');
  disp(trialmaster); disp(params); disp(const); disp(modelopt);
  
  % run obstacle manager
  [obstObj] =  obstManager( params.obst, modelopt );
  params.obst = obstObj.param;
  %build a parameter matrix
  runVec = trialmaster.runstrtind + (0:trialmaster.nt-1);
  param_mat = combvec( runVec, obstObj.inds);
  [~,nparams] = size(param_mat);
  paramRun = param_mat(1,:);
  paramObst = param_mat(2,:);
  fprintf('Starting paramloop \n')
  fprintf('nparams = %d\n', nparams)
  runTimeID = tic;
  % eliminate broadcast warning
  num_tracer = params.num_tracer;
  tr_unbnd_diff = params.tr_unbnd_diff;
  size_tracer = const.size_tracer;
  n_gridpoints = const.n_gridpoints;
  dim = const.dim;
  ntimesteps =  const.ntimesteps;
  NrecTot = const.NrecTot;
  tind = trialmaster.tind;
  obstParam = obstObj.param;
  % set-up str
  obstStr = cell(1, nparams);
  for ii = 1:nparams
    obstStr{ii} = obstObj.str{ paramObst(ii) };
  end
  allowPlaceTracerObst = modelopt.place_tracers_obst;
  if nparams > 1 && trialmaster.parforFlag
    parforFlag = 1;
    fprintf('Using parfor to run diffusion model\n');
    % turn off animation and movie
    modelopt.animate = 0;
    modelopt.movie = 0;
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
    numWorkers = parobj.NumWorkers;
  else
    parforFlag = 0;
    fprintf('Not using parfor\n')
    numWorkers = 0;
  end
  parfor (j=1:nparams, numWorkers)
    %   for j=1:nparams
    % scramble rng in parfor! It's rng is indepedent on ML's current state
    if parforFlag
      pause(j);
      rng('shuffle');
      fprintf('Parfor j = %d Rand num = %f \n', j, rand() );
    end
    % grab parameters
    runIdTemp = paramRun(j);
    paramObstTemp = paramObst(j);
    %parameter cell
    pvec= [num_tracer, tr_unbnd_diff paramObstTemp ];
    % file string
    filestring=['unD',num2str(tr_unbnd_diff),...
      obstStr{j}, ...
      '_ntrcr',num2str(num_tracer,'%d'),'_st',num2str(size_tracer),...
      '_pto', num2str( allowPlaceTracerObst, '%d' ),...
      '_ng',num2str(n_gridpoints),...
      '_dim', num2str(dim),'_nt',num2str(ntimesteps),...
      '_nrec', num2str(NrecTot),...
      '_t', num2str(tind,'%.2d'),'.',num2str(runIdTemp,'%.2d') ];
    filename=['data_',filestring,'.mat'];
    fprintf('%s\n',filename);
    %run the model!
    [~,~] = diffusion_model(pvec, const, modelopt, obstParam, filename);
    movefile(filename,'./runfiles');
  end
  % Clean up tmp
  if parforFlag
    delete( [clustdir '/*.mat' ] );
    delete( [clustdir '/*.txt' ] );
    if ~isempty( ls(clustdir) )
      tempDir = ls(clustdir);
      tempDir = tempDir( ~isspace( tempDir ) );
      delete( [clustdir '/' tempDir '/*' ] );
      rmdir( [clustdir '/' tempDir ] );
    end
    rmdir(clustdir);
  end
  runTime = toc(runTimeID);
  runHr = floor( runTime / 3600); runTime = runTime - runHr*3600;
  runMin = floor( runTime / 60);  runTime = runTime - runMin*60;
  runSec = floor(runTime);
  fprintf('RunTime: %.2d:%.2d:%.2d (hr:min:sec)\n', runHr, runMin,runSec);
  EndTime = datestr(now);
  fprintf('Completed run: %s\n',EndTime);
  fclose('all');
  movefile('StatusRunning.txt','StatusFinished.txt')
  movefile('ParamsRunning.mat','ParamsLastRun.mat');
catch err
  fprintf('%s',err.getReport('extended') );
end % try catch
