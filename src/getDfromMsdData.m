% [diffInfo] = getDfromMsdData( t, msd, msdErr, ...
%   threshold, numBins, plotFlag, verbose ) 
%
% outputs:
%   diffInfo: struct containing diffusion coefficient, standard deviation, 
%     the minimum anomalous scaling coefficient, and the anomalous time
%
% inputs: 
%   t: time delay
%   msd: msd data
%   msdErr: uncertainty on the msd data
%   threshold: threshold value for calling a bin as a horz. asymptote
%   numBins: number of bins to divide data into
%   plotFlag: plotting flag
%   verbose: print results to screen
%
function [diffInfo, asymInfo] = getDfromMsdData( t, msd, msdErr, ...
  threshold, numBins, plotFlag, verbose )
% handle arguments
if nargin == 3
  threshold = 0.1;
  numBins = 10;
  plotFlag = 0;
  verbose = 0;
elseif nargin == 4
  numBins = 10;
  plotFlag = 0;
  verbose = 0;
elseif nargin == 5
  plotFlag = 0;
  verbose = 0;
elseif nargin == 6
  verbose = 0;
end

% convert inputs to what getHorzAsymptotes wants
x = log( t );
y = log( msd ./ t );
errY = msdErr ./ msd;

% get aymptotes
asymInfo = getHorzAsymptotes( x, y, errY, threshold, ...
  numBins,'eqDeltaDist', plotFlag );

% if you plot, fix axis labels
if plotFlag
  ax = gca;
  ax.XLabel.String = '$$ \ln( t ) $$';
  ax.YLabel.String = '$$ \ln( r^2 / t ) $$';
end

% Store it
diffInfo.alpha = 1 + asymInfo.maxNegSlope;
diffInfo.maxNegSlope = asymInfo.maxNegSlope;
if asymInfo.numAsymptotes == 0
  diffInfo.steadyState = 0;
  if verbose
    fprintf('No asymptotes found. Try altering threshold and bin number\n' )
  end
  diffInfo.D = NaN;
  diffInfo.stdD = NaN;
  diffInfo.tAnom = NaN;
  diffInfo.tAnomSig = NaN;
else
  diffInfo.steadyState = 1;
  if verbose
    fprintf('Asymptotes found \n')
  end
  % calculate D from asymptote
  diffInfo.D = exp( asymInfo.aveW(end) );
  diffInfo.DSig = diffInfo.D * asymInfo.stdW(end);
  if asymInfo.maxSlopeAsymXIntercept(end) < asymInfo.xSmallestAsym(end)
    diffInfo.earlyAnom = 0;
    diffInfo.tAnom = exp( asymInfo.maxSlopeAsymXIntercept(end) );
    diffInfo.tAnomSig = -asymInfo.stdW(end) ./ asymInfo.maxNegSlope;
  else
    diffInfo.earlyAnom = 1;
    diffInfo.tAnom = exp( asymInfo.xSmallestAsym(end) );
    diffInfo.tAnomSig = 0;
    diffInfo.maxNegSlope = [];
  end
end
% verbose
if verbose
  fprintf( 'Long time diffusion D = %f p/m %f \n', ...
    diffInfo.D, diffInfo.DSig) 
  fprintf('max anom. coeff alpha = %f \n' , diffInfo.alpha)
  fprintf('anomalous time tanom = %f \n', diffInfo.tAnom);
end
% plot
if plotFlag
  % plot
  figure()
  plot( x, y );
  ax = gca;
  axisYLim =  ax.YLim;
  ax.XLim = [ x(1) x(end) ];
  hold
  % asymptote
  nPtns = length(x);
  onesVec = ones( 1, nPtns );
  p = plot( x,  asymInfo.aveW(end) .* onesVec,'-' );
  p.Color = [0.75 0 0];
  % max slope line
  slopeLarge = 1000 .* max(y);
  if diffInfo.earlyAnom == 0 
    plot( x, diffInfo.maxNegSlope * x + asymInfo.maxSlopeInterceptVal,'k-');
    ax.YLim = axisYLim;
    % Their intercept
    p = plot( x, slopeLarge .* ( x - asymInfo.maxSlopeAsymXIntercept(end) ), '--'  );
    p.Color = [0 0.5 0];
  end
  title('Fit Results');
  ax = gca;
  ax.XLabel.String = '$$ \ln( t ) $$';
  ax.YLabel.String = '$$ \ln( r^2 / t ) $$';
  hold off
end  % plotting routines