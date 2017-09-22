function [obstObj] =  obstManager( obst, modelopt )
% Build obstObj
numObst = length(obst);
if numObst
  % number of strings
  % Allocate
  obstInputs = zeros( 1, numObst );
  names = cell( 1, numObst );
  for ii = 1:numObst
    obstTemp = obst{ii};
    names{ii} = obstTemp{1};
    % take care of parameters
    obstInputs(ii) = length(obstTemp) - 1;
    paramInd = 2;
    paramSingMat = obstTemp{paramInd};
    for jj = paramInd+1:length(obstTemp)
      paramSingMat = combvec(paramSingMat,obstTemp{jj});
    end
    if ii == 1
      paramMat = paramSingMat;
    else
      paramMat = combvec(paramMat, paramSingMat);
    end
  end
  % put transpose in cell
  [ numRuns, ~] = size(paramMat');
  obstInds = 1:numRuns;
  paramSepCell = mat2cell( paramMat', ones(1, numRuns), obstInputs );
  % Reallocate
  obstRun = cell( 1, numRuns);
  obstParams = cell( 1, numObst);
  obstStr = cell( 1, numRuns);
  % set-up str and parmaters
  for ii = 1:numRuns
    strTemp = [];
    for jj = 1:numObst
      obstTemp = { names{jj}, paramSepCell{ii,jj} };
      % check runs
      if names{jj} == 'rand'
        [obstTemp, strAdd] = checkObstRand( obstTemp, modelopt );
      elseif names{jj} == 'wall'
        [obstTemp, strAdd] = checkObstWall( obstTemp );
      end
      obstParams{jj} = obstTemp;
      strTemp = [  strTemp strAdd];
    end
    % fix str
    obstStr{ii} = strTemp;
    obstRun{ii} = obstParams;
  end 
else
  obstRun = {[]};
  obstStr = {''};
  obstInds = 1;
end
% Store it
obstObj.param = obstRun;
obstObj.str = obstStr;
obstObj.inds = obstInds;
end

% random
function [obst, obstStr] = checkObstRand( obst, modelopt )
% check inputs
if length(obst{1,2}) ~= 5
  fprintf('Incorrect number of random obstacle parameters\n')
  error('Incorrect number of random obstacle parameters\n')
end
% fix edge place
% Dont place on edges if obstacles can overlap
if modelopt.obst_excl == 0
  obst{1,2}(5)=0;   %1 if place tracers on obstacle edges
% if bound diffusion = 0, place on edges
elseif obst{1,2}(1) == 0
  obst{1,2}(5)=1;   %1 if place tracers on obstacle edges
end
% check size
obst{1,2}(4) = max( obst{1,2}(4), 1 );

% make string
obstParams = obst{1,2};
obstStr = [ '_rand_bD' num2str(obstParams(1),'%.2f')  ...
'_be' num2str(obstParams(2),'%.2f') '_fo' num2str(obstParams(3),'%.2f')  ...
'_so' num2str(obstParams(4),'%d') ]; 
end

% wall
function [obst, obstStr] = checkObstWall( obst )

% check inputs
if length(obst{1,2}) ~= 4
  fprintf('Incorrect number of wall obstacle parameters\n')
  error('Incorrect number of wall obstacle parameters\n')
end
% make string
obstParams = obst{1,2};
obstStr = [ '_wall_bD' num2str(obstParams(1),'%.2f')  ...
'_be' num2str(obstParams(2),'%.2f') '_t' num2str(obstParams(3),'%.2f')  ...
'_gw' num2str(obstParams(4),'%d') ]; 
end
