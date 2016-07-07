% SetUpParamsTmpl
% 
% Parameter file for set-up run master

% Directory stuff
RunDirPath = '~/RunDir/McHydro';
FilesInDir = 4;
AvailWorkers = 4;

%trial indicator
trialind  = 1; 

%parameters to that are looped as be, ffob, trials
n_trials    = 1;
bind_energy_vec = [ 0 ] ;
ffrac_obst_vec= [ 0 ];         %filling fraction of obstacles
size_obj_vec = [ 1 ];

% Fix size issues
size_obj_vec( ~mod(size_obj_vec,2) ) = ...
  size_obj_vec(~mod(size_obj_vec,2) ) - 1; 
size_obj_vec = unique(size_obj_vec);
size_obj_vec = size_obj_vec( size_obj_vec <= ...
  round( max(params.ffrac_obst_vec) ^ (1/modelopt.dimension) * const.n_gridpoints ) );
if size_obj_vec == 0; size_obj_vec = 1; end;

