% masterD( be, ffo, bBar, D, Dsig, tAsymp, tAsympSig, steadyState , ...
% earlyAsymp, slopeEnd, slopeMoreNeg, yinterMostNeg, upperbound)
function plotDvsNuDmat( axTemp, D2plot, be2plot )
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
  x2plot =  D2plot(ind2plot,2);
  y2plot =  D2plot(ind2plot,4);
  p = plot(axTemp, x2plot, y2plot,'o');
  
  p.Marker = 'o';
  p.LineWidth = 1;
  p.MarkerFaceColor = map(ii,:);
  p.Color = map(ii,:);
end

