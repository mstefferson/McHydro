classdef SpeclocObstClass
  properties
    Type = 'placed';
    SiteDiff = 0;
    Be = 0;
    Ff = 0;
    Length = 0;
    TracerOccNum = 0;
    TracerOccFrac = 0;
    AllPts = 0;
    NumFilledSites = 0;
    Num = 0;
    Corners = 0;
    CornerInds = 0;
    Centers = 0;
    EdgePlaceFlag = 0;
    ObstExcludeFlag = 0;
    Color = [0 0 0];
    Curvature = 0.2;
  end % properties
  
  methods
    % constructor
    function obj =  SpeclocObstClass( bndDiff, be, location, so, ...
        color, gridObj, forbiddenSites )
      % set inputs
      obj.SiteDiff = bndDiff;
      obj.Be = be;
      obj.Length = so;
      obj.Color = color;
      % now place
      obj = obj.placeObst( gridObj,  location, forbiddenSites );
      % set centers (useful for animate)
      deltaCen = floor( ( obj.Length - 1 ) / 2 );
      obj.Centers = zeros( obj.Num, 2 );
      obj.Centers(:,1) = mod( obj.Corners(:,1) + deltaCen - 1, gridObj.sizeV(1) ) + 1;
      obj.Centers(:,2) = mod( obj.Corners(:,2) + deltaCen - 1, gridObj.sizeV(2) ) + 1;
    end
    
    % methods
    function [obj] = placeObst( obj, gridObj, locations, forbiddenSites )
      num = 1;
      % get delta ind
      deltaL1 = round( obj.Length-1 );
      deltaL2 = round( (obj.Length-1) .* min( floor( gridObj.dim/2 ), 1 ) );
      deltaL3 = round( (obj.Length-1) .* min( floor( gridObj.dim/3 ), 1 ) );
      % set-up grid
      gridTemp = ones(1,3);
      gridTemp(1:gridObj.dim) = gridObj.sizeV;
      gridSize = gridTemp;
      if gridObj.dim == 2
        locations = [ locations; ones( obj.Num, 1 ) ];
      end
      actualAdded = 0;
      newCorners = [];
      numSitesFilled = 0;
      allSitesFilled = [];
      for ii = 1:num
        newCornerInd = locations(ii);
        [i,j,k] = ind2sub( gridSize, newCornerInd);
        if ~ismember( newCornerInd, forbiddenSites )
          newCorners = [newCorners newCornerInd];
          newiFill = mod( (i:i+deltaL1) - 1, gridSize(1) ) + 1;
          newjFill = mod( (j:j+deltaL2) - 1, gridSize(2) ) + 1;
          newkFill = mod( (k:k+deltaL3) - 1, gridSize(3) ) + 1;
          newComb = combvec(newiFill, newjFill, newkFill);
          newInds = sub2ind( gridSize, newComb(1,:)', newComb(2,:)', newComb(3,:)' );
          % only except unique obstacles
          actualNewSites = setdiff( newInds, allSitesFilled );
          numActualNew = length( actualNewSites );
          % See if we can accept
          numSiteFilledTemp = numSitesFilled + numActualNew;
          % fill em!
          allSitesFilledTemp = [allSitesFilled; actualNewSites ];
          allSitesFilled = allSitesFilledTemp;
          forbiddenSites = [forbiddenSites; actualNewSites];
          % update what's not longer available
          allSitesFilled = unique( allSitesFilled );
          numSitesFilled = length( allSitesFilled );
          actualAdded = actualAdded + 1;
        end
      end
      % set all points
      obj.Num = actualAdded;
      obj.Ff = numSitesFilled / gridObj.totPnts;
      obj.AllPts = allSitesFilled;
      obj.NumFilledSites = numSitesFilled;
      % corners
      obj.Corners = zeros( num, 3 );
      obj.CornerInds = newCorners;
      [obj.Corners(:,1), obj.Corners(:,2), obj.Corners(:,3)] = ...
        ind2sub( gridSize, obj.CornerInds );
    end % place_obst
  end % methods
end % class
