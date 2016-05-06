%initialize parameters here and save it to a Params.mat
%allows for inputs
% called by SetUpRunMaster

function [] = changeparams_bindobs( beVec, ffoVec, numtrl, trlind, runind)

initparams;

%parameters in the inputs
params.bind_energy_vec = beVec;
params.ffrac_obst_vec= ffoVec;         %filling fraction of obstacles

%trial master
if nargin > 2
  const.n_trials         = numtrl;
  trialmaster.tind       = trlind;
  trialmaster.runstrtind = runind;
  trialmaster.nt         = const.n_trials; 
end

save('Params', 'const', 'params','trialmaster','modelopt')

end % function
