% Builds directories for all analysis

function SetUpAnalyzeMaster()
addpath('./src');

% Directory stuff
CurrentDir = pwd;

%Initialize the setup params
if exist('initAnalyzeParams.m', 'file');
   initAnalyzeParams
else
   cpmatparams
   initAnalyzeParams
end

%grab files
Files2Analyze = filelist( '.mat', './runfiles');
NumFilesTot = size(Files2Analyze,1);

% Only run if there are files to analyze
if NumFilesTot
   % Number of Dirs
   NumDirs = ceil( NumFilesTot / FilesInDir );
   
   fprintf('Analyzing %d files in %d dirs\n', NumFilesTot, NumDirs);
   % Print the filenames

   fprintf('Printing all files\n');
   for i = 1:NumFilesTot
     filename = Files2Analyze{i};
     fprintf('%s\n',filename);
   end
   
   % random number for identifier
   % Pick a random seed
   rng('shuffle');
   randnum = floor( 1000 * rand() );
   
   %% Not finished %%%
   for i = 1:NumDirs
      dirstr = sprintf('/AnalyzeMe%d_%.2d_%.2d', randnum, trial, i );
      dirpath = [RunDirPath dirstr];
      mkdir( dirpath );
      mkdir( [dirpath '/runfiles'] )

      % save seed
      seedShift = i;
      save('seed.mat','seedShift')
      
      FileStart = (i-1) * FilesInDir + 1;
      FileEnd = (i) * FilesInDir;
      if FileEnd > NumFilesTot; FileEnd = NumFilesTot; end;
      TotFilesInDir = ( FileEnd - FileStart ) + 1;
      
      fprintf('Moving %d files to %s\n', TotFilesInDir, dirstr);
      for j = 1:TotFilesInDir
         % Need to use strcat. I don't know why vector notation isn't working
         filename = Files2Analyze{ FileStart + (j-1) };
         sprintf('file: %s\n',filename);
         PathStart = [CurrentDir '/runfiles/' filename ];
         PathEnd =  [dirpath '/runfiles/' filename];
         %fprintf(' Moving %s to %s\n', PathStart, PathEnd );
         movefile( PathStart, PathEnd);
         movefile( 'seed.mat', dirpath );
         copyfile('./*.m', [dirpath] );
         copyfile('./*.sh', [dirpath] );
         copyfile('./src', [dirpath '/src/'] );
      end
      
   end % loop of dirs
else
   fprintf('Nothing to analyze\n');
end % if Num files

end %function

