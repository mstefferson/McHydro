% Builds directories for all the runs 

function SetUpRunMaster(DirInpt)

%number of runs to split job over. Each goes it it's own directory
trial  = 2; %trial indicator

%parameters to that are looped as be, ffob, trials
const.n_trials    = 4;
bind_energy_vec = [1 0];
ffrac_obst_vec= [ 1  2 3];         %filling fraction of obstacles


%Run dir Path
if nargin == 0
  RunDirPath = '~/RunDir/McHydro';
  if exist(RunDirPath,'dir') == 0; mkdir(RunDirPath); end;
else
RunDirPath = DirInpt;
end

%Find number of workers a pool can have
poolobj = gcp('nocreate'); % If no pool, do not create new one.
if isempty(poolobj)
    Workers = 0;
else
    Workers = poolobj.NumWorkers;
end



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
% groupsize = nffo * nbe; % Number of parameter configurations. files/dir 
% gsdivsors = divisors(groupsize); % # files/dir needs to be divisor of groupsize
% gsmult    =  groupsize * (1:nruns); % or a multiple
% possbinsize = [ gsdivsors(1:end-1) gsmult  ];
% binsizetemp = nruns / NumDir;
% [~, binind] = min( abs( binsizetemp - possbinsize ) );
% binsize = possbinsize( binind );
% NumDir  = nruns / binsize;

% We the number of runs in a dir to be equal to the workers
NumDir = ceil( nruns / Workers );

% random number for identifier
randnum = floor( 1000 * rand() );

%% Not finished %%%
for i = 1:NumDir
  dirstr = sprintf('/Run%d_%d_%d/', randnum, trial, i );
  dirpath = [RunDirPath dirstr];
  mkdir( dirpath );

  if i < NumDir
    runIndTemp = unique( param_mat( 1 + Workers * (i-1) : Workers * i, 1 ) );
    beTemp     = unique( param_mat( 1 + Workers * (i-1) : Workers * i, 2 ) );
    ffTemp     = unique( param_mat( 1 + Workers * (i-1) : Workers * i, 3 ) ); 
  else
    runIndTemp = unique( param_mat( 1 + Workers * (i-1) : end, 1 ) );
    beTemp     = unique( param_mat( 1 + Workers * (i-1) : end, 2 ) );
    ffTemp     = unique( param_mat( 1 + Workers * (i-1) : end, 3 ) ); 
 end

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
  copyfile('*.sh', dirpath);

end




