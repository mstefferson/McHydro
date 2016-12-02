%  plotDataAsympError( x, y, erry, slopeMax, yinterAsy, tasymp, ...
%     earlyAsymp, hAsymp, sigh, be, ffo, bBar, errorFlag )
% Description: Plot horizontal asymptope with error bars, tasymp, and max slope

function plotDataAsympError( x, y, erry, slopeMax, yinterAsy, tanom, ...
  earlyAsymp, hAsymp, sigh, be, ffo, bBar, errorFlag )
% Calculate lenght and logs
lenX = length(x);
logx = log10(x);
logy_x = log10( y ./ x);
% set-up figure
figure()
hold on
ax = gca;
ax.YLim = [ min( logy_x ), max( logy_x )];
falsehugeSlope = 10000; % for t anom
% plot data
if errorFlag
  errorbar( logx, logy_x, erry ./ ( y .* log(10) ) );
else
  plot( logx, logy_x );
end
xlabel( 'log_{10} (t) ' ); ylabel( 'log_{10} (x^2/t) ' );
titstr = ['Log Plot Data and bin lines be = ' num2str( be ) ...
  ' ffo = ' num2str( ffo, '%.2f' ) ' bBar = ' num2str( bBar ) ];
title(titstr)
% plot asymptote and friends
plot( logx, hAsymp .* ones( lenX , 1) );
plot( logx, ( hAsymp - sigh ) .* ones( lenX, 1) )
plot( logx, ( hAsymp + sigh ) .* ones( lenX, 1) )
plot( logx, falsehugeSlope .* logx - falsehugeSlope * log10(tanom) );
% plot max slope if it was able to
if earlyAsymp == 0
  plot( logx, slopeMax .*  logx + yinterAsy )
end
