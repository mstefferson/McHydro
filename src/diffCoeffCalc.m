% [Dstruct, coeffsFit, coeffsSig] = diffCoeffCalc( filename, timestart, fitPlotFlag, ...
%  logPlotflag, verbose, saveFlag, initGuess )
%  Measures diffusion coefficients over trials for fixed parameters


function [Dstruct, coeffsFit, coeffsSig] = diffCoeffCalc( filename, timestart, fitPlotFlag, ...
  logPlotflag, verbose, saveFlag, initGuess )

if nargin == 1
  timestart = 1;
  fitPlotFlag  = 0;
  logPlotflag  = 0;
  verbose = 0;
  saveFlag = 0;
  guessFlag = 0;
elseif nargin == 2
  fitPlotFlag  = 0;
  logPlotflag  = 0;
  verbose = 0;
  saveFlag = 0;
  guessFlag = 0;
elseif nargin == 3
  logPlotflag  = 0;
  verbose = 0;
  saveFlag = 0;
  guessFlag = 0;
elseif nargin == 4
  verbose = 0;
  saveFlag = 0;
  guessFlag = 0;
elseif nargin == 5
  saveFlag = 0;
  guessFlag = 0;
elseif  nargin == 6
  guessFlag = 0;
else
  guessFlag = 1;
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
  soM = paramlist.so;
elseif exist('paramvec','var' )
  ffoM = paramvec(1);
  bindenM = paramvec(4);
  so = [];
else
  error('I cannot find any parameters');
end

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
errorMsc = zeros( recLength * NumFiles, 1 );
masterIndstr = 1; % Storing index

% Store data that isn't fitted for plotting
if fitPlotFlag == 1
  tIndNf     = 1: (tstartInd - 1);
  dtimeNfM   = zeros( (tstartInd - 1 ) * NumFiles, 1 );
  msdNfM     = zeros( (tstartInd - 1 ) * NumFiles, 1 );
  msdAveNf   = zeros( (tstartInd - 1 ), 1 );
  NfPtsTot   = zeros( (tstartInd - 1 ), 1 );
  NfIndstr   = 1; % Storing index
end

% Average
dtimeAveF = dtime( tInd );
msdAveF   = zeros(recLength, 1);
FpntsTot = zeros(recLength, 1);

fitCoeffV   = zeros( NumFiles, 1 );
fitSigV   = zeros( NumFiles, 1 );

fitCoeffSeV   = zeros( NumFiles, 1 );
fitSigSeV   = zeros( NumFiles, 1 );

fitCoeffUwV   = zeros( NumFiles, 1 );
fitSigUwV   = zeros( NumFiles, 1 );

if NumFiles == 0
  error('I am not analyzing anything')
end

plotIndFile = 0;

if plotIndFile; figure(); end;
if guessFlag; fitguess = initGuess; end;

% Loop over files
for ii=1:NumFiles
  
  load(SameParamFiles{ii})
  totTpnts = length( dtime );
  if totTpnts ~= totTpntsOld; error('Record lengths changing'); end;
  
  % Make sure the parameter are the same
  if exist('paramlist','var')
    ffoTemp = paramlist.ffo;
    bindTemp = paramlist.be;
    soTemp = paramlist.so;
  elseif exist('paramvec','var')
    ffoTemp = paramvec(1);
    bindTemp = paramvec(4);
    soTemp = [];
  else
    error('I cannot find any parameters');
  end
  
  if ( abs(ffoTemp - ffoM) > 1e-15 ) || ...
      ( bindTemp ~= bindenM ) || (soTemp ~= soM);
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
  error_tempS  = ( msd(tInd,2) ./ sqrt( nPts_temp ) ) ; % Column vector
  error_temp  =  msd(tInd,2) ; % Column vector
  
  %Make sure nothing is broken
  if isinf( msd_temp )
    error('msd is infinite')
  end
  % Record points not in fit if plotting
  if fitPlotFlag
    NfIndend = NfIndstr + tstartInd - 2;
    dtimeNfM(NfIndstr:NfIndend) = dtime( tIndNf ) ;
    msdNfM(NfIndstr:NfIndend)    = msd( tIndNf , 2 );
    msdAveNf   = msdAveNf + msd(tIndNf,2) .*  msd(tIndNf,3);
    NfPtsTot   = NfPtsTot + msd(tIndNf,3);
  end
  
  % Store it for weighted average
  % Error not scaled by root N
  if guessFlag == 1
    [coeffsW, coeffsigW] = nlDiffFit( t_temp, msd_temp, error_temp, fitguess );
  else
    [coeffsW, coeffsigW] = nlDiffFit( t_temp, msd_temp, error_temp );
  end
  
  fitCoeffV(ii,1) = coeffsW(1);
  fitCoeffV(ii,2) = coeffsW(2);
  fitCoeffV(ii,3) = coeffsW(3);
  fitSigV(ii,1) = coeffsigW(1);
  fitSigV(ii,2) = coeffsigW(2);
  fitSigV(ii,3) = coeffsigW(3);
  
  % Error scaled by root N
  if guessFlag == 1
    [coeffsWsc, coeffsigWsc] = nlDiffFit( t_temp, msd_temp, error_tempS,fitguess );
  else
    [coeffsWsc, coeffsigWsc] = nlDiffFit( t_temp, msd_temp, error_tempS );
  end
  
  fitCoeffSeV(ii,1) = coeffsWsc(1);
  fitCoeffSeV(ii,2) = coeffsWsc(2);
  fitCoeffSeV(ii,3) = coeffsWsc(3);
  fitSigSeV(ii,1) = coeffsigWsc(1);
  fitSigSeV(ii,2) = coeffsigWsc(2);
  fitSigSeV(ii,3) = coeffsigWsc(3);
  
  % Unweighted
  if guessFlag == 1
    [coeffsUw, coeffsigW] = nlDiffFit( t_temp, msd_temp,1, fitguess );
  else
    [coeffsUw, coeffsigW] = nlDiffFit( t_temp, msd_temp,1 );
  end
  
  fitCoeffUwV(ii,1) = coeffsUw(1);
  fitCoeffUwV(ii,2) = coeffsUw(2);
  fitCoeffUwV(ii,3) = coeffsUw(3);
  fitSigUwV(ii,1) = coeffsigW(1);
  fitSigUwV(ii,2) = coeffsigW(2);
  fitSigUwV(ii,3) = coeffsigW(3);
  
  if plotIndFile
    fprintf('Weighted = %f \n', fitCoeffV(ii,2) )
    fprintf('W. delta = %f \n', fitCoeffV(ii,2) - 1 );
    fprintf('Weighted/ sqrt N = %f \n', fitCoeffSeV(ii,2) )
    fprintf('WS. delta = %f \n', fitCoeffSeV(ii,2) - 1 );
    fprintf('UnWeighted = %f \n', fitCoeffUwV(ii,2) )
    fprintf('UW. delta = %f \n',  fitCoeffUwV(ii,2) - 1 );
    
    ind = 1:10:length(t_temp);
    plot( t_temp(ind), msd_temp(ind) )
    hold on;
    plot(...
      t_temp, coeffsW(1) + coeffsW(2) .* t_temp + coeffsW(3) .* log(t_temp),...
      t_temp, coeffsWsc(1) + coeffsWsc(2) .* t_temp + coeffsWsc(3) .* log(t_temp),...
      t_temp, coeffsUw(1) + coeffsUw(2) .* t_temp + coeffsUw(3) .* log(t_temp) );
    
    if ffoTemp == 0
      plot( t_temp, t_temp );
    end
    
    hold off;
    ax = gca;
    ax.XLim = [0 t_temp(end)];
    ax.YLim = [0 2e5];
    if ffoTemp == 0
      legend( 'data', 'weighted', 'weighted / sqrt(N)', 'unweighted',...
        'linear','location','best');
    else
      legend( 'data', 'weighted', 'weighted / sqrt(N)', 'unweighted',...
        'location','best');
    end
    titstr = sprintf('fo = %.2f',ffoTemp);
    title(titstr);
    keyboard
  end
  
  % Store all the msd data for master plot. -2 because we skip t = 1
  masterIndend = masterIndstr + recLength - 1;
  
  % Master list
  dtimeM( masterIndstr:masterIndend  ) = t_temp;
  msdM( masterIndstr:masterIndend  ) = msd_temp;
  errorM( masterIndstr:masterIndend  ) = error_temp;
  errorMsc( masterIndstr:masterIndend  ) = error_tempS;
  
  % Average list. Sum everything up then divide by total points
  msdAveF   = msdAveF + msd_temp .* nPts_temp;
  FpntsTot = FpntsTot + nPts_temp;
  masterIndstr = masterIndend + 1;
  
  % Update fit guess
  if guessFlag; fitguess = coeffsWsc; end;
  
  totTpntsOld = totTpnts;
end

fprintf('Finished trials loop  be= %f ffo= %f so= %f numtrials = %d\n',...
  bindenM , ffoM, soM, NumFiles);

% Calculate average;
msdAveF = msdAveF ./ FpntsTot;
if fitPlotFlag
  msdAveNf   = msdAveNf ./ NfPtsTot;
end
% Cut off zeros if there are any. There should be though...
NotZeroInd = length( dtimeM ( dtimeM > 0 ) );
dtimeM = dtimeM(1:NotZeroInd);
msdM = msdM(1:NotZeroInd);
errorM = errorM(1:NotZeroInd);

% Non-linear fit r2 = a + b t + c ln(t)
coeffWaWf = zeros(1,3);
coeffSigWaWf = zeros(1,3);
coeffWaWfSc = zeros(1,3);
coeffSigWaWfSc = zeros(1,3);
coeffWaUwf = zeros(1,3);
coeffSigWaUwf = zeros(1,3);

% Weighted sig^2 not scaled by N
[coeffWaWf(1), coeffSigWaWf(1)] = wmean( fitCoeffV(:,1), fitSigV(:,1) );
[coeffWaWf(2), coeffSigWaWf(2)] = wmean( fitCoeffV(:,2), fitSigV(:,2) );
[coeffWaWf(3), coeffSigWaWf(3)] = wmean( fitCoeffV(:,3), fitSigV(:,3) );

coeffUwaWf = mean( fitCoeffV, 1 );
coeffSigUwaWf = std( fitCoeffV, 1 );

if guessFlag == 1
  [coeffAllWf, coeffSigAllWf] = nlDiffFit( dtimeM, msdM, errorM, coeffUwaWf  );
else
  [coeffAllWf, coeffSigAllWf] = nlDiffFit( dtimeM, msdM, errorM );
end

% Weighted by sig^2/sqrt(N)
[coeffWaWfSc(1), coeffSigWaWfSc(1)] = wmean( fitCoeffSeV(:,1), fitSigSeV(:,1) );
[coeffWaWfSc(2), coeffSigWaWfSc(2)] = wmean( fitCoeffSeV(:,2), fitSigSeV(:,2) );
[coeffWaWfSc(3), coeffSigWaWfSc(3)] = wmean( fitCoeffSeV(:,3), fitSigSeV(:,3) );

coeffUwaWfSc = mean( fitCoeffSeV, 1 );
coeffSigUwaWfSc = std( fitCoeffSeV, 1 );
if guessFlag == 1
  [coeffAllWfSc, coeffSigAllWfSc] = nlDiffFit( dtimeM, msdM, errorMsc, coeffUwaWfSc   );
else
  [coeffAllWfSc, coeffSigAllWfSc] = nlDiffFit( dtimeM, msdM, errorMsc );
end

% Unweighted fit
[coeffWaUwf(1), coeffSigWaUwf(1)] = wmean( fitCoeffUwV(:,1), fitSigUwV(:,1) );
[coeffWaUwf(2), coeffSigWaUwf(2)] = wmean( fitCoeffUwV(:,2), fitSigUwV(:,2) );
[coeffWaUwf(3), coeffSigWaUwf(3)] = wmean( fitCoeffUwV(:,3), fitSigUwV(:,3) );

coeffUwaUwf = mean( fitCoeffUwV, 1 );
coeffSigUwaUwf = std( fitCoeffUwV, 1 );

if guessFlag == 1
  [coeffAllUwf, coeffSigAllUwf] = nlDiffFit( dtimeM, msdM, 1, coeffUwaUwf  );
else
  [coeffAllUwf, coeffSigAllUwf] = nlDiffFit( dtimeM, msdM, 1 );
end

% Put it in a struct
% All point in a weighted fit
Dstruct.DfitAllWf  = coeffAllWf(2);
Dstruct.DsigAllWf = coeffSigAllWf(2);
% All point in a weighted fit scaled by sqrt(N)
Dstruct.DfitAllWfSc  = coeffAllWfSc(2);
Dstruct.DsigAllWfSc = coeffSigAllWfSc(2);
% All point in a unweighted fit
Dstruct.DfitAllUwf = coeffAllUwf(2);
Dstruct.DsigAllUwf = coeffSigAllUwf(2);
% The weighted average of all individual weighed fits
Dstruct.DfitWaWf = coeffWaWf(2);
Dstruct.DsigWaWf = coeffSigWaWf(2);
% The unweighted average of all weighted fits
Dstruct.DfitUwaWf = coeffUwaWf(2);
Dstruct.DsigUwaWf = coeffSigUwaWf(2);
% The weighted average of all individual weighed fits scaled by sqrt(N)
Dstruct.DfitWaWfSc = coeffWaWfSc(2);
Dstruct.DsigWaWfSc = coeffSigWaWfSc(2);
% The unweighted average of all weighted fits scaled by sqrt(N)
Dstruct.DfitUwaWfSc = coeffUwaWfSc(2);
Dstruct.DsigUwaWfSc = coeffSigUwaWfSc(2);
% The weighted average of all individual unweighted fits
Dstruct.DfitUwaWf = coeffWaUwf(2);
Dstruct.DsigUwaWf = coeffSigWaUwf(2);
% The unweighted average of all individual unweighted fits
Dstruct.DfitUwaUwf = coeffUwaUwf(2);
Dstruct.DsigUwaUwf = coeffSigUwaUwf(2);
Dstruct.tstart = timestart;

% Coefficients
coeffsFit.AllWf = coeffAllWf;
coeffsSig.AllWf = coeffSigAllWf;

coeffsFit.AllWfSc = coeffAllWfSc;
coeffsSig.AllWfSc = coeffSigAllWfSc;

coeffsFit.AllUwf = coeffAllUwf;
coeffsSig.AllUwf = coeffSigAllUwf;

coeffsFit.WaWf = coeffWaWf;
coeffsSig.WaWf = coeffSigWaWf;

coeffsFit.UwaWf = coeffUwaWf;
coeffsSig.UwaWf = coeffSigUwaWf;

coeffsFit.WaWfSc = coeffWaWfSc;
coeffsSig.WaWfSc = coeffSigWaWfSc;

coeffsFit.UwaWfSc = coeffUwaWfSc;
coeffsSig.UwaWfSc = coeffSigUwaWfSc;

coeffsFit.WaUwf = coeffWaUwf;
coeffsSig.WaUwf = coeffSigWaUwf;

coeffsFit.UwaUwf = coeffUwaUwf;
coeffsSig.UwaUwf = coeffSigUwaUwf;

plotFits = 0;
if plotFits
  figure()
  hold all
  fprintf('Printing all fits\n');
  
  plot(dtimeAveF, coeffsFit.AllWf(1) + coeffsFit.AllWf(2) .* dtimeAveF ...
    + coeffsFit.AllWf(3) .* log(dtimeAveF), 'r-');
  plot(dtimeAveF, coeffsFit.WaWf(1) + coeffsFit.WaWf(2) .* dtimeAveF ...
    +  coeffsFit.WaWf(3) .* log(dtimeAveF), 'b-');
  plot(dtimeAveF, coeffsFit.UwaWf(1) + coeffsFit.UwaWf(2) .* dtimeAveF  ...
    + coeffsFit.UwaWf(3) .* log(dtimeAveF), 'g-');
  
  plot(dtimeAveF, coeffsFit.AllWfSc(1) + coeffsFit.AllWfSc(2) .* dtimeAveF ...
    + coeffsFit.AllWfSc(3) .* log(dtimeAveF),'r--');
  plot(dtimeAveF, coeffsFit.WaWfSc(1) + coeffsFit.WaWfSc(2) .* dtimeAveF  ...
    +  coeffsFit.WaWfSc(3) .* log(dtimeAveF), 'b--' );
  plot(dtimeAveF, coeffsFit.UwaWfSc(1) + coeffsFit.UwaWfSc(2) .* dtimeAveF ...
    + coeffsFit.UwaWfSc(3) .* log(dtimeAveF), 'g--' );
  
  plot(dtimeAveF, coeffsFit.AllUwf(1) + coeffsFit.AllUwf(2) .* dtimeAveF ...
    + coeffsFit.AllUwf(3) .* log(dtimeAveF),'r-.');
  plot( dtimeAveF, coeffsFit.WaUwf(1) + coeffsFit.WaUwf(2) .*  dtimeAveF ...
    + coeffsFit.WaUwf(3) .* log(dtimeAveF), 'b-.' );
  plot(dtimeAveF, coeffsFit.UwaUwf(1) + coeffsFit.UwaUwf(2) .* dtimeAveF  ...
    + coeffsFit.UwaUwf(3) .* log(dtimeAveF), '-.' );
  
  plot(dtimeAveF, msdAveF,'o')
  legend('All Wf', 'Wa Wf','UWa Wf',...
    'All WfSc', 'Wa WfSc','UWa WfSc', ...
    'All Uwf','Wa Uwf', ...
    'data', ...
    'location', 'best' )
  title(['fo =' num2str(ffoM)])
  Ax = gca;
  Ax.XLim = [0 max(dtimeAveF) ];
  Ax.YLim = [0 max(msdAveF) ];
end

% Plot it
if fitPlotFlag || logPlotflag
  ParamList1 = sprintf('ffo: %.2g BE = %.2g', ffoM, bindenM);
end
if fitPlotFlag
  dataFitPlot(dtimeAveF, coeffsFit.UwaWfSc, msdAveF, ...
    bindenM, ffoM, ParamList1, saveFlag)
end
if logPlotflag
  logMsdPlot(dtimeAveF, msdAveF, bindenM, ffoM, ParamList1, saveFlag)
end