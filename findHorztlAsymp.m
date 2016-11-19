function [output]= findHorztlAsymp(x,y,erry)

% Vector is noisey. Bin it to smooth it out
binNum = 16;
% binSize = ceil( length(y) ./ binNum );
% length of vector
nV = length(x);
spaceLog = floor( logspace( 0, log10( length(x) ), binNum + 1 ) );
spaceLog = unique( spaceLog );
binNum = length( spaceLog ) - 1;
% Store slope and center of each bin
slopeBin = zeros( binNum, 1);
yinter = zeros( binNum, 1);
centerVal = zeros( binNum, 1);
aveBin = zeros( binNum, 1);
stdBin = zeros( binNum, 1);
numPnts = zeros( binNum, 1 );

% Plots
figure()
subplot(2,1,1)
errorbar(  x, y, erry )
xlabel( 't' ); ylabel( 'x^2/t' );
title('Data w/ error bars')
subplot(2,1,2)
plot( x, y)
xlabel( 't' ); ylabel( 'x^2/t' );
title('Data')
hold on

figure()
plot( log10( x ), log10( y./x ) )
xlabel( 'log_{10} (t) ' ); ylabel( 'log_{10} (x^2/t) ' );
title('Log Plot Data and bin lines')
hold on
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
  aveBin(ii) = mean( yTemp );
  stdBin(ii) = std( yTemp );
  plot( xTemp, pfit.p1 .* xTemp  + pfit.p2 );
end

% Find asymptote
bins2Check = randSelectAboutMin(slopeBin);
[ hAsymp, sigh, ~] = ...
  findBins4asymp( bins2Check, spaceLog, x, y, erry );
D = 10 ^ (hAsymp);
Dsig = sigh .* D .* log(10) ;
slopeTail = slopeBin(end);
slopeStart = slopeBin(1);
asympInter = ( hAsymp -  yinter(1) )./ slopeStart ; 
tAsymp = 10 ^ ( asympInter );

% Plot with error bars
figure()
errorbar( log10(x), log10(y./x), erry ./ ( y .* log(10) ) );
xlabel( 'log_{10} (t) ' ); ylabel( 'log_{10} (x^2/t) ' );
title('Data w/ error bars')
hold on
plot( log10(x), hAsymp .* ones( length(x) , 1) );
plot( log10(x), ( hAsymp - sigh ) .* ones( length(x) , 1) )
plot( log10(x), ( hAsymp + sigh ) .* ones( length(x) , 1) )

% Plot it
figure()
plot( log10( x ), log10( y./x ) )
xlabel( 'log_{10} (t) ' ); ylabel( 'log_{10} (x^2/t) ' );
title('Log Plot Data and bin lines')
hold on
plot( log10( x ), ones( length(x) ,1 ) .* hAsymp, ...
  log10( x ), slopeStart .*  log10( x ) + yinter(1) )

% Compile output
output.D = D;
output.Dsig = Dsig;
output.hAsymp = hAsymp;
output.hSig = sigh;
output.slopeLongT = slopeTail;
output.slopeShortT = slopeStart;
output.tAsymp = tAsymp;
output.slopeBin = slopeBin;
output.centerBin = centerVal;



