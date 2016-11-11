% function analyze_bindobs(NumFiles2Analyze)
% MWS edited original analyze program written by MB and LH to be more general

% Get all the files you want to analyze
function analyze_bindobs(NumFiles2Analyze)
try
  addpath('./src');
  
  % Scramble and shift the seed
  s = rng('shuffle');
  if exist( 'seed.mat','file');
    load('seed.mat');
  else
    seedShift = 0;
  end
  rng( s.Seed + seedShift );
  
  if nargin == 0; NumFiles2Analyze = 1; end;
  
  tstart = tic;
  StartTime = datestr(now);
  fprintf('In analyze_bindobs, %s\n', StartTime);
  
  %Make sure it's not a string (bash)
  if isa(NumFiles2Analyze,'string');
    fprintf('You gave me a string, turning it to an int\n');
    NumFiles2Analyze = str2int('NumFiles2Analyze');
  end;
  
  %make output directories if they don't exist
  if exist('msdfiles','dir') == 0; mkdir('msdfiles');end;
  if exist('./runfiles/analyzing','dir') == 0; mkdir('./runfiles/analyzing');end;
  
  %grab files
  Files2Analyze = filelist( '.mat', './runfiles');
  NumFilesTot = size(Files2Analyze,1);
  
  %Fix issues if Numfiles is less than desired amount
  if NumFiles2Analyze > NumFilesTot;
    NumFiles2Analyze = NumFilesTot;
  end;
  
  % Move the files you want to analyze to an analyzing folder
  if NumFiles2Analyze;
    % Set-up a parpool that's cluster safe
    % No pool yet
    if isempty(gcp('nocreate') )
      fprintf('Creating pool\n')
      % Initiate a parcluster
      c = parcluster();
      % Create temporary directory to parpool data to go
      clustdir = tempname();
      mkdir(clustdir)
      c.JobStorageLocation = clustdir;
      % Pause for parpool (preventing race conditions) just in case
      tpause = 1 + 60*rand();
      fprintf( 'Pausing for %f \n', tpause );
      pause( tpause );
      parobj = parpool(c);
    else % Already pool
      fprintf('Pool exists\n')
      parobj = gcp;
      clustdir = parobj.Cluster.JobStorageLocation;
      mkdir(clustdir);
    end
    
    fprintf('I have hired %d workers\n',parobj.NumWorkers);
    fprintf('Temp cluster dir: %s\n', clustdir);
    
    % Move things to analyzing directory
    fprintf('Moving files to analyzing directory\n');
    for j=1:NumFiles2Analyze
      % Grab a file
      filename = Files2Analyze{j};
      movefile( ['./runfiles/' filename], ['./runfiles/analyzing/' filename] );
    end
    
    fprintf('Starting analysis\n');
    for j=1:NumFiles2Analyze
      
      % Grab a file
      filename = Files2Analyze{j};
      
      % Put all variables in a struct
      S = load( ['./runfiles/analyzing/' filename] );
      if S.const.trPosRecNoModFlag == 1
        %test calling msd function
        if isfield(S.const,'maxpts_msd') == 1 && isfield(S.const,'calcQuad') == 1
          [msd,dtime]=computeMSD(S.tracer_cen_rec_nomod, S.const.maxpts_msd, S.const.calcQuad);
        elseif isfield(S.const,'maxpts_msd') == 1 && isfield(S.const,'calcQuad') == 0
          [msd,dtime]=computeMSD(S.tracer_cen_rec_nomod, S.const.maxpts_msd, 0);
        elseif isfield(S.const,'maxpts_msd') == 0 && isfield(S.const,'calcQuad') == 1
          [msd,dtime]=computeMSD(S.tracer_cen_rec_nomod, 100, S.const.calcQuad);
        elseif isfield(S.const,'maxpts_msd') == 0 && isfield(S.const,'calcQuad') == 0
          [msd,dtime]=computeMSD(S.tracer_cen_rec_nomod, 100, 0);
        end
      else
        fprintf('Nothing to analyze\n');
      end
      %dtime doesn't take the record time into account, do fix it
      dtime = dtime * S.const.rec_interval;
      
      % Save it
      msdfilename=['msd_',filename(6:end)];

      if S.const.trackOcc
        S.occupancy = S.occupancy'; % transpose it so it fits format of msd
        msdsave(msdfilename, msd, dtime, S.const, S.modelopt, ...
          S.obst, S.paramlist, S.tracer, S.occupancy);
      else
        msdsave(msdfilename, msd, dtime, S.const, S.modelopt, ...
          S.obst, S.paramlist, S.tracer);
      end
      movefile(msdfilename, './msdfiles');
      delete( ['./runfiles/analyzing/' filename] );
      
    end %loop over files
  end %if analyzing
  % Clean up tmp
  delete( [clustdir '/*.mat' ] );
  delete( [clustdir '/*.txt' ] );
  if ~isempty( ls(clustdir) )
    tempDir = ls(clustdir);
    tempDir = tempDir( ~isspace( tempDir ) );
    delete( [clustdir '/' tempDir '/*' ] );
    rmdir( [clustdir '/' tempDir ] );
  end
  rmdir(clustdir);
  end_time = toc(tstart);
  fprintf('Finished analysis. Analyzed %d files in %.2g min\n', NumFiles2Analyze, end_time / 60);
catch err
  fprintf('%s',err.getReport('extended') );
end % try catch

%   HOW IT IS ALL DEFINED:
%         msd_distrib(dt,:) = [mean(squared_dis(:)); ... % average
%         std(squared_dis(:)); ...; % std
%         length(squared_dis(:)); ... % n (how many points used to compute mean)
%     	mean(quartic_dis(:)); ... %average
%     	std(quartic_dis(:))]'; %std
