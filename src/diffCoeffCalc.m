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
dtimeAveF = dtime( tInd ); % Ave time
masterIndstr = 1; % Storing index

% Allocate memory for things
msdAveF   = zeros(recLength, 1);
FpntsTot = zeros(recLength, 1);
fitCoeffSeV   = zeros( NumFiles, 1 );
fitSigSeV   = zeros( NumFiles, 1 );

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
  error_temp  = ( msd(tInd,2) ./ sqrt( nPts_temp ) ) ; % Column vector
  
  %Make sure nothing is broken
  if isinf( msd_temp )
    error('msd is infinite')
  end
  
  % Non-linear fit r2 = a + b t + c ln(t)
  % Error scaled by root N
  % Make sure error isn't zero. Can happen at high attraction

    err0 = find( error_temp == 0 );
    if ~isempty( err0 )
     error_temp(err0) = error_temp(err0 + 11);
    end

  try
  if guessFlag == 1
    [coeffsWsc, coeffsigWsc] = nlDiffFit( t_temp, msd_temp, error_temp,fitguess );
  else
    [coeffsWsc, coeffsigWsc] = nlDiffFit( t_temp, msd_temp, error_temp );
  end
  catch errMsg
    keyboard
  end
  fitCoeffSeV(ii,1) = coeffsWsc(1);
  fitCoeffSeV(ii,2) = coeffsWsc(2);
  fitCoeffSeV(ii,3) = coeffsWsc(3);
  fitSigSeV(ii,1) = coeffsigWsc(1);
  fitSigSeV(ii,2) = coeffsigWsc(2);
  fitSigSeV(ii,3) = coeffsigWsc(3);
  
  % Store all the msd data for master plot. -2 because we skip t = 1
  masterIndend = masterIndstr + recLength - 1;
  
  try
    % Average list. Sum everything up then divide by total points
    msdAveF   = msdAveF + msd_temp .* nPts_temp;
    FpntsTot = FpntsTot + nPts_temp;
    masterIndstr = masterIndend + 1;
    totTpntsOld = totTpnts;
  catch
    keyboard
  end
  % Update fit guess
  if guessFlag; fitguess = coeffsWsc; end;
end

if verbose
  fprintf('Finished trials loop  be= %f ffo= %f so= %f numtrials = %d\n',...
    bindenM , ffoM, soM, NumFiles);
end

% Calculate average;
msdAveF = msdAveF ./ FpntsTot;

% Aveage coeffs.
coeffUwaWfSc = mean( fitCoeffSeV, 1 );
coeffSigUwaWfSc = std( fitCoeffSeV, 1 );

% Put it in a struct
Dstruct.DfitUwaWfSc = coeffUwaWfSc(2);
Dstruct.DsigUwaWfSc = coeffSigUwaWfSc(2);
Dstruct.tstart = timestart;

% Coefficients
coeffsFit.UwaWfSc = coeffUwaWfSc;
coeffsSig.UwaWfSc = coeffSigUwaWfSc;

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
