function [obst, hopInfo] = buildObstMaster( obstCell, freeDiff, grid, colorArray )

% get place order. place walls first
num_obst_types = length( obstCell );
% get a list of the obstacle types
placeInds = zeros( 1, num_obst_types );
sizeVec   = zeros( 1, num_obst_types );
sizeVecInd = zeros( 1, num_obst_types );
placeIndHolder = 1;
numTypes = zeros( 1, 2); % 'walls, rand'
for ii = 1:num_obst_types
  % place walls first
  if strcmp( obstCell{ii}{1}, 'wall' )
    placeInds( placeIndHolder ) = ii;
    placeIndHolder = placeIndHolder + 1;
    numTypes(1) = numTypes(1) + 1;
  else % get sizes of random for their place order
    sizeVec(ii) =  obstCell{ii}{2}(4);
    sizeVecInd(ii) = ii;
    numTypes(2) = numTypes(2) + 1;
  end
end
sizeVec = sizeVec( sizeVec ~= 0 );
sizeVecInd = sizeVecInd( sizeVecInd ~= 0 );
% sort by size size
[~, sortInd] = sort( sizeVec, 'descend' );
placeInds( numTypes(1)+1 : numTypes(1)+numTypes(2) ) = sizeVecInd(sortInd);
% have obstacle as a cell of obst structures
obst = cell(1, num_obst_types+1);
filledSites = [];
wallStartLoc = grid.sizeV( 2 );
% build vectors for transition matrix
be = zeros(1,num_obst_types+1);
hopProb = zeros(1,num_obst_types+1);
ff = zeros(1,num_obst_types+1);
% place tracers
for ii = 1:num_obst_types
  obstCellInput = obstCell{ placeInds(ii) };
  if strcmp( obstCellInput{1}, 'wall' )
     out = WallObstClass( obstCellInput{2}(1),obstCellInput{2}(2),  ...
       obstCellInput{2}(3),obstCellInput{2}(4),...
       colorArray(ii,:), grid, wallStartLoc );
     wallStartLoc = wallStartLoc-out.Thickness;
     filledSites = [ filledSites; out.AllPts ];
  end
  if strcmp( obstCellInput{1}, 'rand' )
    out = RandObstClass( obstCellInput{2}(1), obstCellInput{2}(2),  ...
      obstCellInput{2}(3), obstCellInput{2}(4),...
      obstCellInput{2}(5), obstCellInput{2}(6), colorArray(ii,:), grid, filledSites );
    filledSites = [ filledSites; out.AllPts ];
  end
  obst{ii} = out;
  be(ii) = out.Be;
  hopProb(ii) = out.SiteDiff;
  ff(ii) = out.Ff;
end
% fill out empty obstacl
out = EmptyObstClass( freeDiff, filledSites, grid.totPnts );
obst{num_obst_types+1} = out;
be(num_obst_types+1) = out.Be;
hopProb(num_obst_types+1) = out.SiteDiff;
ff(num_obst_types+1) = 1 - sum( ff(1:num_obst_types) );
% Build transition matrix
% T(i,j): i-final state, j-initial stae
deltaG = be' - be;
bindT = exp( -deltaG );
bindT(bindT>1) = 1;
hopT = repmat( hopProb, [num_obst_types+1, 1] ) ;
hopT(end,:) = 1; % can always hop to empty
% accept probability
hopInfo.acceptT = hopT .* bindT;
hopInfo.sizeT = size( hopT );
hopInfo.be = be;
hopInfo.ff = ff;
