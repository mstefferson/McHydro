% SetUpParamsTmpl
% 
% Parameter file for set-up run master

% Directory stuff
RunDirPath = '~/RunDir/McHydro';
FilesInDir = 12;
AvailWorkers = 12;

%trial stuff indicator
n_trials    = 36;
trialind     = 5; 
runstrtid    = 13;

%bind_energy_vec = [ -4 4 Inf];
%ffrac_obst_vec= [ 0.1:0.2:0.9];         %filling fraction of obstacles
bind_energy_vec = [0];
ffrac_obst_vec= [ 0 ];         %filling fraction of obstacles
