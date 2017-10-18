function [obst, hopInfo] = buildObstMaster( obstCell, freeDiff, gridObj, colorArray )

% get place order. place walls first
num_obst_types = length( obstCell );
% get a list of the obstacle types
obstPlaceOrder = zeros( 1, num_obst_types );
sizeVec   = zeros( 1, num_obst_types );
sizeVecInd = zeros( 1, num_obst_types );
teleportInd = zeros( 1, num_obst_types );
speclocInd = zeros( 1, num_obst_types );
placeIndHolder = 1;
numTypes = zeros( 1, 4); % 'walls, rand, teleport, placed'
for ii = 1:num_obst_types
  % place walls first
  if  strcmp( obstCell{ii}{1}, 'rand' )
    sizeVec(ii) =  obstCell{ii}{2}(4);
    sizeVecInd(ii) = ii;
    numTypes(1) = numTypes(1) + 1;
  elseif strcmp( obstCell{ii}{1}, 'wall' )
    obstPlaceOrder( placeIndHolder ) = ii;
    placeIndHolder = placeIndHolder + 1;
    numTypes(2) = numTypes(2) + 1;
    % get sizes of random for their place order
  elseif strcmp( obstCell{ii}{1}, 'teleport' )
    teleportInd(ii) = ii;
    numTypes(3) = numTypes(3) + 1;
  elseif strcmp( obstCell{ii}{1}, 'specloc' )
    speclocInd(ii) = ii;
    numTypes(4) = numTypes(4) + 1;
  end
end
% get rid of zeros
sizeVec = sizeVec( sizeVec ~= 0 );
sizeVecInd = sizeVecInd( sizeVecInd ~= 0 );
teleportInd = teleportInd( teleportInd ~= 0 );
speclocInd = speclocInd( speclocInd ~= 0 );
% place teleport after wall
totPlaced = numTypes(2);
obstPlaceOrder( totPlaced+1:(totPlaced+numTypes(3)) ) = teleportInd;
% place specloc afer teleport 
totPlaced = totPlaced + numTypes(3);
obstPlaceOrder( totPlaced+1:(totPlaced+numTypes(4)) ) = speclocInd;
% sort by size size
totPlaced = totPlaced + numTypes(4);
[~, sortInd] = sort( sizeVec, 'descend' );
obstPlaceOrder( totPlaced+1: num_obst_types ) = sizeVecInd(sortInd);
% have obstacle as a cell of obst structures
obst = cell(1, num_obst_types+1);
filledSites = [];
forbiddenWallStart = [];
% build vectors for transition matrix
be = zeros(1,num_obst_types+1);
hopProb = zeros(1,num_obst_types+1);
ff = zeros(1,num_obst_types+1);
% place tracers
for ii = 1:num_obst_types
  obstCellInput = obstCell{ obstPlaceOrder(ii) };
  if strcmp( obstCellInput{1}, 'wall' )
    startLocation = obstCellInput{2}(6);
    dim = obstCellInput{2}(5);
    thickness = obstCellInput{2}(3);
    desiredSites = (startLocation-thickness+1):startLocation;
    locCounter = 0;
    while ~isempty( intersect( desiredSites, forbiddenWallStart ) ) && locCounter < gridObj.sizeV( dim );
      startLocation = mod( startLocation - 1 - 1, ...
        gridObj.sizeV( dim ) ) + 1;
      locCounter = locCounter + 1;
      desiredSites = (startLocation-thickness+1):startLocation;
    end
    if locCounter == gridObj.sizeV(dim)
      fprintf('Error, could not place a wall at any start location\n')
      error('Error, could not place a wall at any start location\n')
    end
    out = WallObstClass( obstCellInput{2}(1), obstCellInput{2}(2),  ...
      obstCellInput{2}(3), obstCellInput{2}(4),...
      dim, startLocation, obstCellInput{2}(7),...
      colorArray(ii,:), gridObj);
    forbiddenWallStart = [forbiddenWallStart (startLocation-out.Thickness+1):startLocation];
    filledSites = [ filledSites; out.AllPts ];
  end
  if strcmp( obstCellInput{1}, 'rand' )
    out = RandObstClass( obstCellInput{2}(1), obstCellInput{2}(2),  ...
      obstCellInput{2}(3), obstCellInput{2}(4),...
      obstCellInput{2}(5), obstCellInput{2}(6), colorArray(ii,:), gridObj, filledSites );
    filledSites = [ filledSites; out.AllPts ];
  end
  if strcmp( obstCellInput{1}, 'teleport' )
    out = TeleportObstClass( obstCellInput{2}(1), obstCellInput{2}(2), ...
       obstCellInput{2}(3), gridObj );
    filledSites = [ filledSites; out.AllPts; out.SinkInds ];
  end
  if strcmp( obstCellInput{1}, 'specloc' )
    out = SpeclocObstClass( obstCellInput{2}(1), obstCellInput{2}(2), ...
       obstCellInput{2}(3), obstCellInput{2}(4), colorArray(ii,:), gridObj, filledSites );
    filledSites = [ filledSites; out.AllPts ];
  end
  obst{ii} = out;
  be(ii) = out.Be;
  hopProb(ii) = out.SiteDiff;
  ff(ii) = out.Ff;
end
% fill out empty obstacle
out = EmptyObstClass( freeDiff, filledSites, gridObj.totPnts );
obst{num_obst_types+1} = out;
be(num_obst_types+1) = out.Be;
hopProb(num_obst_types+1) = out.SiteDiff;
ff(num_obst_types+1) = 1 - sum( ff(1:num_obst_types) );
% Build transition matrix
% T(i,j): i-final state, j-initial stae
deltaG = be' - be;
bindT = exp( -deltaG );
bindT( isnan(bindT) ) = 1;
bindT(bindT>1) = 1;
hopT = ones( num_obst_types+1, num_obst_types+1 );
hopT( logical( eye(num_obst_types+1) ) ) = hopProb;
% accept probability
hopInfo.acceptT = hopT .* bindT;
hopInfo.sizeT = size( hopT );
hopInfo.be = be;
hopInfo.ff = ff;
