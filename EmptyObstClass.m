classdef EmptyObstClass
  properties
    Type = 'empty';
    SiteDiff = 1;
    Be = 0;
    Color = [1 1 1];
    Curvature = 0.2;
    TracerOccNum = 0;
    TracerOccFrac = 0;
    AllPts = 0;
    NumFilledSites = 0;
  end % properties
  
  methods
    % constructor
    function obj =  EmptyObstClass( freeDiff, filledSites, numSites )
      % set inputs
      obj.SiteDiff = freeDiff;
      % now place
      obj.AllPts = setdiff( 1:numSites, filledSites );
      obj.NumFilledSites = length( obj.AllPts );
    end
  end % methods
end % class
