%initialize parameters here and save it to a Params.mat
%allows for inputs
% called by SetUpRunMaster

function [] = changeparams_bindobs( beVec, ffoVec, soVec, numtrl, trlind, runind)

if exist('Params.mat','file') == 0 ; 
  fprintf('No params yet, running initparams \n');
  if exist('initparams.m','file') == 0; cpmatparams; end;
  initParams; 
else
  load('Params.mat');
end;

%trial master
if nargin > 3
  const.n_trials         = numtrl;
  trialmaster.tind       = trlind;
  trialmaster.runstrtind = runind;
  trialmaster.nt         = const.n_trials; 
end

%parameters in the inputs
params.bind_energy_vec = beVec;
params.ffrac_obst_vec= ffoVec;         %filling fraction of obstacles
params.size_obst = soVec;

% Fix size issues
params.size_obst( ~mod(params.size_obst,2) ) = ...
  params.size_obst(~mod(params.size_obst,2) ) - 1; 
params.size_obst = unique(params.size_obst);
params.size_obst = params.size_obst( params.size_obst <= ...
  round( max(params.ffrac_obst_vec) ^ (1/modelopt.dimension) * const.n_gridpoints ) );
if isempty(params.size_obst); params.size_obst = 1; end;

const.size_tracer( ~mod(const.size_tracer,2) ) = ...
  const.size_tracer(~mod(const.size_tracer,2) ) - 1; 
const.size_tracer = unique(const.size_tracer);
const.size_tracer = const.size_tracer( const.size_tracer <= ...
  round( max(params.ffrac_tracer) ^ (1/modelopt.dimension) * const.n_gridpoints ) );
if isempty(const.size_tracer); const.size_tracer = 1; end;

% Number of particles on the grid
const.num_tracer = round(params.ffrac_tracer .* ...
  (const.n_gridpoints/const.size_tracer) ^ modelopt.dimension);

save('Params', 'const','params','trialmaster','modelopt')

end % function
