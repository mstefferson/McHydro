% masterD( be, ffo, bBar, D, Dsig, tAsymp, tAsympSig, steadyState , ...
% earlyAsymp, slopeEnd, slopeMoreNeg, yinterMostNeg, upperbound)
function plotDiffDstruct( axTemp, Dstruct, param )
% colors
colormap(['lines(' num2str(param.numParams) ')']);
map=colormap;
set(gcf,'DefaultAxesColorOrder',map);
% loop over plots
for ii = 1:param.numParams
  % plot it
  x2plot =  param.pVary;
  y2plot =  Dstruct(ii).Dmat(:,5);
  p = plot(axTemp, x2plot, y2plot,'o');
  % design
  p.Marker = 'o';
  p.LineWidth = 1;
  p.MarkerFaceColor = map(ii,:);
  p.Color = map(ii,:);
end

