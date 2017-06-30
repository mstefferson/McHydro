% place tracers based on binding
% tracers are size one

%function obj = place_tracers( nTracer, availObstSites, emptySites, ffo, be, gridSize )
function obj = place_tracers( nTracer, obst, be, ffoAct, gridSize )

% dimension and sites
dim = length(gridSize);
numSites = prod( gridSize );

% keep track of number
obj.num = nTracer;
obj.ffActual = nTracer ./ numSites;
obj.length = 1;

% find how many tracers to place on each obstacle
num_obst_types = length(obst);

% change ff is only placing on edges and get total filled sites
filledObstSites = [];
for ii = 1:num_obst_types
  if obst{ii}.edgePlace
    ffTemp = obst{ii}.numEdges ./ ...
      ( numSites - obst{ii}.numFilledSite + obst{ii}.numEdges );
    ffoAct(ii) = ffTemp;
  end
  filledObstSites = [filledObstSites; obst{ii}.allpts];
end

% scramble the order. No favorites!!!
emptySites = setdiff( 1:numSites, filledObstSites);
ind = 1:num_obst_types;
numTracerEmpty = (1-sum(ffoAct) );
boltzFac = [ ffoAct .* exp( be' ); numTracerEmpty];
normFac = sum( boltzFac );
tracersOccNum = round( nTracer * boltzFac(ind) / normFac );
tracerOccFrac = boltzFac(ind)  / normFac;

% allocate
obj.allpts = zeros( nTracer, 1 );
obj.state = zeros( nTracer, 1 );
holder = 1;
totalPlaced = 0;
for ii = 1:num_obst_types
  if tracersOccNum(ii) > 0
    tracerInd = holder:holder+tracersOccNum(ii)-1;
    if obst{ii}.edgePlace
      availObstSites = obst{ii}.edgeInds;
    else
      availObstSites = obst{ii}.allpts;
    end
    % place them
   
    obj.allpts( tracerInd ) = availObstSites( ...
         randi( length(availObstSites), [1 tracersOccNum(ii)] ) );
    obj.state( tracerInd ) = ii;
  
    holder = holder+tracersOccNum(ii);
    totalPlaced = totalPlaced + tracersOccNum(ii);
  end
  
  % place the rest on empty
  numTrEmpty = nTracer - totalPlaced;
  if numTrEmpty > 0
    obj.allpts( totalPlaced+1:nTracer ) = emptySites( randi( length(emptySites), [1 numTrEmpty] ) );
  end
  
  % convert it to x,y indices
  obj.center = zeros( nTracer, 3 );
  [obj.center(:,1), obj.center(:,2), obj.center(:,3) ] = ind2sub( gridSize, obj.allpts );
  obj.center = obj.center(:,1:dim);
  obj.occNum = tracersOccNum;
  obj.occFrac = tracerOccFrac;

end


