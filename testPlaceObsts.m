%%
ff = 0.3;
nG = 10;
numSites = nG^2;
lobst = 3;
deltaL = lobst-1;

overlapCool = 1;

% number of sites to fill
maxFilledSites = round( ff * numSites );
maxFilledCenters = round( ff * numSites / (lobst^2) );

% all Sites
allSitesOpen = 1:numSites;
availCenters = allSitesOpen;
numCentersAvail = length( availCenters );
% number of filled
allSitesFilled = [];
numFilledSites = 0;
% do Initial fill
if overlapCool
  numCentersInit = maxFilledCenters;
else
  numCentersInit = 1;
end
obstCentersInds = randperm( numCentersAvail, numCentersInit );
obstCenters = availCenters( obstCentersInds )';

% Find coordinates
for nn = 1:numCentersInit
  [i, j] = ind2sub( [nG nG], obstCenters(nn) );
  newiFill = mod( (i:i+deltaL) - 1, nG ) + 1;
  newjFill = mod( (j:j+deltaL) - 1, nG ) + 1;
  newComb = combvec( newiFill, newjFill );
  newInds = sub2ind( [nG nG], newComb(1,:)', newComb(2,:)' );
  % Find actual new
  actualNewSites = setdiff( newInds, allSitesFilled );
  allSitesFilledTemp = [allSitesFilled; actualNewSites];
  allSitesFilled = allSitesFilledTemp;
  if overlapCool
    availCenters = setdiff( availCenters, obstCenters(nn)  );
    numCentersAvail = numCentersAvail - 1;
  else
    newiNoCenter = mod( (i-deltaL:i+deltaL) - 1, nG ) + 1;
    newjNoCenter = mod( (j-deltaL:j+deltaL) - 1, nG ) + 1;
    newComb = combvec( newiNoCenter, newjNoCenter );
    newInds = sub2ind( [nG nG], newComb(1,:)', newComb(2,:)' );
    availCenters = setdiff( availCenters, newInds  );
    notAvailCenters = setdiff( allSitesOpen, availCenters );
    [in, jn] = ind2sub( [nG nG],  notAvailCenters  );

    numCentersAvail =  numCentersAvail - length(newInds);
  end
  numAvailCenters = length(availCenters);
  notAvailCenters = setdiff( obstCenters, availCenters );
  numNotAvailCenters = numSites - numAvailCenters;
end
% 
allSitesFilled = unique( allSitesFilled );
numSitesFilled = length( allSitesFilled );
allSitesOpen = setdiff( allSitesOpen, allSitesFilled );
numSitesOpen = length( allSitesOpen );
% Now fill in remaining
% save it
allSitesFilled = unique( allSitesFilled );
numAllSites = length( allSitesFilled );
obstCenters = unique( obstCenters );
fprintf( 'ff = %f \n', numAllSites ./ nG^2 );

filledSites = zeros(nG, nG);
filledSites( allSitesFilled ) = 1;
filledSites( obstCenters ) = 2;

imagesc( filledSites );
colorbar
axis square
[in' jn'];
%%
% Fill until you cannot
numTrys = 0;
maxTrys = numAvailCenters;
while numSitesFilled ~= maxFilledSites || numTrys  > maxTrys
  %%
  newCenterInds = randperm( numCentersAvail, 1 );
  newCenter = availCenters( newCenterInds );
  [i, j] = ind2sub( [nG nG], newCenter );
  newiFill = mod( (i:i+deltaL) - 1, nG ) + 1;
  newjFill = mod( (j:j+deltaL) - 1, nG ) + 1;
  newComb = combvec(newiFill, newjFill);
  newInds = sub2ind( [nG nG], newComb(1,:)', newComb(2,:)' );
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
    obstCenters = unique( [obstCenters; newCenter] );
    if overlapCool
      availCenters = setdiff( availCenters, newCenter );
      numCentersAvail =  numCentersAvail - 1;
    else
      newiNoCenter = mod( (i-deltaL:i+deltaL) - 1, nG ) + 1;
      newjNoCenter = mod( (j-deltaL:j+deltaL) - 1, nG ) + 1;
      newComb = combvec( newiNoCenter, newjNoCenter );
      newInds = sub2ind( [nG nG], newComb(1,:)', newComb(2,:)' );
      availCenters = setdiff( availCenters, newInds  );
      numCentersAvail =  numCentersAvail - length(newInds);
    end
  else
    availCenters = setdiff( availCenters, newCenter );
    numCentersAvail =  numCentersAvail - 1;
    numTrys = numTrys + 1;
  end
  % update what's not longer available
  obstCenters ;
  numCentersAvail;
  notAvailCentersTemp = [notAvailCenters;  newCenter];
  notAvailCenters = notAvailCentersTemp;
  allSitesFilled = unique( allSitesFilled );
  numAllSites = length( allSitesFilled );
  obstCenters = unique( obstCenters );
  fprintf( 'ff = %f \n', numAllSites ./ nG^2 );
  allSitesFilled = unique( allSitesFilled );
  % plotting
  numAllSites = length( allSitesFilled );
  obstCenters = unique( obstCenters );
  fprintf( 'ff = %f \n', numAllSites ./ nG^2 );
  filledSites( allSitesFilled ) = 1;
  filledSites( obstCenters ) = 2;
  imagesc( filledSites );
  axis square
  if numCentersAvail == 0
    break
  end
end
allSitesFilled = unique( allSitesFilled );
numAllSites = length( allSitesFilled );
obstCenters = unique( obstCenters );
fprintf( 'ff = %f \n', numAllSites ./ nG^2 );
filledSites( allSitesFilled ) = 1;
filledSites( obstCenters ) = 2;
imagesc( filledSites );
axis square

% save it
% allSites = unique( allSitesFilledNew );
% numAllSites = length( allSites );
% allCenter = unique( obstCentersNew );
% fprintf( 'ff = %f \n', numAllSites ./ nG^2 );
%
% filledSite = zeros(nG, nG);
% filledSites( allSites ) = 1;
% filledSites( allCenter ) = 2;




