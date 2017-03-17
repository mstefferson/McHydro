% masterD( be, ffo, bBar, D, Dsig, tAsymp, tAsympSig, steadyState , ...
% earlyAsymp, slopeEnd, slopeMoreNeg, yinterMostNeg, upperbound)
function plotTasymVsNuDmat( axTemp, D2plot, xInd, be2plot )
%
numBe = length(be2plot);
% colors
colormap(['lines(' num2str(numBe) ')']);
map=colormap;
set(gcf,'DefaultAxesColorOrder',map);

for ii = 1:numBe
  beTemp = be2plot(ii);
  % find ind
  ind2plot = find( D2plot(:,1) == beTemp );
  x2plot =  D2plot(ind2plot,xInd);
  y2plot =  D2plot(ind2plot,7);
  err2plot =  D2plot(ind2plot,8);
  p = errorbar(axTemp, x2plot, y2plot, err2plot,'o');
  
  p.Marker = 'o';
  p.LineWidth = 1;
  p.MarkerFaceColor = map(ii,:);
  p.Color = map(ii,:);
end

