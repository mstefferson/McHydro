function [ aveSteady, sigSteady, countedBins] = ...
  findBins4asymp( bins2try, spaceLog, x, y, erry )

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
  vecTemp = log10( y( indStart:indEnd ) ./ x( indStart:indEnd ) );
  errTemp = erry( indStart:indEnd ) ./ ...
    ( y( indStart:indEnd ) .* log(10)  );
  wTemp = 1 ./ (errTemp.^2);
  
% Calculate average of bin
  sumVecTemp = sum(vecTemp .* wTemp );
  sumWTemp = sum( wTemp );
  aveTemp = sumVecTemp ./ sumWTemp;
%   stdTemp = std(vecTemp);
%   fprintf('old range: %f - %f. New: %f\n',  abs(aveOld) - stdOld, ...
%   abs(aveOld) + stdOld, abs(aveTemp) );
%   fprintf('newrange: %f - %f \n',  abs(aveTemp) - stdTemp, ...
%   abs(aveTemp) + stdTemp );

  if abs(aveTemp) > abs(aveOld) + stdOld || abs(aveTemp) < abs(aveOld) - stdOld    
%     fprintf('Bin is not helping! Not including %d\n', binTemp);
    trackAccept(ii) = 0;
  else

%     fprintf('Counting bin %d\n', binTemp );
    vecTotal = [vecTotal; vecTemp];
    wTotal = [wTotal; wTemp];
    nPnts = length( vecTemp ); 

    sumWNew = sumWNew + sumWTemp;
    sumVecNew = sumVecNew + sumVecTemp;
    aveNew = sumVecNew ./ sumWNew;
    sumstd2numNew = sum( ( vecTotal - aveNew ) .^ 2 .* wTotal );
    stdNew = sqrt( sumstd2numNew ./ ( ( nPnts - 1 ) ./ (nPnts) .*  sumWNew ) );
    aveOld = aveNew;
    stdOld = stdNew;
    trackAccept(ii) = 1;
  end
  % Update  
end

countedBins = bins2try(trackAccept == 1);
aveSteady =  aveNew;
sigSteady =  stdNew;

end