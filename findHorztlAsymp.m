function [slopeBin, centerVal, numPnts ]= findHorztlAsymp(x,y,erry, nAve)

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
plot(  x, y)
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
  wTemp = erry ( indStart:indEnd ) ./ ( y(indStart:indEnd) * log(10) );
  ptsTemp = length(yTemp);
  pfit = fit( xTemp, yTemp, 'poly1', 'weights',  wTemp);
%   p = polyfit( xTemp, yTemp,1 );
  slopeBin(ii) = pfit.p1;
  centerVal(ii) = pfit.p1 .* xTemp( round( ptsTemp / 2 ) ) + pfit.p2;
  numPnts(ii) = ptsTemp;
  aveBin(ii) = mean( yTemp );
  stdBin(ii) = std( yTemp );
  plot( xTemp, pfit.p1 .* xTemp  + pfit.p2 );
end

% Find maximun possible windows
NwDesired = 100;
NwMax = ceil( (nV+1) ./ (1:nV) ) - 1; % minus cause ind start at 1
Nw = min( NwDesired, NwMax )';

% Plot with error bars
figure()
errorbar( log10(x), log10(y./x), erry ./ ( y .* log(10) ) );
xlabel( 'log_{10} (t) ' ); ylabel( 'log_{10} (x^2/t) ' );
title('Data w/ error bars')

% New averaging method based on discussion w/ Jeffrey Moore

%%
continCond = 1;
counter = binNum;

% first step outside loop
indStart =  spaceLog(counter) ;
indEnd = spaceLog(counter+1);
vecTemp = log10( y( indStart:indEnd ) ./ x( indStart:indEnd ) );
errTemp = erry( indStart:indEnd ) ./ ...
  ( sqrt( Nw( indStart:indEnd ) ) .* y( indStart:indEnd ) .* log(10)  );
w = 1 ./ (errTemp.^2);
nPnts = length(vecTemp);
sumVecNew = sum(vecTemp .* w );
sumWNew = sum( w );

aveNew = sumVecNew ./ sumWNew;
sumstd2numNew  = sum( ( vecTemp - aveNew ) .^ 2 .* w );
stdNew = sqrt( sumstd2numNew ./ ( ( nPnts - 1 ) ./ (nPnts) .*  sumWNew ) );

% update
aveOld = aveNew;
sumWOld = sumWNew;
stdOld = stdNew;
sumstd2numOld = sumstd2numNew; 
counter = counter - 1;
numAveBin = 1;
countedBins = binNum;

while continCond 
  indStart =  spaceLog(counter) ;
  indEnd = spaceLog(counter+1);
  vecTemp = log10( y( indStart:indEnd ) ./ x( indStart:indEnd ) );
  errTemp = erry( indStart:indEnd ) ./ ...
    ( sqrt( Nw( indStart:indEnd ) ) .* y( indStart:indEnd ) .* log(10)  );
  w = 1 ./ (errTemp.^2);
  nPnts = nPnts + length(vecTemp);
  
  sumstd2numNewTemp = sum( ( vecTemp - aveNew ) .^ 2 .* w );
  sumstd2numNew  = sumstd2numNew  +  sumstd2numNewTemp;
  sumVecTemp = sum(vecTemp .* w );
  sumVecNew = sumVecNew + sumVecTemp;
  sumWTemp = sum( w );
  sumWNew = sumWNew + sumWTemp;
  
  aveTemp = sumVecTemp ./ sumWTemp;
  aveNew = sumVecNew ./ sumWNew;
  stdNew = sqrt( sumstd2numNew ./ ( ( nPnts - 1 ) ./ (nPnts) .*  sumWNew ) );
  
  if abs(aveTemp) > abs(aveOld) + stdOld || abs(aveTemp) < abs(aveOld) - stdOld
    continCond = 0;
    aveSteady = aveOld; 
    stdSteady = sqrt( sumstd2numOld ./ ( ( nPnts - 1 ) ./ (nPnts) .*  sumWOld ) );

    fprintf('Bin is no longer helping!\n')
  elseif counter == 0
    continCond = 0;
    aveSteady = 0;
    stdSteady = 0;
    fprintf('I have gone through all the bins.')
  else
    countedBins = [countedBins counter];
    aveOld = aveNew;
    sumWOld = sumWNew;
    stdOld = stdNew;
    sumstd2numOld = sumstd2numNew; 
    counter = counter - 1;
    numAveBin = numAveBin + 1;
  end
  % Update
%   abs(aveOld)
%   abs(aveOld) - stdOld
%   abs(aveNew)
%   abs(aveOld) + stdOld
%   continCond
  
end

fprintf( 'ave = % f std = %f bins = %d\n', aveSteady, stdSteady, numAveBin )

if length( countedBins ) == 1
  hAsymp = 0;
else
  indstart = spaceLog( countedBins(end) );
  indend = spaceLog( countedBins(1) + 1 ) ;
  rang2ave = x(  indstart : indend );
  data2ave = log10( y(  indstart : indend ) ./ x(  indstart : indend ) );
  err2ave = erry( indstart : indend );
  w = 1 ./ (err2ave.^2);
  sumW = sum(w);
  hAsymp =  sum( w .* data2ave ) ./ sumW;
  nPts = length( data2ave );
  sig_h  = sqrt ( sum ( w .* ( data2ave - hAsymp ) .^ 2 ) ./ ...
    ( (nPts-1) ./ nPts .* sumW ) );
  % fit it too
  pfit = fit( rang2ave, data2ave, 'poly1', 'weights',  w);
  
  hSlope = pfit.p1 .* ( log10( rang2ave(end) ) + log10( rang2ave(1) ) ) ./ 2 + pfit.p2;
  hold on
  plot(pfit) 
  sig_hSlop = abs( pfit.p1 .* ( log10( rang2ave(end) ) -  log10( rang2ave(1) ) )./ 2 );  
end
slopeTail = slopeBin(end);
slopeStart = slopeBin(1);

tAsymp = ( hAsymp - log10( ( y(1) ./x(1) ) ) ) ./ slopeStart + log10( x(1) ) ; 


% Plot it
figure()
plot( log10( x ), log10( y./x ) )
xlabel( 'log_{10} (t) ' ); ylabel( 'log_{10} (x^2/t) ' );
title('Log Plot Data and bin lines')
hold on
plot( log10( x ), ones( length(x) ,1 ) .* hAsymp, ...
  log10( x ), slopeStart .* ( log10( x ) - log10( x(1) ) ) + log10( y(1) ./x(1) ) )

