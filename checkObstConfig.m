try
  addpath('./src');
  StartTime = datestr(now);
  currentdir=pwd;
  fprintf('In dir %s\n',currentdir);
  fprintf('In checkObstConfig, %s\n', StartTime);
  
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
  
  %display everything
  fprintf('parameters read in\n');
  disp(trialmaster); disp(params); disp(const); disp(modelopt);

  % force animate and dimension to 2
  modelopt.animate = 1;
  const.dim = 2;
  
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
 for j=1:nparams
    % scramble rng in parfor! It's rng is indepedent on ML's current state
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
    [~,~] = setupAndAnimate(pvec, const, modelopt, obstParam, filename);
    movefile(filename,'./runfiles');
  end
  runTime = toc(runTimeID);
  runHr = floor( runTime / 3600); runTime = runTime - runHr*3600;
  runMin = floor( runTime / 60);  runTime = runTime - runMin*60;
  runSec = floor(runTime);
  fprintf('RunTime: %.2d:%.2d:%.2d (hr:min:sec)\n', runHr, runMin,runSec);
  EndTime = datestr(now);
  fprintf('Completed animation: %s\n',EndTime);
  fclose('all');
  movefile('StatusRunning.txt','StatusFinished.txt')
  movefile('ParamsRunning.mat','ParamsLastRun.mat');
catch err
  fprintf('%s',err.getReport('extended') );
end % try catch
