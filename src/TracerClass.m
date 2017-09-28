classdef TracerClass
  properties
    type = 'tracer';
    Color = [0 1 1]; % cyan
    Length = 1;
    Curvature = 1;
    OccNum = 0;
    OccFrac = 0;
    AllPts = 0;
    State = 0;
    Num = 0;
    PosNoMod = 0;
    Centers = 0;
  end % properties
  
  methods
    % constructor
    function obj =  TracerClass( nTracer, obst, be, grid, allowObstPlacement )
      % set inputs
      obj.Num = nTracer;
      % now place
      totSites = grid.totPnts;
      dim = grid.dim;
      obj = obj.place( obst, be, totSites, allowObstPlacement );
      % initialize some vectors to be used later
      centerNoMod = zeros( nTracer, 3 );
      [centerNoMod(:,1), centerNoMod(:,2),centerNoMod(:,3) ] = ...
        ind2sub( grid.sizeV, obj.AllPts );
      obj.PosNoMod = centerNoMod(:,1:dim);
      obj.Centers = obj.PosNoMod;
    end
    
    % methods
    function [obj] = place( obj, obst, be, totSites, allowObstPlacement )
      nTracer = obj.Num;
      numObstTypes = length( obst ) - 1;
      % store occupanyc
      tracersOccNum = zeros( 1, numObstTypes+1 );
      tracersOccFrac= zeros( 1, numObstTypes+1 );
      if allowObstPlacement
        ffoPlace = zeros( 1, numObstTypes );
        % change ff is only placing on edges and get total filled sites
        % scramble the order. No favorites!!!
        for ii = randperm( numObstTypes )
          if obst{ii}.EdgePlaceFlag
            ffTemp = obst{ii}.NumEdges ./ ...
              ( totSites - obst{ii}.NumFilledSites + obst{ii}.NumEdges );
            ffoPlace(ii) = ffTemp;
          else
            ffoPlace(ii) = obst{ii}.Ff;
          end
        end
        emptySites = obst{numObstTypes+1}.AllPts;
        ind = 1:numObstTypes;
        numTracerEmpty = (1-sum(ffoPlace) );
        boltzFac = [ ffoPlace(ind) .* exp( -be(ind) ) numTracerEmpty];
        normFac = sum( boltzFac );
        tracersOccNum(ind) = round( nTracer * boltzFac(ind) / normFac );
        tracersOccFrac(ind) = boltzFac(ind)  / normFac;
        % allocate
        obj.AllPts = zeros( nTracer, 1 );
        obj.State = (numObstTypes + 1) * ones( nTracer, 1 );
        holder = 1;
        totalPlaced = 0;
        for ii = 1:numObstTypes
          if tracersOccNum(ii) > 0
            tracerInd = holder:holder+tracersOccNum(ii)-1;
            if obst{ii}.EdgePlaceFlag
              availObstSites = obst{ii}.EdgeInds;
            else
              availObstSites = obst{ii}.AllPts;
            end
            % place them
            obj.AllPts( tracerInd ) = availObstSites( ...
              randi( length(availObstSites), [1 tracersOccNum(ii)] ) );
            obj.State( tracerInd ) = ii;
            holder = holder+tracersOccNum(ii);
            totalPlaced = totalPlaced + tracersOccNum(ii);
          end
        end
        % place the rest on empty
        numTrEmpty = nTracer - totalPlaced;
        if numTrEmpty > 0
          obj.AllPts( totalPlaced+1:nTracer ) = emptySites( randi( length(emptySites), [1 numTrEmpty] ) );
        end
        obj.State( totalPlaced+1:nTracer ) = numObstTypes+1;
        tracersOccNum(numObstTypes+1) = nTracer-sum( tracersOccNum(1:numObstTypes) );
        tracersOccFrac(numObstTypes+1) = 1 - sum( tracersOccFrac(1:numObstTypes) );
      else
        obj.AllPts( 1:nTracer ) = emptySites( randi( length(emptySites), [1 nTracer] ) );
        obj.State( 1:nTracer ) = numObstTypes+1;
        tracersOccNum(numObstTypes+1) = nTracer;
        tracersOccFrac(numObstTypes+1) = 1;
      end % allow obstacle placement
      % store other things
      obj.OccNum = tracersOccNum;
      obj.OccFrac = tracersOccFrac;
    end % place
  end % methods
end % class
