% Plot Horzitonal asymptote with error bars
function plotDataAsympError( x, y, erry, slopeStart, yinter, hAsymp, sigh, be, ffo, bBar, errorFlag )

lenX = length(x);

figure()
if errorFlag
errorbar( log10(x), log10(y./x), erry ./ ( y .* log(10) ) );
else
plot( log10(x), log10(y./x) );
end
xlabel( 'log_{10} (t) ' ); ylabel( 'log_{10} (x^2/t) ' );
titstr = ['Log Plot Data and bin lines be = ' num2str( be ) ...
  ' ffo = ' num2str( ffo, '%.2f' ) ' bBar = ' num2str( bBar ) ];
title(titstr)
hold on
plot( log10(x), hAsymp .* ones( lenX , 1) );
plot( log10(x), ( hAsymp - sigh ) .* ones( lenX, 1) )
plot( log10(x), ( hAsymp + sigh ) .* ones( lenX, 1) )
plot( log10( x ), slopeStart .*  log10( x ) + yinter(1) )