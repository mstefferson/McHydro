function [output]= findHorztlAsymp(x,y,erry)

% add paths
addpath('./src')
% Vector is noisey. Bin it to smooth it out
binNum = 16;
% binSize = ceil( length(y) ./ binNum );
% length of vector
nV = length(x);
spaceLog = round( logspace( 0, log10( length(x) ), binNum + 1 ) );
spaceLog = unique( spaceLog );
binNum = length( spaceLog ) - 1;
% Store slope and center of each bin
slopeBin = zeros( binNum, 1);
yinter = zeros( binNum, 1);
centerVal = zeros( binNum, 1);
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
  centerVal(ii) = pfit.p1 .* xTemp( round( ptsTemp / 2 ) ) + pfit.p2;
  numPnts(ii) = ptsTemp;
  binLength(ii) = xTemp(end) - xTemp(1);
  aveBin(ii) = mean( yTemp );
  stdBin(ii) = std( yTemp );
end
%Store the slope of the first/last bin
slopeStart = slopeBin(1);
slopeEnd = slopeBin(end);

% Find asymptote
% First check that it got close to steady state to count: an a relative uncertainty of less than 10 %
[minSlope, ind] = min( slopeBin );
deltaY = binLength(ind) .* minSlope;
relUncertainty = abs( 10 ^ ( deltaY / 2 ) - 10 ^ ( -deltaY / 2) );
threshold = 0.1;

%Check if the last few slopes are worse than the middle
midBin = round( binNum / 2 );
finalSlopes =  mean( slopeBin( midBin:end ) );

if relUncertainty > threshold
  steadyState = 0;
elseif finalSlopes < midBin
  steadyState = 0;
else
  steadyState = 1;
end

if steadyState 
  bins2Check = randSelectAboutMin(slopeBin);
  [ hAsymp, sigh, ~] = ...
    findBins4asymp( bins2Check, spaceLog, x, y, erry );
  D = 10 ^ (hAsymp);
  Dsig = sigh .* D .* log(10) ;

  %Calculate early time slope to find the analmous time. If it's too flat, set anomalous time to zero
  aveSlope = mean(slopeBin); 
  stdSlope = std(slopeBin); 
  if ( ( slopeStart < aveSlope + stdSlope ) && ( slopeStart > aveSlope + stdSlope ) ) || slopeStart > 0 
    asympInter = x(1);
    asympInterSig = 0;
  else
  asympInter = ( hAsymp -  yinter(1) )./ slopeStart ; 
  asympInterSig =  sigh ./ slopeStart ; 
  end

  tAsymp = 10 ^ ( asympInter );
  tAsympSig = asympInterSig .* log(10) * 10 ^ ( asympInter );

else % not reached steady state
  D = NaN;
  Dsig = NaN;
  hAsymp = -Inf;
  sigh = NaN;
  tAsymp = Inf;
  tAsympSig = NaN;
end

% Compile output
output.steadyState = steadyState;
output.D = D;
output.Dsig = Dsig;
output.hAsymp = hAsymp;
output.hSig = sigh;
output.slopeLongT = slopeEnd;
output.slopeShortT = slopeStart;
output.tAsymp = tAsymp;
output.tAsympSig = tAsympSig;
output.slopeBin = slopeBin;
output.centerBin = centerVal;
output.binLength = binLength;
output.yinter = yinter;

% Plot Binned Data
plotDataBins( x, y, spaceLog, slopeBin, yinter )
% Plot asymptote
plotDataAsympError( x, y, erry, hAsymp, sigh )
plotDataAsymp( x, y, hAsymp, slopeStart, yinter )

