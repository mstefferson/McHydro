% [output]= findHorztlAsymp(x,y,erry)
%   Description: Find the horizontal asymptote, maximum slope, and
%   intercept (if it can)

function [output]= findHorztlAsymp(x,y,erry)
% add paths
addpath('./src')
% Vector is noisey. Bin it to smooth it out
binNum = 16;
spaceLog = round( logspace( 0, log10( length(x) ), binNum + 1 ) );
spaceLog = unique( spaceLog );
binNum = length( spaceLog ) - 1;
% Store slope and center of each bin
slopeBin = zeros( binNum, 1);
yinter = zeros( binNum, 1);
centerValy = zeros( binNum, 1);
centerValx = zeros( binNum, 1);
aveBin = zeros( binNum, 1);
stdBin = zeros( binNum, 1);
numPnts = zeros( binNum, 1 );
binLength = zeros( binNum, 1 );
% Do a linear fit of data between points in a bin
for ii = 1:binNum
  indStart =  spaceLog(ii) ;
  indEnd = spaceLog(ii+1) ;
  yTemp = log10( y( indStart:indEnd ) ./ x( indStart:indEnd ) );
  xTemp =  log10( x( indStart:indEnd ) );
  errTemp = erry ( indStart:indEnd ) ./ ( y(indStart:indEnd) * log(10) );
  wTemp = 1 ./ ( errTemp .^ 2 );
  ptsTemp = length(yTemp);
  pfit = fit( xTemp, yTemp, 'poly1', 'weights',  wTemp);
  slopeBin(ii) = pfit.p1;
  yinter(ii) =  pfit.p2;
  centerValy(ii) = pfit.p1 .* xTemp( round( ptsTemp / 2 ) ) + pfit.p2;
  centerValx(ii) = mean(xTemp);
  numPnts(ii) = ptsTemp;
  binLength(ii) = xTemp(end) - xTemp(1);
  aveBin(ii) = mean( yTemp );
  stdBin(ii) = std( yTemp );
end
% Do a bulk binnning to make sure you don't start analysis in crap
% skip first bin
binSize = 4;
slopeBinBulk = zeros( binNum / binSize, 1 );
for ii = 1: binNum / binSize
  ind = binSize * (ii - 1) + 1;
  indStart =  spaceLog(ind) ;
  indEnd = spaceLog(ind+binSize) ;
  yTemp = log10( y( indStart:indEnd ) ./ x( indStart:indEnd ) );
  xTemp =  log10( x( indStart:indEnd ) );
  errTemp = erry ( indStart:indEnd ) ./ ( y(indStart:indEnd) * log(10) );
  wTemp = 1 ./ ( errTemp .^ 2 );
  pfit = fit( xTemp, yTemp, 'poly1', 'weights',  wTemp);
  slopeBinBulk(ii) = pfit.p1;
end
% find mins
[~, minBulk] = min( abs( slopeBinBulk(2:end) ) );
[~, minIndBulk] = min( abs( slopeBin( ...
  ( minBulk ) * binSize  + 1 : (minBulk+1)  * binSize )  ) );
minInd =  minBulk * binSize  + minIndBulk;
% Don't count noisy end points for steady state and max slope
endInd = round( binNum ./ ( log10( x(end) ) - log10( x(1) ) ) );
%Store the slope of the first/last bin
slopeStart = slopeBin(1);
slopeEnd = slopeBin(end);
[slopeMin, indMax] = min( slopeBin(1 : end - endInd ) );
% Find asymptote
% First check that it got close to steady state to count: an a relative uncertainty of less than 10 %
deltaY = binLength(minInd) .* slopeBin(minInd);
relUncertaintyCenter = abs( 10 ^ ( deltaY / 2 ) - 10 ^ ( -deltaY / 2) );
thresholdMid = 0.1;
%Check if the last few slopes are worse than the middle
finalSlopes =  mean( ...
  slopeBin( end - endInd  : end ) );
dX = sum( binLength(end-endInd : end) ) ;
deltaY = finalSlopes * dX;
relUncertaintyEnd = abs( 10 ^ ( deltaY / 2 ) - 10 ^ ( -deltaY / 2) );
thresholdEnd = 0.15;
% determine steady state
if relUncertaintyCenter > thresholdMid
  steadyState = 0;
elseif relUncertaintyEnd > thresholdEnd
  steadyState = 0;
else
  steadyState = 1;
end
% See if data equilbrated before calculating slope was useful
earlyAnom = 0;
if steadyState
  % Don't check the first coupld of bins due to lack of data point
  bins2Check = randSelectAboutMin(slopeBin,minInd);
  [ hAsymp, sigh, ~] = ...
    findBins4asymp( bins2Check, spaceLog, x, y, erry );
  D = 10 ^ (hAsymp);
  Dsig = sigh .* D .* log(10) ;
  % Calculate early max slope to find the analmous time. If it's too flat,
  % set anomalous time last center val in range
  ind2check = intersect( find( centerValy < hAsymp + sigh  ),  find( centerValy > hAsymp - sigh  ) );
  [minLogtInRange, indRange] = min( centerValx(ind2check) );
  % Calculate t asym from intecept
  asympInter = ( hAsymp -  yinter(indMax) ) ./ slopeMin ;
  asympInterSig =  -sigh ./ slopeMin ;
  tAnom = 10 ^ ( asympInter );
  tAnomSig = asympInterSig .* log(10) * 10 ^ ( asympInter );
  if 10 ^ (minLogtInRange) <  tAnom
    tAnom = 10 ^ (minLogtInRange);
    tAnomSig = tAnom * ( 10 ^ ( binLength(indRange) / 2 ) - 1  )  ;
    earlyAnom = 1;
  end
else % not reached steady state
  D = NaN;
  Dsig = NaN;
  hAsymp = -Inf;
  sigh = NaN;
  tAnom = Inf;
  tAnomSig = NaN;
end
% Compile output
output.steadyState = steadyState;
output.earlyAnom = earlyAnom;
output.D = D;
output.Dsig = Dsig;
output.hAsymp = hAsymp;
output.hSig = sigh;
output.slopeEnd = slopeEnd;
output.slopeStart = slopeStart;
output.slopeMostNeg = slopeMin;
output.yinterMostNeg = yinter(indMax);
output.tAnom = tAnom;
output.tAnomSig = tAnomSig;
output.slopeBin = slopeBin;
output.centerBin = centerValy;
output.binLength = binLength;
output.upperBound = min(centerValy);
output.yinter = yinter;
