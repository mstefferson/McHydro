%initialize parameters here and save it to a Params.mat
%allows for inputs

function [] = paramsinpt_bindobs( beVec, ffoVec, numtrl, trlind, runind)

paramsinit_bindobs;

%parameters in the inputs
bind_energy_vec = beVec;
ffrac_obst_vec= ffoVec;         %filling fraction of obstacles
params.bind_energy_vec = bind_energy_vec;
params.ffrac_obst_vec = ffrac_obst_vec;

%trial master
const.n_trials   = numtrl;
trial.tind       = trlind;
trial.runstrtind = runind;
trial.nt         = const.n_trials;


save('Params')

end % function
