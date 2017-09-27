classdef WallObstClass
  properties
    Type = 'wall';
    SiteDiff = 0;
    Be = 0;
    Ff = 0;  
    Thickness = 0;
    GapWidth = 0;
    Dim = 0;
    Location = 0;
    Length = 1;
    Color = [0 0 0];
    Curvature = 0.2;
    EdgePlaceFlag = 0;
    TracerOccNum = 0;
    TracerOccFrac = 0;
    AllPts = 0;
    Corners = 0;
    Centers = 0;
    NumFilledSites = 0;
    Num = 0;
  end % properties
  
  methods
    % constructor
    function obj =  WallObstClass( bndDiff, be, thickness, gapWidth, ...
        dim, placeLocation, color, grid )
      % set inputs
      obj.SiteDiff = bndDiff;
      obj.Be = be;
      obj.Thickness = thickness;
      obj.GapWidth = gapWidth;
      obj.Dim = dim;
      obj.Location = placeLocation;
      obj.Color = color;
      % now place
      obj = obj.placeObst( grid, dim, placeLocation );
      % set centers. (usefule for animate)
      obj.Centers = obj.Corners;
    end
    
    % methods
    function [obj] = placeObst( obj, grid, dim, placeLocation )
      if dim == 3
        fprintf('Wall obst not written for 3d\n');
        error('Wall obst not written for 3d\n');
      end
      posDim = dim;
      fillDim = mod( dim + 1 - 1, 2 ) + 1;
      midpoint = floor( ( grid.sizeV(posDim) + 1 ) / 2 );
      endPnt = midpoint - floor( ( obj.GapWidth - 1 ) / 2 );
      if dim == 1
        cols2fill = [1:endPnt-1  endPnt+obj.GapWidth:grid.sizeV(fillDim)];
        rows2fill = placeLocation-obj.Thickness+1:placeLocation;
      else % dim = 2
        cols2fill = placeLocation-obj.Thickness+1:placeLocation;
        rows2fill =  [1:endPnt-1  endPnt+obj.GapWidth:grid.sizeV(fillDim)];
      end
      % fix wrap issue
      cols2fill = mod( cols2fill - 1, grid.sizeV(2) ) + 1;
      rows2fill = mod( rows2fill - 1, grid.sizeV(1) ) + 1;
      tempInds = combvec( rows2fill, cols2fill );
      obj.Corners = [ tempInds(1,:)', tempInds(2,:)' ];
      obj.AllPts = sub2ind( grid.sizeV, obj.Corners(:,1), obj.Corners(:,2) );
      obj.NumFilledSites = length( obj.AllPts );
      obj.Num = obj.NumFilledSites;
      obj.Ff = obj.NumFilledSites / grid.totPnts;
    end % place_obst
  end % methods
end % class
