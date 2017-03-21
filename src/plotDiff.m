% masterD( be, ffo, bBar, D, Dsig, tAsymp, tAsympSig, steadyState , ...
% earlyAsymp, slopeEnd, slopeMoreNeg, yinterMostNeg, upperbound)
function plotDiff( axTemp, Dstruct, param )
% loop over plots
for ii = 1:param.numParams
  % plot it
  x2plot =  Dstruct(ii).pVary;
  y2plot =  Dstruct(ii).Dmat(:,5);
  p = plot(axTemp, x2plot, y2plot, param.markerVec(ii));
  % design
  p.Marker = param.markerVec(ii);
  p.MarkerFaceColor = param.colorMat(ii,:);
  p.Color = param.colorMat(ii,:);
end
  

