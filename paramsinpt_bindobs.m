%initialize parameters here and save it to a Params.mat
%allows for inputs

function [] = paramsinpt_bindobs( beVec, ffoVec, trl)

paramsinit_bindobs;

%parameters in the inputs
bind_energy_vec = beVec;
ffrac_obst_vec= ffoVec;         %filling fraction of obstacles
const.n_trials    = trl;

params.bind_energy_vec = bind_energy_vec;
params.ffrac_obst_vec = ffrac_obst_vec;

save('Params')

end % function
