classdef TeleportObstClass < handle
  properties
    Type = 'teleport';
    Be = Inf;
    Ff = 0;
    Length = 1;
    SiteDiff = 0;
    Dim = 0;
    Location = 0;
    SinkLocation = 0;
    SourceLocation = 0;
    AllPts = 0;
    Centers = 0;
    Corners = 0;
    SinkInds = 0;
    NumFilledSites = 0;
    Num = 0;
    Color = [0 0 0];
    Curvature = 0.2;
    EdgePlaceFlag = 0;
    TrackTeleNumFlag = 0;
    Counts = 0;
    CountsPrev = 0;
  end % properties
  
  methods
    % constructor
    function obj = TeleportObstClass( dim, location, trackFlag, gridObj )
      % set inputs
      obj.Dim = dim;
      obj.Location = mod( location-1, gridObj.sizeV(dim) ) + 1;
      obj.TrackTeleNumFlag = trackFlag;
      % now place
      obj = obj.placeObst( gridObj );
      obj.Centers = obj.Corners;
    end
    
    % methods
    function [obj] = placeObst( obj, gridObj )
      dim = obj.Dim;
      if dim == 3
        fprintf('Wall obst not written for 3d\n');
        error('Wall obst not written for 3d\n');
      end
      fillDim = mod( dim + 1 - 1, 2 ) + 1;
      if dim == 1
        cols2fill = [1:gridObj.sizeV(fillDim)];
        rows2fill = obj.Location;
      else % dim = 2
        cols2fill = obj.Location;
        rows2fill =  [1:gridObj.sizeV(fillDim)];
      end
      % fix wrap issue
      obj.Location = mod( obj.Location - 1, gridObj.sizeV(obj.Dim) ) + 1;
      % place hard call
      tempInds = combvec( rows2fill, cols2fill );
      obj.Corners = [ tempInds(1,:)', tempInds(2,:)' ];
      obj.AllPts = sub2ind( gridObj.sizeV, obj.Corners(:,1), obj.Corners(:,2) );
      numFilledSites = length( obj.AllPts );
      obj.Num = numFilledSites;
      obj.Ff = numFilledSites / gridObj.totPnts;
      % set up sink/source
      obj.SinkLocation = mod( obj.Location-2, gridObj.sizeV( obj.Dim) ) + 1;
      obj.SourceLocation = mod( obj.Location, gridObj.sizeV( obj.Dim) ) + 1;
      % get all sink ptns so no other obstacle goes there
      if dim == 1
        rows2fill = obj.SinkLocation;
      else % dim = 2
        cols2fill = obj.SinkLocation;
      end
      tempInds = combvec( rows2fill, cols2fill );
      obj.SinkInds = sub2ind( gridObj.sizeV, tempInds(1,:)', tempInds(2,:)' );
    end % place_obst

    function [centers,moveInds] = teleport( obj, centers )
      moveVec  = centers(:,obj.Dim)  ==  obj.SinkLocation;
      moveInds = find(moveVec);
      centers( moveVec, obj.Dim ) = obj.SourceLocation;
      if obj.TrackTeleNumFlag
        numMoved = sum( moveVec );
        obj.CountsPrev = obj.Counts;
        obj.Counts = obj.Counts + numMoved;
      end
    end

  end % methods
end % class
