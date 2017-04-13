%[diffStruct, param] = ...
%  diffMatParamExtact( Dmat, pVaryStr, p1Want, p2Want, p3Want )
%
% diffMatParamExtact return an organize structure and parameter cell that 
% make plotting over various parameters much more useful. 

function [diffStruct, param] = ...
  diffMatParamExtact( Dmat, pVaryStr, pVaryWant, p1Want, p2Want, p3Want )
% from str, get parameter info
if strcmp(pVaryStr,'bdiff')
  param.pVaryStr = pVaryStr;
  param.pVaryTex = '$$ D_{bound} $$';
  varyInd = 1;
  p1Ind = 2;
  p1Name = '\Delta G';
  p2Ind = 3;
  p2Name= '\nu';
  p3Ind = 4;
  p3Name = 'l_{obst}';
elseif strcmp(pVaryStr,'be')
  param.pVaryStr = pVaryStr;
  param.pVaryTex = '$$ \Delta G $$';
  varyInd = 2;
  p1Ind = 1;
  p1Name = 'D_{bound}';
  p2Ind = 3;
  p2Name= '\nu';
  p3Ind = 4;
  p3Name = 'l_{obst}';
elseif strcmp(pVaryStr,'nu')
  param.pVaryStr = pVaryStr;
  param.pVaryTex = '$$ \nu $$';
  varyInd = 3;
  p1Ind = 1;
  p1Name = 'D_{bound}';
  p2Ind = 2;
  p2Name = '\Delta G';
  p3Ind = 4;
  p3Name = 'l_{obst}';
elseif strcmp(pVaryStr,'lobst')
  param.pVaryStr = pVaryStr;
  param.pVaryTex = '$$ l_{obst} $$';
  varyInd = 4;
  p1Ind = 1;
  p1Name = 'D_{bound}';
  p2Ind = 2;
  p2Name = '\Delta G';
  p3Ind = 3;
  p3Name= '\nu';
else
  error('cannot find varying parameter')
end
% exact the parameters you want
% be careful about rounding
roundVal = 1000;
pVary = unique( round( roundVal .* Dmat(:, varyInd ) ) ./ roundVal, 'stable' );
p1 = unique( Dmat(:, p1Ind ), 'stable'  );
p2 = unique( Dmat(:, p2Ind ), 'stable'  );
p3 = unique( Dmat(:, p3Ind ), 'stable'  );
% if empty, you get everything. if not, get what you want
if isempty(pVaryWant)
  pVaryWant = pVary; 
else
  pVaryWant = intersect( pVaryWant, pVary, 'stable' );
end
if isempty(p1Want)
  p1Want = p1; 
else
  p1Want = intersect( p1Want, p1, 'stable' );
end
if isempty(p2Want)
  p2Want = p2; 
else
  p2Want = intersect( p2Want, p2, 'stable' );
end
if isempty(p3Want)
  p3Want = p3;
else
  p3Want = intersect( p3Want, p3, 'stable' );
end
if isempty(p1Want) || isempty(p2Want) || isempty(p3Want) || isempty(pVaryWant)
  error('input parameter error')
end
% get length
numP1 = length(p1Want);
numP2 = length(p2Want);
numP3 = length(p3Want);
numParams = numP1 * numP2 * numP3;
% paramMat
paramMat = combvec( p1Want', p2Want', p3Want' );
% find max
numVec = [numP1, numP2, numP3];
numVecSort = sort( numVec );
indsV = 1:3;
max1 = numVecSort(3);
max2 = numVecSort(2);
max3 = numVecSort(1);
% only supports two "fixed" variables changing
if max3 ~= 1
  error('Too many varying parameters');
end
maxInd1 = indsV( max1 ==  numVec );
maxInd2 = indsV( max2 ==  numVec );
% extract max vector
maxTemp = {p1Want, p2Want, p3Want};
nameTemp = {p1Name, p2Name, p3Name};
maxVec1 = maxTemp{maxInd1};
maxVec2 = maxTemp{maxInd2};
maxName1 = nameTemp{maxInd1};
maxName2 = nameTemp{maxInd2};
maxMat = combvec( maxVec1', maxVec2' );
% Allocate markers and colors
figure(1000)
colorArray = colormap(['lines(' num2str(numParams) ')']);
close(1000)
colorInds = 1:max1;
markerArray = ['o','s','^','d','+','x'];
markerInds = 1:max2;
indsColorMark = combvec( colorInds, markerInds );
% allocate
param.colorMat = colorArray( indsColorMark(1,:), : );
param.markerVec = markerArray( indsColorMark(2,:) );
% Allocate diffStruct and paramCell
paramCell = cell( 1, numParams );
diffStruct(numParams).pVary = pVaryWant;
% build D struct
for ii = 1:numParams
  str = [];
  % get inds
  p1temp = paramMat(1,ii);
  p2temp = paramMat(2,ii);
  p3temp = paramMat(3,ii);
  maxtemp1 = maxMat(1,ii);
  maxtemp2 = maxMat(2,ii);
  getInd1 = find( Dmat( :, p1Ind ) == p1temp );
  getInd2 = find( Dmat( :, p2Ind ) == p2temp );
  getInd3 = find( Dmat( :, p3Ind ) == p3temp );
  % extra just the info we want
  inds = intersect( getInd1, intersect(getInd2, getInd3) );
  DmatTemp = Dmat(inds, :);
  % repeat for varyign ind
  DmatTemp( :, varyInd ) = round( roundVal .*  DmatTemp( :, varyInd ) ) ./ roundVal;
  pVaryTemp = intersect( pVaryWant,  DmatTemp( :, varyInd ), 'stable' );
  getIndVary = zeros( length(pVaryTemp), 1 );
  for jj = 1:length(pVaryTemp)
    getIndVary(jj) =  find( DmatTemp( :, varyInd ) == pVaryTemp(jj) );
  end
  DmatTemp = DmatTemp(getIndVary,:);
  % build cell
  if max2 >  1
    if isinf(maxtemp2)
      str = [str '$$' maxName2 ' = \infty $$; '];
    else
      str = [str '$$' maxName2 ' = ' num2str( maxtemp2 ) ' $$; '];
    end
  end
  if max1 >  1
    if isinf(maxtemp1)
      str = [str '$$' maxName1 ' = \infty $$; '];
    else
      str = [str '$$' maxName1 ' = ' num2str( maxtemp1 ) ' $$'];
    end
  end
   % get rid of last ; and spaces
   if strcmp( str(end-1:end), '; ')
    str = str(1:end-2);
  end
  % store it
  diffStruct(ii).Dmat = DmatTemp;
  diffStruct(ii).pVary = pVaryTemp;
  diffStruct(ii).p1Name = p1Name;
  diffStruct(ii).p1 = p1temp;
  diffStruct(ii).p2Name = p2Name;
  diffStruct(ii).p2 = p2temp;
  diffStruct(ii).p3Name = p3Name;
  diffStruct(ii).p3 = p3temp;
  diffStruct(ii).D = DmatTemp(:,5);
  diffStruct(ii).Dsig = DmatTemp(:,6);
  diffStruct(ii).tAnom = DmatTemp(:,7);
  diffStruct(ii).tAnomSig = DmatTemp(:,8);
  diffStruct(ii).alpha = DmatTemp(:,12);
  diffStruct(ii).legStr = str;
  paramCell{ii} = str;
end
% param stuff
param.numParams = numParams;
param.pVaryStr = pVaryStr;
param.pVary = pVaryWant;
param.p1Str = p1Name;
param.p1 = p1Want;
param.p2Str = p2Name;
param.p2 = p2Want;
param.p3Str = p3Name;
param.p3 = p3Want;
param.vals = paramMat.';
param.legcell = paramCell;
