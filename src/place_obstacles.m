%place obstacles on seperate lattice sites can handle size effects

function obst = place_obstacles( ff, lobst, ng, excludeVol, dim )
% number of sites to fill
numSites = ng^dim;
deltaL = lobst-1;
if ~excludeVol
  % if you can overlap, floor your max corners
  maxFilledCorners = floor( ff * numSites / (lobst^2) );
  maxFilledSites = round( ff * numSites );
else
  % if exclude, do the best you can
  maxFilledCorners = round( ff * numSites / (lobst^2) );
  maxFilledSites = maxFilledCorners .* lobst^2;
end
% all Sites
allSitesOpen = 1:numSites;
availCorners = allSitesOpen;
numCornersAvail = length( availCorners );
% number of filled
allSitesFilled = [];
numAllSites = 0;
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
  [i, j] = ind2sub( [ng ng], obstCorners(nn) );
  newiFill = mod( (i:i+deltaL) - 1, ng ) + 1;
  newjFill = mod( (j:j+deltaL) - 1, ng ) + 1;
  newComb = combvec( newiFill, newjFill );
  newInds = sub2ind( [ng ng], newComb(1,:)', newComb(2,:)' );
  % Find actual new
  actualNewSites = setdiff( newInds, allSitesFilled );
  allSitesFilledTemp = [allSitesFilled; actualNewSites];
  allSitesFilled = allSitesFilledTemp;
  if ~excludeVol
    availCorners = setdiff( availCorners, obstCorners(nn)  );
    numCornersAvail = max( numCornersAvail - 1, 0 );
  else
    newiNoCorner = mod( (i-deltaL:i+deltaL) - 1, ng ) + 1;
    newjNoCorner = mod( (j-deltaL:j+deltaL) - 1, ng ) + 1;
    newComb = combvec( newiNoCorner, newjNoCorner );
    newInds = sub2ind( [ng ng], newComb(1,:)', newComb(2,:)' );
    availCorners = setdiff( availCorners, newInds  );
    numCornersAvail =  max( numCornersAvail - length(newInds), 0 );
  end
end
% 
allSitesFilled = unique( allSitesFilled );
numSitesFilled = length( allSitesFilled );
% Now fill in remaining
% Fill until you cannot
numTrys = 0;
while (numSitesFilled ~= maxFilledSites) && (numCornersAvail ~= 0)
  % guess a new corner
  newCornerInds = randperm( numCornersAvail, 1 );
  newCorner = availCorners( newCornerInds );
  [i, j] = ind2sub( [ng ng], newCorner );
  newiFill = mod( (i:i+deltaL) - 1, ng ) + 1;
  newjFill = mod( (j:j+deltaL) - 1, ng ) + 1;
  newComb = combvec(newiFill, newjFill);
  newInds = sub2ind( [ng ng], newComb(1,:)', newComb(2,:)' );
  % Find actual new
  actualNewSites = setdiff( newInds, allSitesFilled );
  numActualNew = length( actualNewSites );
  % See if we can accept
  numSiteFilledTemp = numSitesFilled + numActualNew;
  %   keyboard
  % accept
  if numSiteFilledTemp <= maxFilledSites && ~isempty( actualNewSites )
    % update nubmer of filled
    numSitesFilled = numSiteFilledTemp;
    % update all filled sites
    allSitesFilledTemp = [allSitesFilled; actualNewSites ];
    allSitesFilled = allSitesFilledTemp; 
    % Add new center
    obstCorners = unique( [obstCorners; newCorner] );
    if ~excludeVol
      availCorners = setdiff( availCorners, newCorner );
      numCornersAvail =  max( numCornersAvail - 1, 0 );
    else
      newiNoCorner = mod( (i-deltaL:i+deltaL) - 1, ng ) + 1;
      newjNoCorner = mod( (j-deltaL:j+deltaL) - 1, ng ) + 1;
      newComb = combvec( newiNoCorner, newjNoCorner );
      newInds = sub2ind( [ng ng], newComb(1,:)', newComb(2,:)' );
      availCorners = setdiff( availCorners, newInds  );
      numCornersAvail =  max( numCornersAvail - length(newInds), 0 );
    end
  else
    availCorners = setdiff( availCorners, newCorner );
    numCornersAvail =  numCornersAvail - 1;
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
obst.ffActual = numSitesFilled ./ ng^2;
obst.length = lobst;
obst.exclude = excludeVol;
obst.trys2fill = numTrys;
obst.corner = zeros( obst.num, 2 ); obst.centers = zeros( obst.num, 2 ); 
% corners
obst.cornerInds = obstCorners;
[obst.corner(:,1), obst.corner(:,2)] = ind2sub( [ng ng], obstCorners );
% centers
deltaCen = floor( ( lobst - 1 ) / 2 );
obst.center(:,1) = mod( obst.corner(:,1) + deltaCen - 1, ng ) + 1;
obst.center(:,2) = mod( obst.corner(:,2) + deltaCen - 1, ng ) + 1;
obst.centerInds = sub2ind( [ng ng], obst.center(:,1), obst.center(:,2) );
% all ptns
obst.allpts = allSitesFilled;
obst.numFilledSite = numSitesFilled;
end
