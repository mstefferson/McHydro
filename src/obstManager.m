function [obstObj] =  obstManager( obst )
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
      if strcmp( names{jj}, 'rand' )
        [obstTemp, strAdd] = checkObstRand( obstTemp );
      elseif strcmp( names{jj}, 'wall' )
        [obstTemp, strAdd] = checkObstWall( obstTemp );
      elseif strcmp( names{jj}, 'teleport' )
        [obstTemp, strAdd] = checkObstTele( obstTemp );
      elseif strcmp( names{jj}, 'specloc' )
        [obstTemp, strAdd] = checkObstSpecloc( obstTemp );
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
function [obst, obstStr] = checkObstRand( obst )
% check inputs
if length(obst{1,2}) ~= 6
  fprintf('Incorrect number of random obstacle parameters\n')
  error('Incorrect number of random obstacle parameters\n')
end
% check size
obst{1,2}(4) = max( obst{1,2}(4), 1 );
% fix edge place
% Dont place on edges if obstacles can overlap
if obst{1,2}(5) == 0
  obst{1,2}(6)=0; 
% if length is one, there are not edges
elseif obst{1,2}(4) == 1
  obst{1,2}(6)=0;
% if bound diffusion = 0, place on edges
elseif obst{1,2}(1) == 0
  obst{1,2}(6)=1;
end
% make string
obstParams = obst{1,2};
obstStr = [ '_rand_bD' num2str(obstParams(1),'%.2f')  ...
'_be' num2str(obstParams(2),'%.2f') '_fo' num2str(obstParams(3),'%.2f')  ...
'_so' num2str(obstParams(4),'%d') '_oe', num2str( obstParams(5), '%d' ) ]; 
end

% wall
function [obst, obstStr] = checkObstWall( obst )
% check inputs
if length(obst{1,2}) ~= 6
  fprintf('Incorrect number of wall obstacle parameters\n')
  error('Incorrect number of wall obstacle parameters\n')
end
% make string
obstParams = obst{1,2};
obstStr = [ '_wall_bD' num2str(obstParams(1),'%.2f')  ...
'_be' num2str(obstParams(2),'%.2f') '_t' num2str(obstParams(3),'%.2f')  ...
'_gw' num2str(obstParams(4),'%d') ]; 
end

% teleport
function [obst, obstStr] = checkObstTele( obst )
% check inputs
if length(obst{1,2}) ~= 3
  fprintf('Incorrect number of teleport obstacle parameters\n')
  error('Incorrect number of teleport obstacle parameters\n')
end
% make string
obstStr = '_tp';
end

% specific location specloc
function [obst, obstStr] = checkObstSpecloc( obst )
% check inputs
if length(obst{1,2}) ~= 4
  fprintf('Incorrect number of specific location obstacle parameters\n')
  error('Incorrect number of specific location obstacle parameters\n')
end
% make string
obstStr = '_sp';
end
