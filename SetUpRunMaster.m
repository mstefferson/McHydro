% Builds directories for all the runs %

%Run dir Path
RunDirPath = '~/RunDir/McHydro/';

%number of runs to split job over. Each goes it it's own directory
NumDir = 3;
trial  = 5; %trial indicator

%parameters to that are looped as be, ffob, trials
const.n_trials    = 3;
bind_energy_vec = [1 6];
ffrac_obst_vec= [ 0.2 0.3 ];         %filling fraction of obstacles

%build a parameter matrix
nbe      = length( bind_energy_vec );
nffo     = length( ffrac_obst_vec );
nt       = const.n_trials;
nparams  = nbe * nffo;
nruns    = nbe * nffo * nt;

%param matrix.  (:,1) = trial (:,2) = binding (:,3) = ffrc obs
param_mat = zeros( nruns, 3 );
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
groupsize = nffo * nbe; % Number of parameter configurations. files/dir 
gsdivsors = divisors(groupsize); % # files/dir needs to be divisor of groupsize
gsmult    =  groupsize * (1:nruns); % or a multiple
possbinsize = [ gsdivsors(1:end-1) gsmult  ];
binsizetemp = nruns / NumDir;
[~, binind] = min( abs( binsizetemp - possbinsize ) );
binsize = possbinsize( binind );
NumDir  = nruns / binsize;

% random number for identifier
randnum = floor( 1000 * rand() );

%% Not finished %%%
for i = 1:NumDir
  dirstr = sprintf('Run%d_%d_%d/', randnum, trial, i );
  dirpath = [RunDirPath dirstr];
  mkdir( dirpath );

  runIndTemp = unique( param_mat( 1 + binsize * (i-1) : binsize * i, 1 ) );
  beTemp     = unique( param_mat( 1 + binsize * (i-1) : binsize * i, 2 ) );
  ffTemp     = unique( param_mat( 1 + binsize * (i-1) : binsize * i, 3 ) ); 
  
  % number of trials for each dir is the number of run ind in each
  % parameter mat
  ntrialtemp = length( runIndTemp );
  fprintf('%s:\n',dirstr);
  fprintf('RunInds:\n'); disp(runIndTemp'); 
  fprintf('binding energy:\n'); disp(beTemp');
  fprintf('ff obs:\n'); disp(ffTemp');
  
  changeparams_bindobs( beTemp, ffTemp, ntrialtemp,...
      trial, runIndTemp(1) );
  
  movefile('Params.mat', dirpath);
  copyfile('*.m', dirpath);

end

