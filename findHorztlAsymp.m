% [output]= findHorztlAsympx,y,erry)
%   Description: Find the horizontal asymptote, maximum slope, and
%   intercept (if it can)
function [output]= findHorztlAsymp(x,y,erry)
% add paths
addpath('./src')
% Vector is noisey. Bin it to smooth it out
binNum = ceil( log( x(end) ) - log( x(1) ) );
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
  yTemp = log( y( indStart:indEnd ) ./ x( indStart:indEnd ) );
  xTemp =  log( x( indStart:indEnd ) );
  errTemp = erry ( indStart:indEnd ) ./ ( y(indStart:indEnd) );
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
binBulkSize = floor( binNum / 4 );
numBinBulk = floor( binNum / binBulkSize );
slopeBinBulk = zeros( numBinBulk, 1 );
for ii = 1 : numBinBulk
  ind = binBulkSize * (ii - 1) + 1;
  indStart =  spaceLog(ind) ;
  indEnd = spaceLog(ind+binBulkSize) ;
  yTemp = log( y( indStart:indEnd ) ./ x( indStart:indEnd ) );
  xTemp =  log( x( indStart:indEnd ) );
  errTemp = erry ( indStart:indEnd ) ./ ( y(indStart:indEnd) );
  wTemp = 1 ./ ( errTemp .^ 2 );
  pfit = fit( xTemp, yTemp, 'poly1', 'weights',  wTemp);
  slopeBinBulk(ii) = pfit.p1;
end

% find mins
% Get spead of data. If it's small, ignore noisey end
minData = min ( y./x );
maxData = max ( y./x );
meanData = mean( y ./ x);
spread = ( maxData - minData ) ./ meanData;
if spread < 0.1
  [~, minBulk] = min( abs( slopeBinBulk(2:end-1) ) );
else
  [~, minBulk] = min( abs( slopeBinBulk(2:end) ) );
end

[~, minIndBulk] = min( abs( slopeBin( ...
  ( minBulk ) * binBulkSize  + 1 : (minBulk+1)  * binBulkSize )  ) );
indMinSlope =  minBulk * binBulkSize  + minIndBulk;
% Don't count noisy end points or start for steady state and max slope
startInd = find( numPnts > 10, 1 ) ;
endInd = round( binNum ./ ( log( x(end) ) - log( x(1) ) ) );
%Store the slope of the first/last bin
slopeStart = slopeBin(1);
slopeEnd = slopeBin(end);
[slopeMostNeg, indSlopeMostNeg] = min( slopeBin(startInd : indMinSlope) );
indSlopeMostNeg =  indSlopeMostNeg + startInd - 1;
% If max slope later than min slope, try again
% if indSlopeMostNeg > indMinSlope;
%   
% Find asymptote
% First check that it got close to steady state to count: an a relative uncertainty of less than 10 %
deltaY = binLength(indMinSlope) .* slopeBin(indMinSlope);
relUncertaintyCenter = abs( exp( deltaY / 2 ) - exp( -deltaY / 2) );
thresholdMid = 0.1;
%Check if the last few slopes are worse than the middle
finalSlopes =  mean( slopeBin( end - endInd  : end ) );
dX = sum( binLength(end-endInd : end) ) ;
deltaY = finalSlopes * dX;
relUncertaintyEnd = abs( exp( deltaY / 2 ) - exp( -deltaY / 2) );
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
  bins2Check = randSelectAboutMin(slopeBin,indMinSlope);
  [ hAsymp, sigh, ~] = ...
    findBins4asymp( bins2Check, spaceLog, x, y, erry );
  D = exp(hAsymp);
  Dsig = sigh .* D;
  % Calculate early max slope to find the analmous time. If it's too flat,
  % set anomalous time last center val in range
  ind2check = min( intersect( find( centerValy < hAsymp + sigh  ),  find( centerValy > hAsymp - sigh  ) ) );
  % Calculate t asym from intecept
  asympInter = ( hAsymp -  yinter(indSlopeMostNeg) ) ./ slopeMostNeg ;
  asympInterSig =  -sigh ./ slopeMostNeg ;
  tAnom = exp( asympInter );% 
  tAnomSig = asympInterSig .* exp( asympInter );
  if ind2check <=  startInd 
    tAnom = exp( centerValx( ind2check) );
    tAnomSig = 0 ;
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
output.slopeMostNeg = slopeMostNeg;
output.yinterMostNeg = yinter(indSlopeMostNeg);
output.tAnom = tAnom;
output.tAnomSig = tAnomSig;
output.slopeBin = slopeBin;
output.centerBin = centerValy;
output.binLength = binLength;
output.upperBound = min(centerValy);
output.yinter = yinter;
