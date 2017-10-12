function [D, sigD] = getDfromMsdData( t, msd, msdErr, msdNumPtns, numBins, threshold, plotFlag )
if nargin == 4
  numBins = 10;
  threshold = 0.1;
  plotFlag = 1;
elseif nargin == 5
  threshold = 0.1;
  plotFlag = 0;
elseif nargin == 6
  plotFlag = 0;
end

% convert inputs to what getHorzAsymptotes wants
x = log( t );
y = log( msd / t );
errY = msdErr ./ msd;
asymInfo = getHorzAsymptotes( x, y, errY, numBins, threshold, 'eqDeltaDist', plotFlag );

if asymInfo.numAsymptotes == 0
  fprintf('No asymptotes found. Try altering threshold and bin number\n' )


end
