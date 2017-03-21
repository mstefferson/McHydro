% masterD( be, ffo, bBar, D, Dsig, tAsymp, tAsympSig, steadyState , ...
% earlyAsymp, slopeEnd, slopeMoreNeg, yinterMostNeg, upperbound)
function plotAlpha( axTemp, Dstruct, param )
% loop over plots
for ii = 1:param.numParams
  % find ind
  x2plot =  Dstruct(ii).pVary;
  y2plot =  1+Dstruct(ii).Dmat(:,12);
  p = plot(axTemp, x2plot, y2plot, param.markerVec(ii));
  % design 
  p.Marker = param.markerVec(ii);
  p.MarkerFaceColor = param.colorMat(ii,:);
  p.Color = param.colorMat(ii,:);
end
