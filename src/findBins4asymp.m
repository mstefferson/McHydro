% [ aveSteady, sigSteady, countedBins] = ...
%  findBins4asymp( bins2try, spaceLog, x, y, erry )

function [ aveSteady, sigSteady, countedBins] = ...
  findBins4asymp( bins2try, spaceLog, x, y, erry )
% To start set everything to zero
sumVecNew = 0;
sumWNew = 0;
aveNew = 0;
stdNew = 1000;
% update
aveOld = aveNew;
stdOld = stdNew;
trackAccept = zeros( 1, length(bins2try) );
vecTotal = [];
wTotal = [];
for ii=1:length(bins2try)
  binTemp = bins2try(ii);
  indStart =  spaceLog(binTemp) ;
  indEnd = spaceLog(binTemp+1);
  vecTemp = log( y( indStart:indEnd ) ./ x( indStart:indEnd ) );
  errTemp = erry( indStart:indEnd ) ./ y( indStart:indEnd ) ;
  wTemp = 1 ./ (errTemp.^2);
  % Calculate average of bin
  sumVecTemp = sum(vecTemp .* wTemp );
  sumWTemp = sum( wTemp );
  aveTemp = sumVecTemp ./ sumWTemp;
  % See if new bin helps
  if abs(aveTemp) > abs(aveOld) + stdOld || ...
      abs(aveTemp) < abs(aveOld) - stdOld % doesnt
    trackAccept(ii) = 0;
  else % does
    % Add it to the vector
    vecTotal = [vecTotal; vecTemp];
    wTotal = [wTotal; wTemp];
    nPnts = length( vecTotal );
    % Update sums
    sumWNew = sumWNew + sumWTemp;
    sumVecNew = sumVecNew + sumVecTemp;
    aveNew = sumVecNew ./ sumWNew;
    sumstd2numNew = sum( ( vecTotal - aveNew ) .^ 2 .* wTotal );
    stdNew = sqrt( sumstd2numNew ./ ( ( nPnts - 1 ) ./ (nPnts) .*  sumWNew ) );
    % Update average
    aveOld = aveNew;
    stdOld = stdNew;
    trackAccept(ii) = 1;
  end
end
% See how many bins helped and store output
countedBins = bins2try(trackAccept == 1);
aveSteady =  aveNew;
sigSteady =  stdNew;
end