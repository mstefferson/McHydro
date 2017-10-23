% obstacle at a specified location. For now, only place one. This obstacle
% will wrap around previously set obstacles
%
classdef SpeclocObstClass
  properties
    Type = 'specloc';
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
    function obj =  SpeclocObstClass( bndDiff, be,  so, locationSub, ...
        color, gridObj, forbiddenSites )
      % set inputs
      obj.SiteDiff = bndDiff;
      obj.Be = be;
      obj.Length = so;
      obj.Color = color;
      % now place
      obj = obj.placeObst( gridObj,  locationSub, forbiddenSites );
      % set centers (useful for animate)
      deltaCen = floor( ( obj.Length - 1 ) / 2 );
      obj.Centers = zeros( obj.Num, 2 );
      obj.Centers(:,1) = mod( obj.Corners(:,1) + deltaCen - 1, gridObj.sizeV(1) ) + 1;
      obj.Centers(:,2) = mod( obj.Corners(:,2) + deltaCen - 1, gridObj.sizeV(2) ) + 1;
    end
    
    % methods
    function [obj] = placeObst( obj, gridObj, locationSub, forbiddenSites )
      % get size
      [locDim] = size(locationSub,2);
      [num] = size( locationSub,1 );
      % make sure sub are intergers
      locationSub = round( locationSub );
      % assign third dim if missing
      if locDim == 2
        locationSub = [ locationSub; ones(num, 1) ];
      end
      % set-up grid
      gridSize = ones(1,3);
      gridSize(1:gridObj.dim) = gridObj.sizeV;
      % make sure it's on the grid
      locationSub(:,1) = mod( locationSub(:,1) - 1, gridSize(1) ) + 1;
      locationSub(:,2) = mod( locationSub(:,2) - 1, gridSize(2) ) + 1;
      locationSub(:,3) = mod( locationSub(:,3) - 1, gridSize(3) ) + 1;
      % turn subs to inds
      locations = sub2ind( gridObj.sizeV, ...
        locationSub(:,1), locationSub(:,2), locationSub(:,3) );
      % get delta ind
      deltaL1 = round( obj.Length-1 );
      deltaL2 = round( (obj.Length-1) .* min( floor( gridObj.dim/2 ), 1 ) );
      deltaL3 = round( (obj.Length-1) .* min( floor( gridObj.dim/3 ), 1 ) );
      actualAdded = 0;
      newCorners = [];
      numSitesFilled = 0;
      allSpecLocSitesFilled = [];
      allObstFilled = forbiddenSites;
      for ii = 1:num
        newCornerInd = locations(ii);
        [i,j,k] = ind2sub( gridSize, newCornerInd);
        newiFill = mod( (i:i+deltaL1) - 1, gridSize(1) ) + 1;
        newjFill = mod( (j:j+deltaL2) - 1, gridSize(2) ) + 1;
        newkFill = mod( (k:k+deltaL3) - 1, gridSize(3) ) + 1;
        newComb = combvec(newiFill, newjFill, newkFill);
        newInds = sub2ind( gridSize, newComb(1,:)', newComb(2,:)', newComb(3,:)' );
        % only acceptt unique obstacles
        actualNewSites = setdiff( newInds, allObstFilled );
        numActualNew = length( actualNewSites );
        % fill em!
        allSitesFilledTemp = [allSpecLocSitesFilled; actualNewSites ];
        allSpecLocSitesFilled = allSitesFilledTemp;
        allObstFilled = [allObstFilled; actualNewSites];
        % update what's not longer available
        allSpecLocSitesFilled = unique( allSpecLocSitesFilled );
        numSitesFilled = length( allSpecLocSitesFilled );
        actualAdded = actualAdded + numActualNew;
      end
      % set all points
      obj.Num = actualAdded;
      obj.Ff = numSitesFilled / gridObj.totPnts;
      obj.AllPts = allSpecLocSitesFilled;
      obj.NumFilledSites = numSitesFilled;
      % corners
      obj.Corners = zeros( numSitesFilled, 3 );
      obj.CornerInds = obj.AllPts;
      [obj.Corners(:,1), obj.Corners(:,2), obj.Corners(:,3)] = ...
        ind2sub( gridSize, obj.CornerInds );
      obj.Corners = obj.Corners(:, 1:gridObj.dim );
      % reset length to 1
      obj.Length = 1;
    end % place_obst
  end % methods
end % class
