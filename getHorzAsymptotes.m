function getHorzAsymptotes( x, y, w, numBins, threshold, binSpacingType )

% break x up uniformly number of points
nPtns = length(x);
% if no weights, set them to one
if isempty(w)
  w = ones(1, nPtns );
end
% if no bin spacing selected, do equidistant bin spacing
if nargin < 6
  binSpacingType  = [];
end
% make sure x,y,w are column vectors
if isrow(x); x = x.'; end
if isrow(y); y = y.'; end
if isrow(w); w = w.'; end

% linear
% dataBinInds = round( linspace( 1, nPtns, numBins+1) );
if isempty( binSpacingType ) || strcmp( binSpacingType, 'eqDeltaDist' )
  binSpacingType = 'eqDeltaDist';
  equalSpacesXVal = linspace( x(1), x(end), numBins+1 );
   dataBinInds = zeros( 1, numBins + 1 );
for ii = 1:numBins + 1
  [~,ind] = min( abs( x - equalSpacesXVal(ii) ) );
  dataBinInds(ii) = ind;
end
elseif strcmp( binSpacingType, 'eqDeltaInd' )
dataBinInds = round( linspace( 1, nPtns, numBins+1) );
else
  error('Cannot understand desired bin spacing')
end

% allocate
slopeBin = zeros(1, numBins);
yinterBin = zeros(1, numBins); 
xCenterBin = zeros(1, numBins);
numPtnsBin = zeros(1, numBins);
centerYValBin = zeros(1, numBins);
deltaYValBin = zeros(1, numBins);
thresTest = zeros(1, numBins);
% loop over bins
for ii = 1:numBins
  indStart = dataBinInds(ii);
  indEnd = dataBinInds(ii+1);
  xTemp = x( indStart:indEnd );
  yTemp = y( indStart:indEnd );
  wTemp = w( indStart:indEnd );
  pfit = fit( xTemp, yTemp, 'poly1', 'weights',  wTemp);
  slopeBin(ii) = pfit.p1;
  yinterBin(ii) =  pfit.p2;
  xCenterBin(ii) = ( xTemp(end) + xTemp(1) ) / 2;
  numPtnsBin(ii) = length(xTemp);
  centerYValBin(ii) = pfit.p1 .* xCenterBin(ii) + pfit.p2;
  deltaYValBin(ii) = pfit.p1 .* ( xTemp(end) - xTemp(1) );
  thresTest(ii) = abs( deltaYValBin(ii) ./ centerYValBin(ii) );
end

% get max slope and intercept
[maxSlopeSlopeVal, maxSlopeBin] = min( slopeBin );
maxSlopeInterceptVal = yinterBin( maxSlopeBin );

%find flat inds. If they are adjacent, plot them all together
acceptedFlatBins = thresTest < threshold;
failedInds = find( acceptedFlatBins == 0 );
maxFlats = length( failedInds ) + 1;
% add start and end
failedInds = [ 0 failedInds numBins+1 ];

flatInds = cell( 1, maxFlats  );
for ii = 1:length( failedInds )-1
  indRange = failedInds(ii)+1:failedInds(ii+1)-1;
  flatInds{ii} = indRange;
end
% get rid of empty cells
flatInds = flatInds( ~cellfun('isempty',flatInds) );
  
% now fit over range of flat data
numAsymptotes = length( flatInds );
slopeAsym = zeros(1, numAsymptotes);
yInterAsym = zeros(1, numAsymptotes); 
xCenterAsym = zeros(1, numAsymptotes);
numPtnsAsym = zeros(1, numAsymptotes);
centerYValAsym = zeros(1, numAsymptotes);
deltaYValAsym = zeros(1, numAsymptotes);
maxSlopeAsymIntercept =  zeros(1, numAsymptotes);
asymBinEnd = zeros(1, numAsymptotes); 
asymBinStart = zeros(1, numAsymptotes); 
for ii = 1:numAsymptotes
  bins2count = flatInds{ii};
  indStart = dataBinInds( bins2count(1) );
  indEnd = dataBinInds( bins2count(end) + 1 );
  asymBinEnd(ii) = bins2count(end) + 1;
  asymBinStart(ii) = bins2count(1);
  xTemp = x( indStart:indEnd );
  yTemp = y( indStart:indEnd );
  wTemp = ones(1, length(xTemp) );
  pfit = fit( xTemp, yTemp, 'poly1', 'weights',  wTemp);
  slopeAsym(ii) = pfit.p1;
  yInterAsym(ii) =  pfit.p2;
  xCenterAsym(ii) = ( xTemp(end) + xTemp(1) ) / 2;
  numPtnsAsym(ii) = length(xTemp);
  centerYValAsym(ii) = pfit.p1 .* xCenterAsym(ii) + pfit.p2;
  deltaYValAsym(ii) = abs( pfit.p1 .* ( xTemp(end) - xTemp(1) ) );
  maxSlopeAsymIntercept(ii) = ( centerYValAsym(ii) - maxSlopeInterceptVal )...
    / maxSlopeSlopeVal;
end

% plot
figure()
plot( x, y );
ax = gca;
axisYLim =  ax.YLim;
ax.XLim = [ x(1) x(end) ];
hold
% max slope line
plot( x, maxSlopeSlopeVal * x + maxSlopeInterceptVal,'k-');
ax.YLim = axisYLim;
% plot bins
slopeLarge = 1000 .* max(y);
transparVal = 0.25;
for ii = 1:numBins-1
  indEnd = dataBinInds(ii+1);
  if isempty( intersect( ii+1, [asymBinEnd asymBinStart] ) )
    p = plot( x, slopeLarge .* ( x - x(indEnd) ), 'k:' );
  else
    p = plot( x, slopeLarge .* ( x - x(indEnd) ), 'r:' );
  end
  p.Color(4) = transparVal;
end
% plot asymptote regions
onesVec = ones( 1, nPtns );
for ii = 1:numAsymptotes
  % asymptote
  p = plot( x, centerYValAsym(ii) .* onesVec,'-' );
  p.Color = [0.75 0 0];
  % Their intercept
  p = plot( x, slopeLarge .* ( x - maxSlopeAsymIntercept(ii) ), '--'  );
  p.Color = [0 0.5 0];
end
title('Asymptotes, bins, max slope, and intercepts!');
ylabel('$$ y $$');
xlabel('$$ x $$');
