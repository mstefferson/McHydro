%% Grab multiple files to load


if ffo == 0
fileind = sprintf('msd_bar0_bind%d_fo%d_ft0.1_so1_st1_oe1_ng100_nt10000_nrec1000_t%d',...
binden, ffo, trialind );   
else
fileind = sprintf('msd_bar0_bind%d_fo%.1f_ft0.1_so1_st1_oe1_ng100_nt10000_nrec1000_t%d',...
binden, ffo, trialind );
end


% Grad some parameters
filetemp = [fileind '.' int2str(runstart) '.mat' ];
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

% All the data
dtimeM = zeros( recLength * NumFiles, 1 ); 
msdM   = zeros( recLength * NumFiles, 1 ); 
errorM = zeros( recLength * NumFiles, 1 ); 

% Average
dtimeAve = zeros(recLength, 1 );
msdAve   = zeros(recLength, 1);
numPtsT = zeros(recLength, 1);

DfitV   = zeros( NumFiles, 1 );
DsigV   = zeros( NumFiles, 1 );


masterIndstr = 1;
for i=1:NumFiles
   
  load(FileCell{i})
  % Measure D for run
  NrecPoints = round( length(dtime) );
  % Skip t = 1 because error is zero
  tInd = 2:NrecPoints;
  
  % Temporary vectors
  t_temp = dtime(tInd);
  msd_temp      = msd(tInd,2);
  nPts_temp   = msd(tInd,3);
  error_temp  = ( msd(tInd,2) ./ sqrt( nPts_temp ) ) ; % Column vector 
 
  % Calculate Dave from a weighted fit (poly1fitw uses matlab's fit.m)
  [Dave, Dsig, ~, ~] = poly1fitw( t_temp, msd_temp, error_temp, alphaFit );
  
  % Store it for weighted average  
  DfitV(i) = Dave;
  DsigV(i) = Dsig;

  % Store all the msd data for master plot. -2 because we skip t = 1 
  masterIndend = masterIndstr + NrecPoints - 2;
  
  % Master list
  dtimeM( masterIndstr:masterIndend  ) = t_temp;
  msdM( masterIndstr:masterIndend  ) = msd_temp;
  errorM( masterIndstr:masterIndend  ) = error_temp;
  
  % Average list. Sum everything up then divide by total points
  dtimeAve = dtimeAve + t_temp .* nPts_temp; % This is just a test
  msdAve   = msdAve + msd_temp .* nPts_temp;
  numPtsT = numPtsT + nPts_temp;
  masterIndstr = masterIndend + 1;

end

 % Calculate average;
 dtimeAve = dtimeAve ./ numPtsT;
 msdAve = msdAve ./ numPtsT;

 % Cut off zeros if there are any
  NotZeroInd = length( dtimeM ( dtimeM > 0 ) );
  dtimeM = dtimeM(1:NotZeroInd);
  msdM = msdM(1:NotZeroInd);
  errorM = errorM(1:NotZeroInd);
  
% Fit it
  [DaveFit, DsigFit, Shift, ~] = poly1fitw( dtimeM, msdM, errorM, alphaFit );
  [DaveW, DsigW] = wmean( DfitV, DsigV );
  DaveUw = mean(DfitV);
  DsigUw = std(DfitV);
  
  fprintf('Weighted: D = %.4g +/- %.4g\n', DaveW, DsigW);
  fprintf('Unweight: D = %.4g +/- %.4g\n', DaveUw, DsigUw);
  fprintf('Fit: D = %.4g +/- %.4g\n', DaveFit, DsigFit);

 
  % Plot it
  
  % Parameters
  ParamList1 = sprintf('ffo: %.1g BE = %.1g', ffo, binden);
  ParamList2 = sprintf('ntrials: %d', const.n_trials);
  
  ParamList3 = sprintf( ' ng: %d \n ntime: %d \n nrecint:%d \n randtimeptns: %d \n ntracer: %d\n',...
    const.n_gridpoints, const.ntimesteps, const.rec_chunk,...
    const.maxpts_msd,const.num_tracer);
  TitleStr1 = 'msd';
  TitleStr2 = ParamList1;
  TitleStr3 = ParamList1;
  
  Dstr1 =  sprintf('W: D = %.4f +/- %.2e', DaveW, DsigW);
  Dstr2 = sprintf('UW: D = %.4f +/- %.2e', DaveUw, DsigUw);
  Dstr3 =  sprintf('Fit: D = %.4f +/- %.2e', DaveFit, DsigFit);
  
  Dstr = sprintf('%s\n%s\n%s\n', Dstr1, Dstr2, Dstr3);

 
  %% Fig 1: scatter plot with fit and average vals with fit
  figure()
  savestr = sprintf('msdbe%.1foff%.1f.fig', binden, ffo);
  
  % All
  subplot( 2,2,1);
  scatter( dtimeM, msdM )
  hold all
  plot( dtimeM, Shift + DaveFit .* dtimeM )
  axis square
  xlabel('time'); ylabel('r^2')
  title( [TitleStr1 '(all)' ] )
  
  
  % Ave
  subplot( 2,2,2 )
  scatter( dtimeAve, msdAve )
  hold all
  plot( dtimeAve, Shift + DaveFit .* dtimeAve)
  axis square
  xlabel('time'); ylabel('r^2')
  title( [TitleStr2] )
  
  %Params
  subplot( 2, 2, 3)
  axis square
  text( 0.1, 0.5, Dstr )
  
    subplot( 2, 2, 4)
  axis square
  text( 0.1, 0.5, ParamList3 )
  % Save it
  savefig( savestr );
  
  %% Fig 2: log plots to show anomalous
  figure()
  savestr = sprintf('logbe%.1foff%.1f.fig', binden, ffo);
  
  subplot(2,1,1)
  loglog( dtimeAve, msdAve )
   xlabel('time'); ylabel('r^2')
  title( [TitleStr2 ': loglog msd vs time (avg)' ] )
  
  subplot(2,1,2)
  loglog( dtimeAve, msdAve./dtimeAve )
   xlabel('time'); ylabel('r^2/t')
  title( [TitleStr2 ': loglog msd/time vs time (avg)' ] )
  
  % Save it
  savefig( savestr );
  
  