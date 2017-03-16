%place obstacles on seperate lattice sites can handle size effects

function obst = place_obstacles( ff, lobst, gridSize, excludeVol )
% make sure length of obstacle is at least one
lobst = max( lobst, 1 );
% get dimension and add ones for unused higher dimensions
dim = length(gridSize);
gridTemp = ones(1,3);
gridTemp(1:dim) = gridSize;
gridSize = gridTemp;
% number of sites to fill
numSites = prod( gridSize );
deltaL1 = round( lobst-1 );
deltaL2 = round( (lobst-1) .* min( floor( dim/2 ), 1 ) );
deltaL3 = round( (lobst-1) .* min( floor( dim/3 ), 1 ) );
if ~excludeVol
  % if you can overlap, floor your max corners
  maxFilledCorners = floor( ff * numSites / (lobst^dim) );
  maxFilledSites = round( ff * numSites );
else
  % if exclude, do the best you can
  maxFilledCorners = round( ff * numSites / (lobst^dim) );
  maxFilledSites = maxFilledCorners .* lobst^dim;
end
% all Sites
allSitesOpen = 1:numSites;
availCorners = allSitesOpen;
numCornersAvail = length( availCorners );
% number of filled
allSitesFilled = [];
% do Initial fill
if ~excludeVol
  numCornersInit = maxFilledCorners;
else
  numCornersInit = 1;
end
obstCornersInds = randperm( numCornersAvail, numCornersInit );
obstCorners = availCorners( obstCornersInds )';
% Find coordinates
for nn = 1:numCornersInit
  [i, j, k] = ind2sub( gridSize, obstCorners(nn) );
  newiFill = mod( (i:i+deltaL1) - 1, gridSize(1) ) + 1;
  newjFill = mod( (j:j+deltaL2) - 1, gridSize(2) ) + 1;
  newkFill = mod( (k:k+deltaL3) - 1, gridSize(3) ) + 1;
  newComb = combvec( newiFill, newjFill, newkFill );
  newInds = sub2ind( gridSize, newComb(1,:)', newComb(2,:)', newComb(3,:)' );
  % Find actual new
  actualNewSites = setdiff( newInds, allSitesFilled );
  allSitesFilledTemp = [allSitesFilled; actualNewSites];
  allSitesFilled = allSitesFilledTemp;
  if ~excludeVol
    availCorners = setdiff( availCorners, obstCorners(nn)  );
    numCornersAvail = max( numCornersAvail - 1, 0 );
  else
    newiNoCorner = mod( (i-deltaL1:i+deltaL1) - 1, gridSize(1) ) + 1;
    newjNoCorner = mod( (j-deltaL2:j+deltaL2) - 1, gridSize(2) ) + 1;
    newkNoCorner = mod( (k-deltaL3:k+deltaL3) - 1, gridSize(2) ) + 1;
    newComb = combvec( newiNoCorner, newjNoCorner, newkNoCorner  );
    newInds = sub2ind( gridSize, newComb(1,:)', newComb(2,:)', newComb(3,:)'  );
    availCorners = setdiff( availCorners, newInds  );
    numCornersAvail = length(availCorners);
  end
end
% save unique
allSitesFilled = unique( allSitesFilled );
numSitesFilled = length( allSitesFilled );
% Now fill in remaining
% Fill until you cannot
numTrys = 0;
while (numSitesFilled ~= maxFilledSites) && (numCornersAvail ~= 0)
  % guess a new corner
  newCornerInds = randperm( numCornersAvail, 1 );
  newCorner = availCorners( newCornerInds );
  [i, j, k] = ind2sub( gridSize, newCorner );
  newiFill = mod( (i:i+deltaL1) - 1, gridSize(1) ) + 1;
  newjFill = mod( (j:j+deltaL2) - 1, gridSize(2) ) + 1;
  newkFill = mod( (k:k+deltaL3) - 1, gridSize(3) ) + 1;
  newComb = combvec(newiFill, newjFill, newkFill);
  newInds = sub2ind( gridSize, newComb(1,:)', newComb(2,:)', newComb(3,:)' );
  % Find actual new
  actualNewSites = setdiff( newInds, allSitesFilled );
  numActualNew = length( actualNewSites );
  % See if we can accept
  numSiteFilledTemp = numSitesFilled + numActualNew;
  % accept
  if numSiteFilledTemp <= maxFilledSites && ~isempty( actualNewSites )
    % update all filled sites
    allSitesFilledTemp = [allSitesFilled; actualNewSites ];
    allSitesFilled = allSitesFilledTemp; 
    % Add new center
    obstCorners = unique( [obstCorners; newCorner] );
    if ~excludeVol
      availCorners = setdiff( availCorners, newCorner );
      numCornersAvail =  max( numCornersAvail - 1, 0 );
    else
      newiNoCorner = mod( (i-deltaL1:i+deltaL1) - 1, gridSize(1) ) + 1;
      newjNoCorner = mod( (j-deltaL2:j+deltaL2) - 1, gridSize(2) ) + 1;
      newkNoCorner = mod( (k-deltaL3:k+deltaL3) - 1, gridSize(3) ) + 1;
      newComb = combvec( newiNoCorner, newjNoCorner, newkNoCorner );
      newInds = sub2ind( gridSize, newComb(1,:)', newComb(2,:)', newComb(3,:)' );
      availCorners = setdiff( availCorners, newInds  );
      numCornersAvail =  length(availCorners);
    end
  else
    availCorners = setdiff( availCorners, newCorner );
    numCornersAvail =  length(availCorners);
  end
  % update what's not longer available
  allSitesFilled = unique( allSitesFilled );
  numSitesFilled = length( allSitesFilled );
  numTrys = numTrys + 1;
end
% save it in obst
% allocate
obst.num = length( obstCorners );
obst.ffWant = ff;
obst.ffActual = numSitesFilled ./ numSites;
obst.length = lobst;
obst.exclude = excludeVol;
obst.trys2fill = numTrys;
obst.corner = zeros( obst.num, 3 ); obst.center = zeros( obst.num, 3 ); 
% corners
obst.cornerInds = obstCorners;
[obst.corner(:,1), obst.corner(:,2), obst.corner(:,3)] = ind2sub( gridSize, obstCorners );
% centers
deltaCen = floor( ( lobst - 1 ) / 2 );
obst.center(:,1) = mod( obst.corner(:,1) + deltaCen - 1, gridSize(1) ) + 1;
obst.center(:,2) = mod( obst.corner(:,2) + deltaCen - 1, gridSize(2) ) + 1;
obst.center(:,3) = mod( obst.corner(:,3) + deltaCen - 1, gridSize(3) ) + 1;
obst.centerInds = sub2ind( gridSize, obst.center(:,1), obst.center(:,2), obst.center(:,3) );
% all ptns
obst.allpts = allSitesFilled;
obst.numFilledSite = numSitesFilled;
% get rid of unused dims
obst.corner = obst.corner(:,1:dim);
obst.center = obst.center(:,1:dim);
end
