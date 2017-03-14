% place tracers based on binding

function obj = place_tracers( fft, ng, lt, obstSite, ffo, be, dim )
% keep track of number
numSites = ng^dim;
nTracer = round(fft*(ng/lt)^dim);
obj.num = nTracer;
obj.ffWant = fft;
obj.ffActual = nTracer ./ numSites; 
obj.length = lt;

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
[obj.center(:,1), obj.center(:,2) ] = ind2sub( [ng ng], obj.allpts );

end


