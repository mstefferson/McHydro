%% Grab multiple files to load

alphaFit = 0.68;
trialind = 3;
fileind = ['./msdfiles/msd_bar0_bind0_fo0_ft0.1_so1_st1_oe1_ng100_nt10000_nrec10000_t' int2str(trialind) '.' ];
runstart = 1;
runend = 8;

% Grad some parameters
filetemp = [fileind int2str(runstart) '.mat' ];
load(filetemp);
recLength = length( dtime(2:end) );

% Get the files
sameParamFiles = ls( [fileind '*']);

Blanks = find( isspace( sameParamFiles ) );
NumFiles = length(Blanks);

% Add a 0 to start of blanks for first file. This helps with pulling
% out the file names in the upcoming for loop
Blanks = [0 Blanks];

% Make cell array to store these files names
FileCell = cell(NumFiles,1);

% Put all the files in the cell. Dance around the blanks
for i = 1:NumFiles
    FileCell{i} =  sameParamFiles( Blanks(i) + 1 : Blanks(i+1)-1 );
end



% Allocate memory for things
dtimeM = zeros( recLength * NumFiles, 1 ); 
msdM   = zeros( recLength * NumFiles, 1 ); 
errorM = zeros( recLength * NumFiles, 1 ); 
DfitV   = zeros( NumFiles, 1 );
DsigV   = zeros( NumFiles, 1 );


masterIndstr = 1;
for i=1:4
   
  load(FileCell{i})
  % Measure D for run
  NrecPoints = length(tInd);
  % Skip t = 1 because error is zero
  tInd = 2:NrecPoints;
  
  t_temp = dtime(tInd);
  msd_temp      = msd(tInd,2);
  error_temp  = ( msd(tInd,2) ./ sqrt( msd(tInd,3) ) ) ; % Column vector 
 
  [Dave, Dsig, ~, ~] = poly1fitw( t_temp, msd_temp, error_temp, alphaFit );
  
  % Store it for weighted average  
  DfitV(i) = Dave;
  DsigV(i) = Dsig;

  % Store all the msd data for master plot. -2 because we skip t = 1 
  masterIndend = masterIndstr + NrecPoints - 2;
  
  dtimeM( masterIndstr:masterIndend  ) = t_temp;
  msdM( masterIndstr:masterIndend  ) = msd_temp;
  errorM( masterIndstr:masterIndend  ) = error_temp;
  
  masterIndstr = masterIndend + 1;

end

  [DaveFit, DsigFit, ~, ~] = poly1fitw( dtimeM, msdM, errorM, alphaFit );
  [DaveW, DsigW] = wmean( DfitV, DsigV );

  fprintf('Weighted Ave: D = %.4g +/- %.4g\n', DaveW, DsigW);
  fprintf('Fit: D = %.4g +/- %.4g\n', DaveFit, DsigFit);
  
