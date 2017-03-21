
function [Dstruct, param] = ...
  diffMatParamExtact( Dmat, pVaryStr, p1want, p2want, p3want )
% from str, get parameter info
if strcmp(pVaryStr,'bdiff')
  param.pVaryStr = pVaryStr;
  param.pVaryTex = ' $$ D_{bound} $$ ';
  varyInd = 1;
  p1Ind = 2;
  p1Name = '\Delta G';
  p2Ind = 3;
  p2Name= '\nu';
  p3Ind = 4;
  p3Name = 'l_{obst}';
elseif strcmp(pVaryStr,'be')
  param.pVaryStr = pVaryStr;
  param.pVaryTex = ' $$ \Delta G $$ ';
  varyInd = 2;
  p1Ind = 1;
  p1Name = ' D_{bound} ';
  p2Ind = 3;
  p2Name= '\nu';
  p3Ind = 4;
  p3Name = 'l_{obst}';
elseif strcmp(pVaryStr,'nu')
  param.pVaryStr = pVaryStr;
  param.pVaryTex = ' $$ \nu $$ ';
  varyInd = 3;
  p1Ind = 1;
  p1Name = ' D_{bound} ';
  p2Ind = 2;
  p2Name = ' \Delta G ';
  p3Ind = 4;
  p3Name = 'l_{obst}';
elseif strcmp(pVaryStr,'lobst')
  param.pVaryStr = pVaryStr;
  param.pVaryTex = ' $$ l_{obst} $$ ';
  varyInd = 4;
  p1Ind = 1;
  p1Name = ' D_{bound} ';
  p2Ind = 2;
  p2Name = ' \Delta G ';
  p3Ind = 3;
  p3Name= '\nu';
else
  error('cannot find varying parameter')
end
% exact the parameters you want
% be careful about rounding
roundVal = 1000;
pVary = unique( round( roundVal .* Dmat(:, varyInd ) ) ./ roundVal );
p1 = unique( Dmat(:, p1Ind ) );
p2 = unique( Dmat(:, p2Ind ) );
p3 = unique( Dmat(:, p3Ind ) );
% if empty, you get everything. if not, get what you want
if isempty(p1want)
  p1want = p1; 
else
  p1want = intersect( p1want, p1 );
end
if isempty(p2want)
  p2want = p2; 
else
  p2want = intersect( p2want, p2 );
end
if isempty(p3want)
  p3want = p3;
else
  p3want = intersect( p3want, p3 );
end
% get length
numP1 = length(p1want);
numP2 = length(p2want);
numP3 = length(p3want);
numParams = numP1 * numP2 * numP3;
% paramMat
paramMat = combvec( p1want', p2want', p3want' );
paramCell = cell( 1, numParams );
Dstruct(numParams).pVary = pVary;
% build D struct
for ii = 1:numParams
  str = [];
  % get inds
  p1temp = paramMat(1,ii);
  p2temp = paramMat(2,ii);
  p3temp = paramMat(3,ii);
  getInd1 = find( Dmat( :, p1Ind ) == p1temp );
  getInd2 = find( Dmat( :, p2Ind ) == p2temp );
  getInd3 = find( Dmat( :, p3Ind ) == p3temp );
  % extra just the info we want
  inds = intersect( getInd1, intersect(getInd2, getInd3) );
  DmatTemp = Dmat(inds, :);
  if numP1 >  1
    if isinf(p1temp)
      str = [str '$$' p1Name ' = \infty $$; '];
    else
      str = [str '$$' p1Name ' = ' num2str( p1temp ) ' $$; '];
    end
  end
  if numP2 >  1
    if isinf(p2temp)
      str = [str '$$' p2Name ' = \infty $$; '];
    else
      str = [str '$$' p2Name ' = ' num2str( p2temp ) ' $$; '];
    end
  end
  if numP3 >  1
    if isinf(p3temp)
      str = [str '$$' p3Name ' = \infty $$; '];
    else
      str = [str '$$' p3Name ' = ' num2str( p3temp ) ' $$; '];
    end
  end
  % get rid of last ; and spaces
  if strcmp( str(end), ' ')
    str = str(1:end-1);
  end
  if strcmp( str(end), ';')
    str = str(1:end-1);
  end
  % store it
  Dstruct(ii).Dmat = DmatTemp;
  Dstruct(ii).pVary = pVary;
  Dstruct(ii).p1Name = p1Name;
  Dstruct(ii).p1 = p1temp;
  Dstruct(ii).p2Name = p2Name;
  Dstruct(ii).p2 = p2temp;
  Dstruct(ii).p3Name = p3Name;
  Dstruct(ii).p3 = p3temp;
  Dstruct(ii).legStr = str;
  paramCell{ii} = str;
end
% param stuff
param.numParams = numParams;
param.pVaryStr = pVaryStr;
param.pVary = pVary;
param.p1Str = p1Name;
param.p1 = p1want;
param.p2Str = p2Name;
param.p2 = p2want;
param.p3Str = p3Name;
param.p3 = p3want;
param.vals = paramMat.';
param.legcell = paramCell;
