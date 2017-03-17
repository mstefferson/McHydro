% place tracers based on binding
% tracers are size one

function obj = place_tracers( fft, obstSite, ffo, be, gridSize )
% dimension and sites
dim = length(gridSize);
numSites = prod( gridSize );
% keep track of number
nTracer = round(fft*numSites);
obj.num = nTracer;
obj.ffWant = fft;
obj.ffActual = nTracer ./ numSites; 
obj.length = 1;

% calculate how many tracers should be on obstacles or not
numTrObst = round( nTracer * exp( -be ) * ffo ./ ( (1 - ffo ) + exp( -be ) .* ffo ) );
numTrEmpty = nTracer - numTrObst;

% find empty sites
totalSite = 1:numSites;
emptySite = totalSite( ~ismember( totalSite, obstSite ) );

% put tracers on obstacles and empty sites randomly
obj.allpts = zeros( nTracer, 1 );
obj.allpts( 1:numTrObst ) = obstSite( randi( length(obstSite), [1 numTrObst] ) );
obj.allpts( numTrObst+1:nTracer ) = emptySite( randi( length(emptySite), [1 numTrEmpty] ) );

% convert it to x,y indices
obj.center = zeros( nTracer, 3 );
[obj.center(:,1), obj.center(:,2), obj.center(:,3) ] = ind2sub( gridSize, obj.allpts );
obj.center = obj.center(:,1:dim);

% save corners just in case
obj.corner = obj.center;

end


