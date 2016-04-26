%initialize parameters here and save it to a Params.mat
%allows for inputs

function [] = changeparams_bindobs( beVec, ffoVec, numtrl, trlind, runind)

initparams_bindobs;

%parameters in the inputs
bind_energy_vec = beVec;
ffrac_obst_vec= ffoVec;         %filling fraction of obstacles
params.bind_energy_vec = bind_energy_vec;
params.ffrac_obst_vec = ffrac_obst_vec; %#ok<STRNU>

%trial master
const.n_trials         = numtrl;
trialmaster.tind       = trlind;
trialmaster.runstrtind = runind;
trialmaster.nt         = const.n_trials; %#ok<STRNU>

save('Params')

end % function