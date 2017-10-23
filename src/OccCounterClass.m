% Track occupancy
classdef OccCounterClass < handle
  properties
    Flag = 0;
    AnimateFlag = 0;
    RecInterval = 0;
    Num = 0;
    SiteSub = 0;
    SiteInd = 0;
    NumTimeRec = 0;
    OccTot = 0;
    Length = 1;
    Color = [0 0 0];
    Curvature = 0.5;
    Rectangle = 0;
    Ngrid = 0;
  end % properties
  
  methods
    % constructor
    function obj = OccCounterClass( occCell, nt, grid )
      % set inputs
      obj.Flag = occCell{1};
      obj.AnimateFlag = occCell{2};
      obj.Ngrid = grid.sizeV(1);
      if obj.Flag
        obj.RecInterval = occCell{3};
        obj.Num = length( occCell{4} );
        obj.SiteSub = reshape( cell2mat( occCell{4} ), [  2 obj.Num ]  )';
        obj.SiteSub(:,1) = mod( round( obj.SiteSub(:,1) ) -1, grid.sizeV(1) ) + 1;
        obj.SiteSub(:,2) = mod( round( obj.SiteSub(:,2) ) -1, grid.sizeV(2) ) + 1;
        obj.SiteInd = sub2ind( grid.sizeV, obj.SiteSub(:,1), obj.SiteSub(:,2) );
        obj.NumTimeRec = floor( nt / obj.RecInterval ) + 1;
        obj.OccTot = zeros( 1, obj.Num );
        obj.Rectangle = struct;
      end
    end
    
    % methods
    function [obj] = updateOcc( obj, m, tracerSites)
      if mod( m, obj.RecInterval ) == 0
        for ii = 1:obj.Num
          occTemp = length( find( tracerSites ==  obj.SiteInd(ii) ) );
          obj.OccTot( ii ) = obj.OccTot( ii ) + occTemp;
        end
      end
    end % updateOcc
    
    % methods
    function [obj] = animate( obj )
      if obj.AnimateFlag
        for ksite=1:obj.Num
          obj.Rectangle = update_rectangle(obj.SiteSub, obj.Rectangle, ...
            ksite, obj.Length, obj.Ngrid,...
            obj.Color,obj.Curvature);
        end
      end
    end % animate
  end % methods
end % class
