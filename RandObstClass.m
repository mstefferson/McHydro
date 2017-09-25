classdef RandObstClass
  properties
    Type = 'rand';
    SiteDiff = 0;
    Be = 0;
    Ff = 0;
    FfWant = 0;
    Length = 0;
    EdgePlaceFlag = 0;
    ObstExcludeFlag = 0;
    Color = [0 0 0];
    Curvature = 0.2;
    TracerOccNum = 0;
    TracerOccFrac = 0;
    AllPts = 0;
    NumFilledSites = 0;
    Num = 0;
    Corners = 0;
    CornerInds = 0;
    EdgeInds = 0;
    NumEdges = 0;
  end % properties

  methods
    % constructor
    function obj =  RandObstClass( bndDiff, be, ff, so, excludeFlag, edgePlace,...
       color, gridSize, forbiddenSites )
      % set inputs
      obj.SiteDiff = bndDiff;
      obj.Be = be;
      obj.FfWant = ff;
      obj.Length = so;
      obj.EdgePlaceFlag = edgePlace;
      obj.ObstExcludeFlag = excludeFlag;
      obj.Color = color;
      % now place
      obj = obj.placeObst( gridSize, forbiddenSites );
    end

    % methods
    function [obj] = placeObst( obj, gridSize, forbiddenSites )
    % set commonly used parameters
    lobst = obj.Length;
    excludeVol = obj.ObstExcludeFlag;
    ff = obj.FfWant;
    % get dimension and add ones for unused higher dimensions
    dim = length(gridSize);
    gridTemp = ones(1,3);
    gridTemp(1:dim) = gridSize;
    gridSize = gridTemp;
    % number of sites to fill
    numSites = prod( gridSize );
    allSitesOpen = setdiff( 1:prod( gridSize ), forbiddenSites );
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
    minFilledSites = lobst^dim;
    availCorners = allSitesOpen;
    numCornersAvail = length( availCorners );
    % number of filled
    allSitesFilled = forbiddenSites;
    if excludeVol
      diInner = 1;
      djInner = min( floor( dim/2 ), 1 );
      dkInner = min( floor( dim/3 ), 1  );
      deltaL1Inner = max( deltaL1 - 2, 0 );
      deltaL2Inner = max( deltaL2 - 2, 0 );
      deltaL3Inner = max( deltaL3 - 2, 0 );
      obstEdges = [];
    end
    % do Initial fill
    if ~excludeVol || lobst == 1
      numCornersInit = maxFilledCorners;
    else
      numCornersInit = 1;
    end
    obstCornersInds = randperm( numCornersAvail, numCornersInit );
    obstCorners = availCorners( obstCornersInds )';
    % Find coordinates
    if lobst > 1 && excludeVol
      for nn = 1:numCornersInit
        % get corner id
        [i, j, k] = ind2sub( gridSize, obstCorners(nn) );
        % fill in all Sites
        newiFill = mod( (i:i+deltaL1) - 1, gridSize(1) ) + 1;
        newjFill = mod( (j:j+deltaL2) - 1, gridSize(2) ) + 1;
        newkFill = mod( (k:k+deltaL3) - 1, gridSize(3) ) + 1;
        newComb = combvec( newiFill, newjFill, newkFill );
        newInds = sub2ind( gridSize, newComb(1,:)', newComb(2,:)', newComb(3,:)' );
        % Find actual new
        actualNewSites = setdiff( newInds, allSitesFilled );
        allSitesFilledTemp = [allSitesFilled; actualNewSites];
        allSitesFilled = allSitesFilledTemp;
        % Find edges by removing inner square
        iInner = i + diInner;
        jInner = j + djInner;
        kInner = k + dkInner;
        newiInner = mod( (iInner:iInner+deltaL1Inner) - 1, gridSize(1) ) + 1;
        newjInner = mod( (jInner:jInner+deltaL2Inner) - 1, gridSize(1) ) + 1;
        newkInner = mod( (kInner:kInner+deltaL3Inner) - 1, gridSize(1) ) + 1;
        newComb = combvec( newiInner, newjInner, newkInner );
        newIndsInner = sub2ind( gridSize, newComb(1,:)', newComb(2,:)', newComb(3,:)' );
        newEdges = setdiff( newInds, newIndsInner );
        obstEdges = [obstEdges; newEdges];
        % excluded volume
        newiNoCorner = mod( (i-deltaL1:i+deltaL1) - 1, gridSize(1) ) + 1;
        newjNoCorner = mod( (j-deltaL2:j+deltaL2) - 1, gridSize(2) ) + 1;
        newkNoCorner = mod( (k-deltaL3:k+deltaL3) - 1, gridSize(2) ) + 1;
        newComb = combvec( newiNoCorner, newjNoCorner, newkNoCorner  );
        newInds = sub2ind( gridSize, newComb(1,:)', newComb(2,:)', newComb(3,:)'  );
        availCorners = setdiff( availCorners, newInds  );
        numCornersAvail = length(availCorners);
        %     end
      end
    else
      availCorners = setdiff( availCorners, obstCorners  );
      numCornersAvail = length( availCorners );
      allSitesFilled = obstCorners;
    end
    % save unique
    allSitesFilled = unique( allSitesFilled );
    numSitesFilled = length( allSitesFilled );
    % Now fill in remaining
    % Fill until you cannot
    numTrys = 0;
    if maxFilledSites > minFilledSites
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
          if ~excludeVol || lobst == 1
            availCorners = setdiff( availCorners, newCorner );
            numCornersAvail =  max( numCornersAvail - 1, 0 );
          else
          % Find edges by removing inner square
            iInner = i + diInner;
            jInner = j + djInner;
            kInner = k + dkInner;
            newiInner = mod( (iInner:iInner+deltaL1Inner) - 1, gridSize(1) ) + 1;
            newjInner = mod( (jInner:jInner+deltaL2Inner) - 1, gridSize(1) ) + 1;
            newkInner = mod( (kInner:kInner+deltaL3Inner) - 1, gridSize(1) ) + 1;
            newComb = combvec( newiInner, newjInner, newkInner );
            newIndsInner = sub2ind( gridSize, newComb(1,:)', newComb(2,:)', newComb(3,:)' );
            newEdges = setdiff( newInds, newIndsInner );
            obstEdges = [obstEdges; newEdges];
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
    else
      obstCorners = [];
      numSitesFilled = 0;
      numTrys = 0;
    end
    % save it in obst
    % allocate
    num = length( obstCorners );
    obj.Num = num;
    obj.Ff = numSitesFilled ./ numSites;
    obj.Corners = zeros( num, 3 );
    % corners
    obj.CornerInds = obstCorners;
    [obj.Corners(:,1), obj.Corners(:,2), obj.Corners(:,3)] = ...
      ind2sub( gridSize, obstCorners );
    % get rid of unused dims
    obj.Corners = obj.Corners(:,1:dim);
    % edges
    if obj.EdgePlaceFlag
      obj.EdgeInds = unique( obstEdges );
      obj.NumEdges = length( obj.EdgeInds );
    end
    % set all points
    obj.AllPts = allSitesFilled;
    obj.NumFilledSites = numSitesFilled;
  end % place_obst
  end % methods
end % class
