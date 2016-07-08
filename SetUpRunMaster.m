% Builds directories for all the runs
% Currently, will divide up jobs by the number of trials
% unless trials = 1, then it will divide it up by the number of
% parameters. This could be smarter, but it's currently
% better than nothing

function SetUpRunMaster()

addpath('./src')

% AvailWorkers set by a parameter now in initSetUpParams

%Initialize the setup params
if exist('initSetupParams.m', 'file');
  initSetupParams
else
  cpmatparams
  initSetupParams
end

% Fix
if n_trials > 1
  n_trials = round( n_trials / AvailWorkers ) .* AvailWorkers;
  TrialsPerWorker = n_trials / AvailWorkers; % equal to trial chunk
  PossDirs = divisors( TrialsPerWorker );
  PossFilesInDir = TrialsPerWorker ./ PossDirs .* AvailWorkers ;
  
  [~, indPoss] = min( abs( PossFilesInDir - FilesInDir ) );
  
  FilesInDir = PossFilesInDir( indPoss );
  NumTrDir = round(n_trials ./ FilesInDir); %Number of trial per dir
else
  FilesInDir = round( FilesInDir/AvailWorkers ) * AvailWorkers;
  if FilesInDir == 0; FilesInDir = 1; end;
end

%Find how long everything is
nbe      = length( bind_energy_vec );
nffo     = length( ffrac_obst_vec );
nso      = length( size_obj_vec ) ;
nt       = n_trials;
nparams  = nbe * nffo * nso;

% random number for identifier
% Pick a random seed
rng shuffle
randnum = floor( 1000 * rand() );

fprintf('Let us make some dirs\n')
% One parameter per dir is nt is a multiple of the workers
if nt > 1
  for i = 1:nbe
    for j = 1:nffo
      for k = 1:nso
        for l = 1:NumTrDir
          
          dirstr = sprintf('/RunMe%d_%d_%d/', ...
            randnum, trialind, l + (k-1)*NumTrDir +...
            (j-1) * NumTrDir * nso + (i-1) * NumTrDir * nso * nffo);
          dirpath = [RunDirPath dirstr];
          mkdir( dirpath );
          
          runIndTemp = (l-1) * NumTrDir+ runstartind;
          beTemp     = bind_energy_vec(i);
          ffTemp     = ffrac_obst_vec(j);
          soTemp     = size_obj_vec(k);
          
          % Print parameters to stdout
          ntstring = [ 'Num trials: ' num2str(beTemp) ];
          runstring = [ 'RunInds: ' int2str(runIndTemp) ];
          bestring = [ 'BE: ' num2str(beTemp) ];
          ffstring = [ 'FF: ' num2str(ffTemp) ];
          sostring = [ 'SO: ' num2str(soTemp) ];
          
          fprintf('\n%s:\n',dirstr);    
          fprintf('%s \n',ntstring);
          fprintf('%s \n',runstring);
          fprintf('%s \n',bestring);
          fprintf('%s \n',ffstring);
          fprintf('%s \n',sostring);
          
          % change parameters and move everything
          changeparams_bindobs( beTemp, ffTemp, soTemp,NumTrDir,...
            trialind, runIndTemp );
          
          moveandcopy(dirpath)
          
        end
      end
    end
  end
  
  % nt < workers. nt = 1 because of rounding
else
  
  NumParamsPerDir = FilesInDir;
  ntrialtemp  = 1;
  runIndTemp  = 1;
  
  [~, minind] = min( ...
    [ mod(nbe,NumParamsPerDir) mod(nffo, NumParamsPerDir) ...
    mod(nso, NumParamsPerDir) ] );
  
  % Pick BE to be the vector variable
  if minind == 1
    fprintf( 'Selecting Binding Energy \n' );
    beSelect = 1;
    ffSelect = 0;
    soSelect = 0;
    NumDirBE  = ceil( nbe / NumParamsPerDir ) ;
    NumDirFF  = nffo;
    NumDirSO  = nso;
  elseif minind == 2
    fprintf( 'Selecting FF \n' );
    beSelect = 0;
    ffSelect = 1;
    soSelect = 0;
    NumDirFF  = ceil( nffo / NumParamsPerDir ) ;
    NumDirBE  = nbe ;
    NumDirSO  = nso;
  else
    fprintf( 'Selecting obs \n' );
    beSelect = 0;
    ffSelect = 0;
    soSelect = 1;
    NumDirSO  = ceil( nso / NumParamsPerDir ) ;
    NumDirBE  = nbe ;
    NumDirFF  = nffo;
  end % Find SelectVec
  
  %Number of dirs total
  NumDirs =  NumDirBE * NumDirFF * NumDirSO;
  
  % For now, throw leftovers in extra dir. This could be a lot,
  % and needs to be fixed when I have time/
  
  for i = 1: NumDirBE
    for j = 1: NumDirFF
      for k = 1: NumDirSO
        dirstr = sprintf('/RunMe%d_%d_%d/', ...
          randnum, trialind, k + (j-1) * NumDirSO + (i-1) * NumDirSO * NumDirFF );
        dirpath = [RunDirPath dirstr];
        mkdir( dirpath );
        
        if beSelect
          if i ~= NumDirBE
            beTemp = ...
              bind_energy_vec( 1 + (i-1) * NumParamsPerDir : i * NumParamsPerDir );
          else
            beTemp = ...
              bind_energy_vec( 1 + (i-1) * NumParamsPerDir : end );
          end
          ffTemp = ffrac_obst_vec(j);
          soTemp = size_obj_vec(k);
        elseif ffSelect
          beTemp = bind_energy_vec(i);
          if j ~= NumDirFF
            ffTemp = ...
              ffrac_obst_vec( 1 + (j-1) * NumParamsPerDir : j * NumParamsPerDir);
          else
            ffTemp = ...
              ffrac_obst_vec( 1 + (j-1) * NumParamsPerDir: end );
          end
          soTemp = size_obj_vec(k);
        else
          beTemp = bind_energy_vec(i);
          ffTemp = ffrac_obst_vec(j);
          if k ~= NumDirSO
            soTemp = ...
              size_obj_vec(1 + (k-1) * NumParamsPerDir: k * NumParamsPerDir);
          else
            soTemp = ...
              size_obj_vec(1 + (k-1) * NumParamsPerDir: k * NumParamsPerDir);
          end
        end % end beSelect
        
        % Print parameters to stdout
        fprintf('\n%s:\n',dirstr)
        runstring = [ 'RunInds: ' int2str(runIndTemp) ];
        bestring = [ 'BE: ' num2str(beTemp) ];
        ffstring = [ 'FF: ' num2str(ffTemp) ];
        sostring = [ 'SO: ' num2str(soTemp) ];
        fprintf('%s \n',runstring);
        fprintf('%s \n',bestring);
        fprintf('%s \n',ffstring);
        fprintf('%s \n',sostring);
        % change parameters and move everything
        changeparams_bindobs( beTemp, ffTemp, soTemp, ntrialtemp,...
          trialind, runIndTemp );
        moveandcopy(dirpath)
      end
    end
  end
  
  
end % nt > workers

end % main function

function moveandcopy(dirpath)

movefile('Params.mat', dirpath)
copyfile('*.m', dirpath);
copyfile('*.sh', dirpath);
copyfile('./src', [dirpath 'src']);

end %moveandcopy

