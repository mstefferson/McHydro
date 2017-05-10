% masterD( be, ffo, bBar, D, Dsig, tAsymp, tAsympSig, steadyState , ...
% earlyAsymp, slopeEnd, slopeMoreNeg, yinterMostNeg, upperbound)
function plotAlpha( axTemp, Dstruct, param, connectDots )
% loop over plots
for ii = 1:param.numParams
  % find ind
  x2plot =  Dstruct(ii).pVary;
  y2plot = Dstruct(ii).alpha;
  y2plot( y2plot < 0 ) = 0;
  if connectDots
    p = plot(axTemp, x2plot, y2plot, ['-' param.markerVec(ii)]);
  else
    p = plot(axTemp, x2plot, y2plot, param.markerVec(ii));
  end
  % design 
  p.Marker = param.markerVec(ii);
  p.MarkerFaceColor = param.colorMat(ii,:);
  p.Color = param.colorMat(ii,:);
end

