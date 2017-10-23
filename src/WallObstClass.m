classdef WallObstClass
  properties
    Type = 'wall';
    SiteDiff = 0;
    Be = 0;
    Ff = 0;  
    Thickness = 0;
    GapWidth = 0;
    Dim = 0;
    PlaceLocation = 0;
    GapLocation = 0;
    Length = 1;    
    TracerOccNum = 0;
    TracerOccFrac = 0;
    AllPts = 0;
    Corners = 0;
    Centers = 0;
    Num = 0;
    EdgePlaceFlag = 0;
    Color = [0 0 0];
    Curvature = 0.2;
  end % properties
  
  methods
    % constructor
    function obj =  WallObstClass( bndDiff, be, thickness, gapWidth, ...
        dim, placeLocation, gapLocation, color, gridObj )
      % set inputs
      obj.SiteDiff = bndDiff;
      obj.Be = be;
      obj.Thickness = thickness;
      obj.GapWidth = gapWidth;
      obj.Dim = dim;
      obj.PlaceLocation = placeLocation;
      obj.GapLocation = round( gapLocation );
      obj.Color = color;
      % now place
      obj = obj.placeObst( gridObj );
      % set centers. (usefule for animate)
      obj.Centers = obj.Corners;
    end
    
    % methods
    function [obj] = placeObst( obj, gridObj )
      dim = obj.Dim;
      if dim == 3
        fprintf('Wall obst not written for 3d\n');
        error('Wall obst not written for 3d\n');
      end
      % gap start and end points
      startPnt = mod( obj.GapLocation - 1 - 1, gridObj.sizeV(2) ) + 1;
      endPnt = mod( startPnt + obj.GapWidth, gridObj.sizeV(2) ) + 1;
      if dim == 1
        cols2fill = [1:startPnt endPnt:gridObj.sizeV(2)];
        rows2fill = obj.PlaceLocation-obj.Thickness+1:obj.PlaceLocation;
      else % dim = 2
        cols2fill = obj.PlaceLocation-obj.Thickness+1:obj.PlaceLocation;
        rows2fill =  [1:startPnt endPnt:gridObj.sizeV(1)];
      end
      % fix wrap issue
      cols2fill = mod( cols2fill - 1, gridObj.sizeV(2) ) + 1;
      rows2fill = mod( rows2fill - 1, gridObj.sizeV(1) ) + 1;
      tempInds = combvec( rows2fill, cols2fill );
      obj.Corners = [ tempInds(1,:)', tempInds(2,:)' ];
      obj.AllPts = sub2ind( gridObj.sizeV, obj.Corners(:,1), obj.Corners(:,2) );
      obj.Num = length( obj.AllPts );
      obj.Ff = obj.Num / gridObj.totPnts;
    end % place_obst
  end % methods
end % class
