function getHorzAsymptotes( x, y, numBins, threshold )

% break x up uniformly number of points
nPtns = length(x);
% linear
% dataBinInds = round( linspace( 1, nPtns, numBins+1) );
dataBinInds = round( logspace( log10(1), log10(nPtns), numBins+1) );
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
  w = ones(1, length(xTemp) );
  pfit = fit( xTemp', yTemp', 'poly1', 'weights',  w');
  slopeBin(ii) = pfit.p1;
  yinterBin(ii) =  pfit.p2;
  xCenterBin(ii) = ( xTemp(end) + xTemp(1) ) / 2;
  numPtnsBin(ii) = length(xTemp);
  centerYValBin(ii) = pfit.p1 .* xCenterBin(ii) + pfit.p2;
  deltaYValBin(ii) = pfit.p1 .* ( xTemp(end) - xTemp(1) );
  thresTest(ii) = abs( deltaYValBin(ii) ./ centerYValBin(ii) );
end

%find flat inds. If they are adjacent, plot them all together
acceptedFlatBins = thresTest < threshold;
failedInds = find( acceptedFlatBins == 0 );
maxFlats = length( failedInds ) + 1;
% add start and end
failedInds = [ 0 failedInds numBins+1 ];

flatInds = cell( 1, maxFlats  );
for ii = 1:length( failedInds )-1
  indRange = failedInds(ii)+1:failedInds(ii+1)-1;
%   if indRange == failedInds(ii)
%     indRange = []
%   end
  flatInds{ii} = indRange;
end
flatInds = flatInds( ~cellfun('isempty',flatInds) );
  
% now fit over range of flat data
numAsymptotes = length( flatInds );
slopeAsym = zeros(1, numAsymptotes);
yInterAsym = zeros(1, numAsymptotes); 
xCenterAsym = zeros(1, numAsymptotes);
numPtnsAsym = zeros(1, numAsymptotes);
centerYValAsym = zeros(1, numAsymptotes);
deltaYValAsym = zeros(1, numAsymptotes);
for ii = 1:numAsymptotes
  bins2count = flatInds{ii};
  indStart = dataBinInds( bins2count(1) );
  indEnd = dataBinInds( bins2count(end) + 1 );
  xTemp = x( indStart:indEnd );
  yTemp = y( indStart:indEnd );
  w = ones(1, length(xTemp) );
  pfit = fit( xTemp', yTemp', 'poly1', 'weights',  w');
  slopeAsym(ii) = pfit.p1;
  yInterAsym(ii) =  pfit.p2;
  xCenterAsym(ii) = ( xTemp(end) + xTemp(1) ) / 2;
  numPtnsAsym(ii) = length(xTemp);
  centerYValAsym(ii) = pfit.p1 .* xCenterAsym(ii) + pfit.p2;
  deltaYValAsym(ii) = abs( pfit.p1 .* ( xTemp(end) - xTemp(1) ) );
end

keyboard