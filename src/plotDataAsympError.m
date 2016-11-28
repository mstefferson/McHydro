% Plot Horzitonal asymptote with error bars
function plotDataAsympError( x, y, erry, hAsymp, sigh )

lenX = length(x);

figure()
errorbar( log10(x), log10(y./x), erry ./ ( y .* log(10) ) );
xlabel( 'log_{10} (t) ' ); ylabel( 'log_{10} (x^2/t) ' );
title('Data w/ error bars')
hold on
plot( log10(x), hAsymp .* ones( lenX , 1) );
plot( log10(x), ( hAsymp - sigh ) .* ones( lenX, 1) )
plot( log10(x), ( hAsymp + sigh ) .* ones( lenX, 1) )

