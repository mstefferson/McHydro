% masterD( be, ffo, bBar, D, Dsig, tAsymp, tAsympSig, steadyState , ...
% earlyAsymp, slopeEnd, slopeMoreNeg, yinterMostNeg, upperbound)
function plotTasymDstruct( axTemp, Dstruct, param )
% colors
colormap(['lines(' num2str(param.numParams) ')']);
map=colormap;
set(gcf,'DefaultAxesColorOrder',map);
% loop over plots
for ii = 1:param.numParams
  % plot it
  x2plot =  param.pVary;
  y2plot =  Dstruct(ii).Dmat(:,7);
  err2plot =  Dstruct(ii).Dmat(:,8);
  p = errorbar(axTemp, x2plot, y2plot, err2plot,'o');
  % design 
  p.Marker = 'o';
  p.LineWidth = 1;
  p.MarkerFaceColor = map(ii,:);
  p.Color = map(ii,:);
end

