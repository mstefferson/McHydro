classdef FluxCounterClass < handle
  properties
    Flag = 0;
    Counts = 0;
    CountsPrev = 0;
    IndsCheck = 0;
    IndWantI = 0;
    IndWantF = 0;
    TotalThrough = 0;
    ParticlesThrough = 0;
  end % properties
  
  methods
    % constructor
    function obj = FluxCounterClass( fluxCell, grid )
      dim = grid.dim;
      % set inputs
      obj.Counts = 0;
      if fluxCell{2} == 3 && dim == 2
        fprintf('Cannot measure flux in third dim since system dim = 2\n')
        obj.Flag = 0;
      end
      if fluxCell{1} == 1
        obj.Flag = 1;
        obj.IndsCheck = fluxCell{2};
        obj.IndWantI = mod( fluxCell{3} - 1, grid.sizeV(obj.IndsCheck) ) + 1;
        obj.IndWantF = mod( fluxCell{3} + 1 - 1, grid.sizeV(obj.IndsCheck) ) + 1;
      end
    end
    
    % methods
    function [obj] = updateFlux( obj, posNew, posOld )
      fluxThrough  = obj.findIndsThrough( posNew, posOld );
      obj = obj.findPartilesThrough( fluxThrough );
      obj = obj.calcTotalThrough();
      obj.CountsPrev = obj.Counts;
      obj.Counts = obj.CountsPrev + obj.TotalThrough;
    end % add2Countser
    
    % find flux through
    function [fluxThrough] = findIndsThrough( obj, posNew, posOld )
      fluxThrough = ( (posNew( :, obj.IndsCheck ) == obj.IndWantF) + ...
        (posOld( :, obj.IndsCheck ) == obj.IndWantI) )  == 2;
    end
    
    % calculate total that went through
    function [obj] = calcTotalThrough( obj )
      obj.TotalThrough = length( obj.ParticlesThrough );
    end
    
    % get indices for particles that went through
    function [obj] = findPartilesThrough( obj, fluxThrough )
      obj.ParticlesThrough = find( fluxThrough );
      if isempty( obj.ParticlesThrough )
        obj.ParticlesThrough = [];
      end
    end
    
  end % methods
end % class
