% Builds directories for all the runs
% Currently, will divide up jobs by the number of trials
% unless trials = 1, then it will divide it up by the number of
% parameters. This could be smarter, but it's currently
% better than nothing

function SetUpRunMaster()

%Find number of workers a pool can have.
if isempty(gcp)
  poolobj = parpool;
else
  poolobj = gcp(); % If no pool,  create new one.
end
AvailWorkers = poolobj.NumWorkers;

%Initialize the setup params
if exist('initsetupParams.m', 'file');
  initsetupParams
else
  cpmatparams
  initsetupParams
end

% Fix
if n_trials > 1
   n_trials = round( n_trials / AvailWorkers ) .* AvailWorkers;
   TrialsPerWorker = n_trials / AvailWorkers; % equal to trial chunk
   PossDirs = divisors( TrialsPerWorker );
   PossFilesInDir = TrialsPerWorker ./ PossDirs .* AvailWorkers ;

   [minPoss, indPoss] = min( abs( PossFilesInDir - FilesInDir ) );
   
   FilesInDir = PossFilesInDir( indPoss );
   NumDirsTr = n_trials ./ FilesInDir;
 else
   FilesInDir = round( FilesInDir/AvailWorkers ) * AvailWorkers;
   if FilesInDir == 0; FilesInDir = 1; end;
end

%Find how long everything is
nbe      = length( bind_energy_vec );
nffo     = length( ffrac_obst_vec );
nt       = n_trials;
nparams  = nbe * nffo;
nruns    = nbe * nffo * nt;

% random number for identifier
randnum = floor( 1000 * rand() );

fprintf('Let us make some dirs\n')
% One parameter per dir is nt is a multiple of the workers
if nt > 1
   
   %NumDirsTr = nt / Workers;
   NumDirs = nffo * nbe * NumDirsTr;
   RunIndVec = 1:FilesInDir;
   %WorkersVec = 1:Workers;
   
   for i = 1:nbe
      for j = 1:nffo
         for k = 1:NumDirsTr
            
            dirstr = sprintf('/Run%d_%d_%d/', ...
               randnum, trialind, k + (j-1)*NumDirsTr + (i-1)*NumDirsTr* nffo );
            dirpath = [RunDirPath dirstr];
            mkdir( dirpath );
            
            runIndTemp = (k-1) * FilesInDir + RunIndVec;
            %runIndTemp = (k-1) * Workers + WorkersVec;
            ntrialtemp = length(runIndTemp);
            beTemp     = bind_energy_vec(i);
            ffTemp     = ffrac_obst_vec(j);
            
      % Print parameters to stdout
            fprintf('\n%s:\n',dirstr)
            runstring = [ 'RunInds: ' int2str(runIndTemp) ];
            bestring = [ 'BE: ' num2str(beTemp) ];
            ffstring = [ 'FF: ' num2str(ffTemp) ];
            fprintf('%s \n',runstring);
            fprintf('%s \n',bestring);
            fprintf('%s \n',ffstring);
            
            changeparams_bindobs( beTemp, ffTemp, ntrialtemp,...
               trialind, runIndTemp(1) );
            
            movefile('Params.mat', dirpath);
            copyfile('*.m', dirpath);
            copyfile('*.sh', dirpath);
            
         end
      end
   end
   
   % nt < workers. nt = 1 because of rounding
else
   
   NumParamsPerDir = FilesInDir;
   ntrialtemp  = 1;
   runIndTemp  = 1;
   
   if ( mod( nbe, NumParamsPerDir )  <= mod( nffo, NumParamsPerDir ) )
      
      fprintf( 'Selecting Binding Energy \n' );
      beSelect = 1;
      NumDirBE  = floor( nbe / NumParamsPerDir ) ;
      NumDirFF  = nffo;
      ExtraDir  = 0;
      if mod( nbe, NumParamsPerDir ) ~= 0; ExtraDir = 1; end;
      
   else
      
      fprintf( 'Selecting FF \n' );
      beSelect = 0;
      NumDirFF  = floor( nffo / NumParamsPerDir ) ;
      NumDirBE  = nbe ;
      ExtraDir  = 0;
      if mod( nffo, NumParamsPerDir ) ~= 0; ExtraDir = 1; end;
   end % Find SelectVec
   
   %Number of dirs total
   NumDirs =  NumDirBE * NumDirFF;
   
   if ExtraDir; NumDirs = NumDirs + 1; end;
   
   for i = 1: NumDirBE
      for j = 1: NumDirFF
         dirstr = sprintf('/Run%d_%d_%d/', ...
            randnum, trialind, j + (i-1) * NumDirFF );
         dirpath = [RunDirPath dirstr];
         mkdir( dirpath );
         
         if beSelect
            beTemp = bind_energy_vec( 1 + (i-1) * NumParamsPerDir : i * NumParamsPerDir );
            ffTemp = ffrac_obst_vec(j);
         else
            beTemp = bind_energy_vec(i);
            ffTemp = ffrac_obst_vec( 1 + (j-1) * NumParamsPerDir : j * NumParamsPerDir);
            
         end % end beSelect
         
      % Print parameters to stdout
          fprintf('\n%s:\n',dirstr)
          runstring = [ 'RunInds: ' int2str(runIndTemp) ];
          bestring = [ 'BE: ' num2str(beTemp) ];
          ffstring = [ 'FF: ' num2str(ffTemp) ];
          fprintf('%s \n',runstring);
          fprintf('%s \n',bestring);
          fprintf('%s \n',ffstring);

         changeparams_bindobs( beTemp, ffTemp, ntrialtemp,...
            trialind, runIndTemp );
         movefile('Params.mat', dirpath);
         copyfile('*.m', dirpath);
         copyfile('*.sh', dirpath);
      end
   end
   
   if ExtraDir
      dirstr = sprintf('/Run%d_%d_%d/', ...
         randnum, trialind, 1+(NumDirBE-1)+(NumDirFF-1) + 1);
      dirpath = [RunDirPath dirstr];
      mkdir( dirpath );
      
      if beSelect
         beTemp = bind_energy_vec( NumDirBE * NumParamsPerDir  + 1:end);
         ffTemp = ffrac_obst_vec;
      else
         beTemp = bind_energy_vec;
         ffTemp = ffrac_obst_vec( NumDirFF * NumParamsPerDir + 1:end);
      end

      % Print parameters to stdout
          fprintf('\n%s:\n',dirstr)
          runstring = [ 'RunInds: ' int2str(runIndTemp) ];
          bestring = [ 'BE: ' num2str(beTemp) ];
          ffstring = [ 'FF: ' num2str(ffTemp) ];
          fprintf('%s \n',runstring);
          fprintf('%s \n',bestring);
          fprintf('%s \n',ffstring);

      changeparams_bindobs( beTemp, ffTemp, ntrialtemp,...
       trialind, runIndTemp );
      movefile('Params.mat', dirpath);
      copyfile('*.m', dirpath);
      copyfile('*.sh', dirpath);
   end % ExtraDir
   
end % nt > workers

% Delete pool
delete(poolobj);

