classdef WallObstClass
  properties
    Type = 'wall';
    SiteDiff = 0;
    Be = 0;
    Ff = 0;
    Thickness = 0;
    GapWidth = 0;
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
        color, grid, placeLocation )
      % set inputs
      obj.SiteDiff = bndDiff;
      obj.Be = be;
      obj.Thickness = thickness;
      obj.GapWidth = gapWidth;
      obj.Color = color;
      % now place
      obj = obj.placeObst( grid, placeLocation );
      % set centers. (usefule for animate)
      obj.Centers = obj.Corners;
    end
    
    % methods
    function [obj] = placeObst( obj, grid, placeLocation )
      center = floor( ( grid.sizeV(2) + 1 ) / 2 );
      top = center - floor( ( obj.GapWidth - 1 ) / 2 );
      cols2fill = placeLocation-obj.Thickness+1:placeLocation;
      rows2fill =  [1:top-1  top+obj.GapWidth:grid.sizeV(1)];
      tempInds = combvec( rows2fill, cols2fill );
      obj.Corners = [ tempInds(1,:)', tempInds(2,:)' ];
      obj.AllPts = sub2ind( grid.sizeV, obj.Corners(:,1), obj.Corners(:,2) );
      obj.NumFilledSites = length( obj.AllPts );
      obj.Num = obj.NumFilledSites;
      obj.Ff = obj.NumFilledSites / grid.totPnts;
    end % place_obst
  end % methods
end % class
