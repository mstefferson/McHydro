% Builds directories for all the runs %

%number of runs to split job over. Each goes it it's own directory
NumRuns = 4;

%parameters to that are looped as be, ffob, trials
const.n_trials    = 3;
bind_energy_vec = [1 6];
ffrac_obst_vec= [ 0.2 0.3 ];         %filling fraction of obstacles

%build a parameter matrix
nbe      = length( bind_energy_vec );
nffo     = length( ffrac_obst_vec );
nt       = const.n_trials;
nparams  = nbe * nffo * nt;
%param matrix.  (:,1) = trial (:,2) = binding (:,3) = ffrc obs
param_mat = zeros( nparams, 3 );
for i = 1:nt
    for j = 1:nbe
        for k = 1:nffo
            rowind = k + nffo * (j-1) + nffo * nbe * (i - 1);
            param_mat( rowind, 1 ) = i;
            param_mat( rowind, 2 ) = bind_energy_vec(j);
            param_mat( rowind, 3 ) = ffrac_obst_vec(k);  
        end
    end
end

% Build directories with parameter files in them

pdInd = ceil( nparams / NumRuns );

for i = 1:NumRuns
  dirstr = ['dirRun' i ];
  mkdir(dirstr);
  if i ~= NumRuns
    trTemp = param_mat( 1 + pdInd * (i-1) : pdInd * i, 1 ) 
    beTemp = param_mat( 1 + pdInd * (i-1) : pdInd * i, 2 ) 
    ffTemp = param_mat( 1 + pdInd * (i-1) : pdInd * i, 3 ) 
  else
    trTemp = param_mat( 1 + pdInd * (i-1) : end , 1 ) 
    beTemp = param_mat( 1 + pdInd * (i-1) : end , 2 ) 
    ffTemp = param_mat( 1 + pdInd * (i-1) : end , 3 ) 
  end

  paramsinpt_bindobs( beTemp, ffTemp, trTemp );
  movefile('Params.mat',dirstr);
  copyfile('*.m', dirstr);

end

