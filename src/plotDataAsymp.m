% Plot Horzitonal asymptote and early time slope

function plotDataAsymp( x, y, hAsymp, slopeStart, yinter )

figure()
plot( log10( x ), log10( y./x ) )
xlabel( 'log_{10} (t) ' ); ylabel( 'log_{10} (x^2/t) ' );
title('Log Plot Data and bin lines')
hold on
plot( log10( x ), ones( length(x) ,1 ) .* hAsymp, ...
  log10( x ), slopeStart .*  log10( x ) + yinter(1) )
