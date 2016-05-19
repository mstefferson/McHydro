%% Plot stuff

figure()
plot( time, aveX, time, 0 .* time )
title('x')
figure()
plot( time, aveX2, time, time )
title('x^2')
figure()
plot( time, aveX4, time, 3 .* time .^ 2 - 2 .* time );
title('x^4')

%% Histogram stuff
bins  = 20;
figure()
Nptns = length( xAll );
Hx = histogram( xAll , 'BinMethod','integers');
Counts  = Hx.Values;
Bins    = Hx.BinEdges;
Percent = Counts ./ Nptns;
% Center the bins 
Hx.BinEdges = Hx.BinEdges - Hx.BinWidth/2;

figure()
% Gaussian
xStart = -deltaT;
xEnd   = deltaT;
xVec = linspace( xStart, xEnd, 100);
Mu = 0;
sigma2 = deltaT;

Norm    = length( xAll ) .* Hx.BinWidth;
GaussX = Norm / sqrt( 2 * pi * sigma2 ) * ...
  exp( -(xVec - Mu) .^ 2 / (2 * sigma2 ) );

GaussX = 1 / sqrt( 2 * pi * sigma2 ) * ...
  exp( -(xVec - Mu) .^ 2 / (2 * sigma2 ) );

bar( Bins(2:end), Percent)
hold all
plot( xVec, GaussX)
title('x'); xlabel('x'); ylabel('counts') 

%%
% Play with effect on averaging
bins  = 11;
figure()
Hx = histogram( xAveP, bins);
hold all
% Center the bins 
Hx.BinEdges = Hx.BinEdges - Hx.BinWidth/2;
title('x averged over particles')

xStart = -deltaT;
xEnd   = deltaT;
xVec = linspace( xStart, xEnd, 100);
Mu = 0;
sigma2 = deltaT ./ Np;

Norm    = length( xAveP ) .* Hx.BinWidth;
GaussX = Norm / sqrt( 2 * pi * sigma2 ) * ...
  exp( -(xVec - Mu) .^ 2 / (2 * sigma2 ) );

plot( xVec, GaussX)
xlabel('x'); ylabel('counts')

%%

bins  = 11;
figure()
Hx = histogram( xAveT, bins);
hold all
% Center the bins 
Hx.BinEdges = Hx.BinEdges - Hx.BinWidth/2;
title('x averaged over time slices')

xStart = -deltaT;
xEnd   = deltaT;
xVec = linspace( xStart, xEnd, 100);
Mu = 0;
sigma2 = deltaT ./ numTimeSlices ;
Norm    = length( xAveT ) .* Hx.BinWidth;
GaussX = Norm / sqrt( 2 * pi * sigma2 ) * ...
  exp( -(xVec - Mu) .^ 2 / (2 * sigma2 ) );

plot( xVec, GaussX)

%%
bins = 36;
figure()
Hx2 = histogram( x2All , bins);
hold all
title('x^2 all')
% Center the bins 
Hx2.BinEdges = Hx2.BinEdges - Hx2.BinWidth/2;

xStart = 0;
xEnd   = deltaT .^ 2 / 4;
xVec = linspace( xStart, xEnd, 100);
N = length(x2All);
Mu = deltaT;
sigma2 = 2 .* deltaT .* (deltaT - 1);


GaussX2 = (N .* Hx2.BinWidth) / sqrt( 2 * pi * sigma2 ) * ...
  exp( -(xVec - Mu) .^ 2 / (2 * sigma2 ) );

plot( xVec, GaussX2)
title('x');

%%
figure()
Hx2 = histogram( x2AveT , bins);
hold all
title('x^2 average over time slices')


figure()
Hx2 = histogram( x2AveP , bins);
hold all
title('x^2 average over particles')