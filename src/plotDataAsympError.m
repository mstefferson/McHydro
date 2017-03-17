%  plotDataAsympError( x, y, erry, slopeMax, yinterAsy, tasymp, ...
%     earlyAsymp, hAsymp, sigh, be, ffo, bBar, errorFlag )
% Description: Plot horizontal asymptope with error bars, tasymp, and max slope
function plotDataAsympError( x, y, erry, slopeMax, yinterAsy, tanom, ...
  earlyAsymp, hAsymp, sigh, be, ffo, bBar, errorFlag )
% Calculate lenght and logs
lenX = length(x);
y_x = y ./ x;
% set-up figure
figure()
hold on
ax = gca;
ax.YLim = [ min( y_x ), max( y_x )];
ax.XScale = 'log';
ax.YScale = 'log';
falseHugeSlope = 50; % for t anom
% plot data
if errorFlag
  errorbar( x, y_x, erry ./  y  );
else
  plot( x, y_x );
end
xlabel( 't' ); ylabel( 'x^2/t' );
titstr = ['Log Plot Data and bin lines be = ' num2str( be ) ...
  ' ffo = ' num2str( ffo, '%.2f' ) ' bBar = ' num2str( bBar ) ];
title(titstr)
% plot asymptote and friends
plot( x, hAsymp .* ones( lenX , 1) );
plot( x, ( hAsymp - sigh ) .* ones( lenX, 1) )
plot( x, ( hAsymp + sigh ) .* ones( lenX, 1) )
y = x .^ (falseHugeSlope) * tanom ^ (-falseHugeSlope ) ;
plot( x, y );
% plot max slope if it was able to
if earlyAsymp == 0
  y = x .^ (slopeMax) * exp(yinterAsy);
  plot( x, y )
end
