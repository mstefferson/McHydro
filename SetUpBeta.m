% Set-up run beta test

%number of runs to split job over. Each goes it it's own directory
trial  = 1; %trial indicator

Workers  = 4;

%parameters to that are looped as be, ffob, trials
const.n_trials    = 1;
bind_energy_vec = [ 1 2 3 4 6 7 ] ;
ffrac_obst_vec= [ 5 6 7 8 9];         %filling fraction of obstacles


% Fix
if const.n_trials > 1
  const.n_trials = round( const.n_trials / Workers ) .* Workers;
end

%Find number of workers a pool can have.
%poolobj = gcp(); % If no pool,  create new one.
%Workers = poolobj.NumWorkers;

%build a parameter matrix
nbe      = length( bind_energy_vec );
nffo     = length( ffrac_obst_vec );
nt       = const.n_trials;
nparams  = nbe * nffo;
nruns    = nbe * nffo * nt;

groupsize   = Workers;
gsdivsors   = divisors(groupsize);
gsmult      = groupsize * (2:nruns);
possTrials = [ gsdivsors gsmult  ];

% random number for identifier
randnum = floor( 1000 * rand() );

% One parameter per dir is nt is a multiple of the workers
if nt >= Workers
  
  NumDirSt = nt / Workers;
  NumDirs = nffo * nbe * NumDirSt;
  WorkersVec = 1:Workers;
  
  for i = 1:nbe
    for j = 1:nffo
      for k = 1:NumDirSt
        
        dirstr = sprintf('/Run%d_%d_%d/', ...
          randnum, trial, 1+(i-1)+(j-1)+(k-1) );
        %mkdir( dirpath );
        
        runIndTemp = (k-1) * Workers + WorkersVec
        beTemp     = bind_energy_vec(i)
        ffTemp     = ffrac_obst_vec(j)
        
        length( runIndTemp ) * length( beTemp ) * length( ffTemp )
      end
    end
  end
  
  % nt < workers
else
  
  NumParamsPerDir = Workers/nt;
  
  if mod( nbe, NumParamsPerDir ) == 0
    
    beSelect = 1;
    NumDirBE  = nbe / NumParamsPerDir ;
    NumDirFF  = nffo;
    ExtraDir  = 0;
    
  elseif mod( nffo, NumParamsPerDir ) == 0
    
    beSelect = 0;
    NumDirFF  = nffo / NumParamsPerDir ;
    NumDirBE  = nbe ;
    ExtraDir  = 0;
    % Just pick the biggest one
  else
    if nbe >= nffo
      beSelect = 1;
      NumDirBE  = floor( nbe / NumParamsPerDir ) ;
      NumDirFF  = nffo;
      ExtraDir  = 1;
    else
      beSelect = 0;
      NumDirFF  = floor( nffo / NumParamsPerDir ) ;
      NumDirBE  = nbe;
      ExtraDir  = 1;
    end
  end % Find SelectVec
  
  NumDirNt = 1;
  
  NumDirs = NumDirNt * NumDirBE * NumDirFF;
  if ExtraDir; NumDirs = NumDirs + 1; end;
  
  for i = 1: NumDirBE
    for j = 1: NumDirFF
      for k = 1:NumDirNt
        dirstr = sprintf('/Run%d_%d_%d/', ...
          randnum, trial, 1+(i-1)+(j-1)+(k-1) );
        
        runIndTemp = 1:nt;
        
        if beSelect
            beTemp = bind_energy_vec( 1 + (i-1) * NumParamsPerDir : i * NumParamsPerDir );
          ffTemp = ffrac_obst_vec(j);
        else
          beTemp = bind_energy_vec(i);
          ffTemp = ffrac_obst_vec( 1 + (j-1) * NumParamsPerDir : j * NumParamsPerDir);

        end % end beSelect
        
        beTemp
        ffTemp
        runIndTemp
        length( runIndTemp ) * length( beTemp ) * length( ffTemp ) 
      end
    end
  end
  
  if ExtraDir
    if beSelect
      beTemp = bind_energy_vec( NumDirBE * NumParamsPerDir  + 1:end)
      ffTemp = ffrac_obst_vec
      runIndTemp = 1:nt
    else
      beTemp = bind_energy_vec
      ffTemp = ffrac_obst_vec( NumDirFF * NumParamsPerDir + 1:end)
      runIndTemp = 1:nt
    end
  end
  
end % nt > workers


% See if we can divide up in terms of BE

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
