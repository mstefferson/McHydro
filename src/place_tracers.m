% place tracers based on binding

function obj = place_tracers( nTracer, ng, obstSite, ffo, be )

% calculate how many tracers should be on obstacles or not
numTrObst = round( ng ^ 2 .* exp( -be ) * ffo ./ ( (1 - ffo ) + exp( -be ) .* ffo ) );
numTrEmpty = nTracer - numTrObst;

% find empty sites
totalSite = 1:ng^2;
emptySite = totalSite( ~ismember( totalSite, obstSite ) );

% put tracers on obstacles and empty sites randomly
obj.allpts = zeros( nTracer, 1 );
obj.allpts( 1:numTrObst ) = obstSite( randi( length(obstSite), [1 numTrObst] ) );
obj.allpts( numTrObst+1:nTracer ) = emptySite( randi( length(emptySite), [1 numTrEmpty] ) );

% convert it to x,y indices
[obj.center(:,1), obj.center(:,2) ] = ind2sub( [ng ng], obj.allpts );

end


