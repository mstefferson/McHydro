function [slopeBin, centerVal, numPnts ]= findHorztlAsymp(x,y,erry,nAve)

% Vector is noisey. Bin it to smooth it out
binNum = 10;
% binSize = ceil( length(y) ./ binNum );
% length of vector
nV = length(x);
% Store slope and center of each bin
slopeBin = zeros( binNum, 1);
centerVal = zeros( binNum, 1);
aveBin = zeros( binNum, 1);
stdBin = zeros( binNum, 1);
numPnts = zeros( binNum, 1 );

spaceLog = floor( logspace( 0, log10( length(x) ), binNum + 1 ) );

figure()
plot( log10( x ), log10( y./x ) )
hold on
% Do a linear fit of data between points in a bin
for ii = 1:binNum
  indStart =  spaceLog(ii) ;
  indEnd = spaceLog(ii+1) ;
  yTemp = log10( y( indStart:indEnd ) ./ x( indStart:indEnd ) );
  xTemp =  log10( x( indStart:indEnd ) );
  ptsTemp = length(yTemp);
  p = polyfit( xTemp, yTemp,1 );
  slopeBin(ii) = p(1);
  centerVal(ii) = p(1) .* xTemp( round( ptsTemp / 2 ) ) + p(2);
  numPnts(ii) = ptsTemp;
  aveBin(ii) = mean( yTemp );
  stdBin(ii) = std( yTemp );
  plot( xTemp, p(1) .* xTemp  + p(2) );
end


% Find maximun possible windows
NwDesired = 100;
NwMax = ceil( (nV+1) ./ (1:nV) ) - 1; % minus cause ind start at 1
Nw = min( NwDesired, NwMax )';

% Plot with error bars
figure()
errorbar( log10(x), log10(y./x), erry ./ ( y .* log(10) .* sqrt(nAve .* Nw ) ) );

figure()

deltaSlope = 0.01;
vec2ave = [];
err4ave = [];
countedBins = [];
stdY = [];
deltaY = [];
for ii = 1:binNum
  indStart =  spaceLog(ii) ;
  indEnd = spaceLog(ii+1);
  deltaY = [ deltaY slopeBin(ii) .* ( log10( x(indEnd) ) - log10( x(indStart) ) )];
  stdY = [stdY std( log10( y( indStart:indEnd ) ./ x( indStart:indEnd ) )  ) ];
  
  if abs( slopeBin(ii) ) <  deltaSlope
    %     indStart =  spaceLog(ii) ;
    %     indEnd = spaceLog(ii+1) ;
    vec2ave = [ vec2ave; log10( y( indStart:indEnd ) ./ x( indStart:indEnd ) ) ];
    err4ave = [ err4ave; erry( indStart:indEnd ) ./ ...
      ( sqrt( Nw( indStart:indEnd ) ) .* y( indStart:indEnd ) .* log(10)  )];
    %     deltaY = [ deltaY slopeBin(ii) .* ( log10( x(indEnd) ) - log10( x(indStart) ) )];
    %     stdY = [stdY std( vec2ave ) ];
    countedBins = [ countedBins ii ];
  end
end

figure()
plotyy( 1:binNum, slopeBin, 1:binNum, centerVal );

% keyboard
horzAsymp = mean( vec2ave  );
stdAsymp = std( vec2ave );
nPnts = length( vec2ave );

sumWNew = sum ( 1 ./ err4ave .^2) ;
horzAsympW =  sum( vec2ave ./ (err4ave .^2) ) ./ ( sumWNew );
stdAsympW = sum ( (vec2ave - horzAsympW ) .^ 2 ./ (err4ave .^2) ) ./ ...
  ( ( nPnts - 1 ) ./ (nPnts) .*  sumWNew ) ;

stdAsympW = sqrt( stdAsympW );

slopeOut = slopeBin(1);
D = 10 ^ horzAsympW;
Dsig = stdAsympW .* log( 10 ) .* 10 ^ (horzAsympW);

% intercept slope and asymptote
xInt =  ( horzAsympW - log10( y(1) ./ x(1) ) ) ./ slopeOut + log10( x(1) );
tAnom = 10 ^ ( xInt );
inds = find( log10(x) < xInt );
inds = [ inds; ( inds(end)+1: inds(end)+10 )' ];
% plot( log10(x), slopeOut .* ( log10(x) - log10(x(1)) ) + log10( y(1) ./ x(1) ) )

figure()
plot( log10( x ), log10( y./x ) )
hold on
plot( log10( x(inds) ), slopeOut .* ( log10( x(inds) ) - log10(x(1)) ) + log10( y(1) ./ x(1) ) )
plot( log10( x ), horzAsympW .* ones(1,nV) )

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
numAveBin = 0;

while continCond
  numAveBin = numAveBin + 1;
    
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
  end
  
  if counter == 1
    continCond = 0;
    aveSteady = 0;
    stdSteady = 0;
  end
  % Update
%   abs(aveOld)
  abs(aveOld) - stdOld
  abs(aveNew)
  abs(aveOld) + stdOld
  continCond
  
  keyboard
  aveOld = aveNew;
  sumWOld = sumWNew;
  stdOld = stdNew;
  sumstd2numOld = sumstd2numNew; 
  counter = counter - 1;

end

fprintf( 'ave = % f std = %f bins = %d\n', aveSteady, stdSteady, numAveBin )

% If one bind, break
keyboard
