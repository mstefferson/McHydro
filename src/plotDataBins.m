function plotDataBins( x, y, spaceLog, slopeBin, yinter )
figure()
plot( log10( x ), log10( y./x ) )
xlabel( 'log_{10} (t) ' ); ylabel( 'log_{10} (x^2/t) ' );
title('Log Plot Data and bin lines')
hold on
% Do a linear fit of data between points in a bin
for ii = 1:length(spaceLog) - 1
  indStart =  spaceLog(ii) ;
  indEnd = spaceLog(ii+1) ;
  xTemp =  log10( x( indStart:indEnd ) );
  plot( xTemp, slopeBin(ii)  .* xTemp  + yinter(ii) );
end

