% masterD( be, ffo, bBar, D, Dsig, tAsymp, tAsympSig, steadyState , ...
% earlyAsymp, slopeEnd, slopeMoreNeg, yinterMostNeg, upperbound)
function plotTasym( axTemp, Dstruct, param, connectDots )
% loop over plots
for ii = 1:param.numParams
  % plot it
  x2plot =  Dstruct(ii).pVary;
  y2plot =  Dstruct(ii).Dmat(:,7);
  err2plot =  Dstruct(ii).Dmat(:,8);
  % get rid of early t anomlaous
  inds = Dstruct(ii).Dmat(:,10) == 0 ;
  x2plot = x2plot( inds );
  y2plot = y2plot( inds );
  err2plot = err2plot( inds );
  if connectDots
    p = errorbar(axTemp, x2plot, y2plot, err2plot,['-' param.markerVec(ii)]);
  else
    p = errorbar(axTemp, x2plot, y2plot, err2plot,param.markerVec(ii));
  end
  % design 
  p.Marker = param.markerVec(ii);
  p.MarkerFaceColor = param.colorMat(ii,:);
  p.Color = param.colorMat(ii,:);
end

