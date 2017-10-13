function [diffInfo] = getDfromMsdData( t, msd, msdErr, numPntsMsd, ...
  threshold, numBins, plotFlag, verbose )
if nargin == 3
  numPntsMsd = 1;
  threshold = 0.1;
  numBins = 10;
  plotFlag = 0;
  verbose = 0;
elseif nargin == 4
  threshold = 0.1;
  numBins = 10;
  plotFlag = 0;
  verbose = 0;
elseif nargin == 5
  numBins = 10;
  plotFlag = 0;
  verbose = 0;
elseif nargin == 6
  plotFlag = 0;
  verbose = 0;
elseif nargin == 7
  verbose = 0;
end

% convert inputs to what getHorzAsymptotes wants
x = log( t );
y = log( msd ./ t );
errY = msdErr ./ msd;
errYMean = errY ./ sqrt( numPntsMsd );
asymInfo = getHorzAsymptotes( x, y, errYMean, threshold, ...
  numBins,'eqDeltaDist', plotFlag );

% if you plot, fix axis labels
if plotFlag
  ax = gca;
  ax.XLabel.String = '$$ \ln( t ) $$';
  ax.YLabel.String = '$$ \ln( r^2 / t ) $$';
end

% Store it
diffInfo.alpha = 1 + asymInfo.maxNegSlope;
if asymInfo.numAsymptotes == 0
  if verbose
    fprintf('No asymptotes found. Try altering threshold and bin number\n' )
  end
  diffInfo.D = NaN;
  diffInfo.stdD = NaN;
  diffInfo.tAnom = NaN;
else
  if verbose
    fprintf('Asymptotes found' )
  end
  % calculate D from asymptote
  diffInfo.D = exp( asymInfo.aveW(end) );
  diffInfo.stdD = diffInfo.D * asymInfo.stdW(end);
  diffInfo.tAnom = exp( asymInfo.maxSlopeAsymXIntercept(end) );
end

