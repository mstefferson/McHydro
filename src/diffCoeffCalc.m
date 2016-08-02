%% Grab multiple files to load
function [Dstruct] = diffCoeffCalc( filename, timestart, plotflag, ...
  verbose, saveFlag )


if nargin == 1
  timestart = 1;
  plotflag  = 1;
  verbose = 0;
  saveFlag = 0;
elseif nargin == 2
  plotflag  = 1;
  verbose = 0;
  saveFlag = 0;
elseif nargin == 3
  verbose = 0;
  saveFlag = 0;
elseif nargin == 4
  saveFlag = 0;
end

% Grab some parameters
load(filename);

% Find all the files
fileId = filename( 1: strfind( filename, '_t' ) + 2);
if verbose
  fprintf('Analyzing all files begining with \n%s\n', fileId );
end
SameParamFiles = filelist( fileId, pwd);
NumFiles = length(SameParamFiles);

% Check for paramlist. Old files didn't have this, it was saved
% as paramvec
if exist('paramlist','var')
  ffoM = paramlist.ffo;
  bindenM = paramlist.be;
elseif exist('paramvec','var' )
  ffoM = paramvec(1);
  bindenM = paramvec(4);
else
  error('I cannot find any parameters');
end

% Non-linear fitting
%fitfunction = @(c0,xdata) c0(1) + c0(2) .* xdata + c0(3) .* log(xdata);
%fitguess = [0 1 - ffoM 0];

% keyboard
% Find Index closest to desired start time. Don't start
% at  t = 1 since the uncertainty it zero. This messes
% up weighted fit (weight = inf)
totTpnts = length(dtime);
[~, tstartInd] = min( abs ( timestart - dtime ) );
if tstartInd == 1; tstartInd = 2; end;
timestart = dtime(tstartInd);
recLength = totTpnts - tstartInd + 1;
totTpntsOld = totTpnts; % See if loaded record lengths are changing
tInd = tstartInd:totTpnts;

% Allocate memory for things
% All the data
dtimeM = zeros( recLength * NumFiles, 1 );
msdM   = zeros( recLength * NumFiles, 1 );
errorM = zeros( recLength * NumFiles, 1 );
masterIndstr = 1; % Storing index

% Store data that isn't fitted for plotting
if plotflag == 1
  tIndNf     = 1: (tstartInd - 1);
  dtimeNfM   = zeros( (tstartInd - 1 ) * NumFiles, 1 );
  msdNfM     = zeros( (tstartInd - 1 ) * NumFiles, 1 );
  dtimeAveNf =  dtime( tIndNf  ) ;
  msdAveNf   = zeros( (tstartInd - 1 ), 1 );
  NfPtsTot   = zeros( (tstartInd - 1 ), 1 );
  NfIndstr   = 1; % Storing index
end

% Average
dtimeAveF = dtime( tInd );
msdAveF   = zeros(recLength, 1);
FpntsTot = zeros(recLength, 1);

DfitV   = zeros( NumFiles, 1 );
DsigV   = zeros( NumFiles, 1 );

DfitVuw   = zeros( NumFiles, 1 );
DsigVuw   = zeros( NumFiles, 1 );

if NumFiles == 0
  error('I am not analyzing anything')
end

for i=1:NumFiles
  
  load(SameParamFiles{i})
  
  totTpnts = length( dtime );
  if totTpnts ~= totTpntsOld; error('Record lengths changing'); end;
  
  % Make sure the parameter are the same
  if exist('paramlist','var')
    ffoTemp = paramlist.ffo;
    bindTemp = paramlist.be;
  elseif exist('paramvec','var')
    ffoTemp = paramvec(1);
    bindTemp = paramvec(4);
  else
    error('I cannot find any parameters');
  end
  
  if ( abs(ffoTemp - ffoM) > 1e-15 ) || ( bindTemp ~= bindenM );
    if ~isinf(bindTemp) && ~isinf(bindenM)
      keyboard
      error('Parameters have changed');
    end
  end
  
  % Measure D for run
  % Temporary vectors
  t_temp      = dtime(tInd);
  msd_temp    = msd(tInd,2);
  nPts_temp   = msd(tInd,3);
  %error_temp  = ( msd(tInd,2) ./ sqrt( nPts_temp ) ) ; % Column vector
  error_temp  =  msd(tInd,2) ; % Column vector
  
  %Make sure nothing is broken
  if isinf( msd_temp )
    error('msd is infinite')
  end
  % Record points not in fit if plotting
  if plotflag
    NfIndend = NfIndstr + tstartInd - 2;
    dtimeNfM(NfIndstr:NfIndend) = dtime( tIndNf ) ;
    msdNfM(NfIndstr:NfIndend)    = msd( tIndNf , 2 );
    msdAveNf   = msdAveNf + msd(tIndNf,2) .*  msd(tIndNf,3);
    NfPtsTot   = NfPtsTot + msd(tIndNf,3);
  end
  
  % Calculate Dave from a weighted fit (poly1fitw uses matlab's fit.m)
  %[Dave, Dsig, Shift, ~] = poly1fitw( t_temp, msd_temp, error_temp, alphaFit );
  %fitcoeff = lsfLin( t_temp, msd_temp, error_temp );
  %Dave = fitcoeff.Coeff(2);
  %Dsig = fitcoeff.StdErrProp( 2 );
  %DfitV(i) = Dave;
  %DsigV(i) = Dsig;

  
  %% Store it for weighted average
  [coeffsW, coeffsig] = nlDiffFit( t_temp, msd_temp, error_temp );

  DfitV(i) = coeffsW(2);
  DsigV(i) = coeffsig(2);
 
  [coeffsW, coeffsig] = nlDiffFit( t_temp, msd_temp );

  DfitVuw(i) = coeffsW(2);
  DsigVuw(i) = coeffsig(2);

  % Non linear fitting
  %Coeffs = lsqcurvefit(fitfunction,fitguess,t_temp,msd_temp);
  %DfitV(i) = Coeffs(2);
  %DsigV(i) = 0;
  
  
  % Store all the msd data for master plot. -2 because we skip t = 1
  masterIndend = masterIndstr + recLength - 1;
  
  % Master list
  dtimeM( masterIndstr:masterIndend  ) = t_temp;
  msdM( masterIndstr:masterIndend  ) = msd_temp;
  errorM( masterIndstr:masterIndend  ) = error_temp;
  
  % Average list. Sum everything up then divide by total points
  msdAveF   = msdAveF + msd_temp .* nPts_temp;
  FpntsTot = FpntsTot + nPts_temp;
  masterIndstr = masterIndend + 1;
  
  totTpntsOld = totTpnts;
end

% Calculate average;
msdAveF = msdAveF ./ FpntsTot;
if plotflag
  msdAveNf   = msdAveNf ./ NfPtsTot;
end
% Cut off zeros if there are any. There should be though...
NotZeroInd = length( dtimeM ( dtimeM > 0 ) );
dtimeM = dtimeM(1:NotZeroInd);
msdM = msdM(1:NotZeroInd);
errorM = errorM(1:NotZeroInd);

% Fit it
%[Dfit, DsigFit, ~, ~] = poly1fitw( dtimeM, msdM, errorM, alphaFit );
%fitcoeff = lsfLin( dtimeM, msdM, errorM );
%Dfit = fitcoeff.Coeff(2);
%DsigFit = fitcoeff.StdErrProp( 2 );
%Shift = fitcoeff.Coeff(1);

% Non-linear fit r2 = a + b t + c ln(t)
[coeffsW, coeffsig] = nlDiffFit( dtimeM, msdM, errorM );

Dfit = coeffsW(2);
DsigFit = coeffsig(2);

[coeffsUw, coeffsig] = nlDiffFit( dtimeM, msdM );

DfitUw = coeffsUw(2);
DsigFitUw = coeffsig(2);
  
%[Coeffs ,resnorm,~,exitflag,output] = lsqcurvefit(fitfunction,fitguess,dtimeM,msdM);
%Dfit = Coeffs(2);
%DsigFit = 0;

%Fsumsquares = @(x)sum((fitfunction(x,dtimeM) - msdM).^2);
%opts = optimoptions('fminunc','Algorithm','quasi-newton');
%[xunc,ressquared,eflag,outputu] = ...
    %fminunc(Fsumsquares,Coeffs,opts);

%disp(Coeffs)

[DaveW, DsigW] = wmean( DfitV, DsigV );
DaveUw = mean(DfitV);
DsigUw = std(DfitV);

DaveUwUw = mean(DfitVuw);
DsigUwUw = std(DfitVuw);

% Put it in a struct
Dstruct.Dfit  = Dfit;
Dstruct.DsigFit = DsigFit;
Dstruct.DaveW = DaveW;
Dstruct.DsigW = DsigW;
Dstruct.DaveUw = DaveUw;
Dstruct.DsigUw = DsigUw;
Dstruct.DfitUw = DfitUw;
Dstruct.DsigFitUw = DsigFitUw;
Dstruct.DaveUwUw = DaveUwUw;
Dstruct.DsigUwUw = DsigUwUw;
Dstruct.Dsaxton = 0.3592;
Dstruct.DsigSax = 0.003;
Dstruct.tstart = timestart;

% D = 0
figure()
plot(dtimeAveF, msdAveF, ...
  dtimeAveF, coeffsW(1) + coeffsW(2) .*  dtimeAveF + coeffsW(3) .* log(dtimeAveF), ... 
  dtimeAveF, coeffsUw(1) + coeffsUw(2) .*  dtimeAveF + coeffsUw(3) .* log(dtimeAveF) )
title(['fo =' num2str(ffoM)])
legend('msd data', 'fit W', 'fit Uw', 'location', 'best')

keyboard
% Plot it
if plotflag
  % Get some parameters for axis
  tMax = dtimeAveF(end);
  
  % Parameters
  ParamList1 = sprintf('ffo: %.1g BE = %.1g', ffoM, bindenM);
  ParamList2 = sprintf( ' ntrials: %d \n ng: %d \n ntime: %d',...
    const.rec_chunk, const.maxpts_msd,const.num_tracer);
  ParamList2 = sprintf( '%s \n nrecint:%d  \n randtimeptns: %d \n ntracer: %d\n',...
    ParamList2, const.rec_chunk, const.maxpts_msd,const.num_tracer);
  
  TitleStr1 = 'msd';
  TitleStr2 = ParamList1;
  
  Dstr1 =  sprintf('W: D = %.4f +/- %.2e', ...
    Dstruct.DaveW, Dstruct.DsigW);
  Dstr2 = sprintf('UW: D = %.4f +/- %.2e',...
    Dstruct.DaveUw, Dstruct.DsigUw);
  Dstr3 =  sprintf('Fit: D = %.4f +/- %.2e',...
    Dstruct.Dfit, Dstruct.DsigFit);
  Dstr = sprintf('%s\n%s\n%s\n', Dstr1, Dstr2, Dstr3);
  
  %% Fig 1: scatter plot with fit and average vals with fit
  figure()
 
  
  % All
  subplot( 2,2,1);
  scatter( dtimeNfM , msdNfM )
  hold on
  scatter( dtimeM , msdM )
  plot( [ dtimeAveNf; dtimeAveF] , Shift + Dfit .* [ dtimeAveNf; dtimeAveF] )
  axis square
  axis( [0 tMax 0 tMax] )
  xlabel('time'); ylabel('r^2')
  title( [TitleStr1 '(all)' ] )
  legend('Data NF', 'Data F', 'Fit line','location','best')
  
  % Ave
  subplot( 2,2,2 )
  scatter( dtimeAveNf , msdAveNf )
  hold on
  scatter( dtimeAveF , msdAveF )
  plot( [ dtimeAveNf; dtimeAveF] , Shift + Dfit .* [ dtimeAveNf; dtimeAveF] )
  axis square
  axis( [0 tMax 0 tMax] )
  xlabel('time'); ylabel('r^2')
  title( [TitleStr2] )
  legend('Data NF', 'Data F', 'Fit line','location','best')
  
  %Params
  subplot( 2, 2, 3)
  axis square
  text( 0.1, 0.5, Dstr )
  
  subplot( 2, 2, 4)
  axis square
  text( 0.1, 0.5, ParamList2 )
  
  % Save it
  if saveFlag
   savestr = sprintf('msdbe%.1foff%.1f.fig', bindenM, ffoM);
    savefig( savestr );
  end
  
  %% Fig 2: log plots to show anomalous
  
  figure()

  
  % All points r^2 vs t
  Ha = subplot(2,2,1);
  loglog(  [ dtimeAveNf ; dtimeAveF ] , [ msdAveNf ; msdAveF ] );
  axis square
  
  xlabel('t'); ylabel('r^2'); title( 'All' );
  
  base10Xstr = 0;  base10Xend = ceil( log10( dtimeAveF(end) ) );
  base10Ystr = 0;  base10Yend = ceil( log10( msdAveF(end) ) );
  
  Ha.XTick = 10 .^( base10Xstr:base10Xend) ;
  Ha.YTick = 10 .^( base10Ystr:base10Yend) ;
  Ha.XLim =  10 .^ [base10Xstr base10Xend];
  Ha.YLim =  10 .^ [base10Ystr base10Yend];
  Ha.YGrid = 'on'; Ha.XGrid = 'on';
  
  % All points r^2 / t vs t
  Ha = subplot(2,2,2);
  loglog(  [ dtimeAveNf ; dtimeAveF ], ...
    [ msdAveNf ; msdAveF ] ./  [ dtimeAveNf ; dtimeAveF ] )
  axis square
  xlabel('t'); ylabel('r^2'); title( [ 'All: ' TitleStr2 ]  );
  
  base10Xstr = 0;  base10Xend = ceil( log10( dtimeAveF(end) ) );
  base10Ystr = -1; base10Yend = 1;
  
  Ha.XTick = 10 .^( base10Xstr:base10Xend) ;
  Ha.YTick = 10 .^( base10Ystr:base10Yend) ;
  Ha.XLim =  10 .^ [base10Xstr base10Xend];
  Ha.YLim =  10 .^ [base10Ystr base10Yend];
  Ha.YGrid = 'on'; Ha.XGrid = 'on';
  
  % Just fit r^2 vs t
  Ha = subplot(2,2,3);
  loglog(  dtimeAveF  , msdAveF )
  axis square
  
  xlabel('t'); ylabel('r^2');   title( 'Fit' );
  
  base10Xstr = 0;  base10Xend = ceil( log10( dtimeAveF(end) ) );
  base10Ystr = 0;  base10Yend = ceil( log10( msdAveF(end) ) );
  
  Ha.XTick = 10 .^( base10Xstr:base10Xend) ;
  Ha.YTick = 10 .^( base10Ystr:base10Yend) ;
  Ha.XLim =  10 .^ [base10Xstr base10Xend];
  Ha.YLim =  10 .^ [base10Ystr base10Yend];
  Ha.YGrid = 'on'; Ha.XGrid = 'on';
  
  % Just fit r^2 / t v t
  Ha = subplot(2,2,4);
  loglog(  dtimeAveF  , msdAveF ./dtimeAveF )
  axis square
  
  xlabel('t'); ylabel('r^2'); title( [ 'F: ' TitleStr2 ]  );
  
  base10Xstr = 0;  base10Xend = ceil( log10( dtimeAveF(end) ) );
  base10Ystr = -1; base10Yend = 1;
  
  Ha.XTick = 10 .^( base10Xstr:base10Xend) ;
  Ha.YTick = 10 .^( base10Ystr:base10Yend) ;
  Ha.XLim =  10 .^ [base10Xstr base10Xend];
  Ha.YLim =  10 .^ [base10Ystr base10Yend];
  Ha.YGrid = 'on'; Ha.XGrid = 'on';
  
  % Save it
  if saveFlag
    savestr = sprintf('logbe%.1foff%.1f.fig', bindenM, ffoM);
    savefig( savestr );
  end
  
end % if Plotflag


