% Builds directories for all analysis 

function SetUpAnalyzeMaster(DirInpt)

%Run dir Path
if nargin == 0
  RunDirPath = '~/RunDir/McHydro';
  if exist(RunDirPath,'dir') == 0; mkdir(RunDirPath); end;
else
RunDirPath = DirInpt;
end

%number of runs to split job over. Each goes it it's own directory
NumDir = 1;
trial  = 1; %trial indicator

% random number for identifier
randnum = floor( 1000 * rand() );

%% Not finished %%%
for i = 1:NumDir
  dirstr = sprintf('/Run%d_%d_%d/', randnum, trial, i );
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
  copyfile('*.sh', dirpath);

end


