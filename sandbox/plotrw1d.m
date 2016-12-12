% Fit parameters
binMax = 50;

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

% All points

bins  = length( unique( xAll ) );
figure()
Nptns = length( xAll );
Hx = histogram( xAll , bins);
title('Histogram: All points'); xlabel('x'); ylabel('counts'); 


% Turn histogram into a probability density
BinCenter = ( Hx.BinEdges(1:end-1) + Hx.BinEdges(2:end) ) / 2;
Counts  = Hx.Values;
Percent = Counts ./ Nptns;
ProbDen = Percent ./ Hx.BinWidth;

% Gaussian
xStart = -deltaT;
xEnd   = deltaT;
xVec = linspace( xStart, xEnd, 100);
Mu = 0;
sigma2 = deltaT;
GaussX = 1 / sqrt( 2 * pi * sigma2 ) * ...
  exp( -(xVec - Mu) .^ 2 / (2 * sigma2 ) );

% probability density plot
figure()
bar( BinCenter, ProbDen)
hold all
plot( xVec, GaussX)
title('x'); xlabel('x'); ylabel('Probability denisty') 

%%
% Play with effect on averaging: Averaging over Particles

bins  = length( unique( xAveP ) );
if bins > binMax; bins = binMax; end;
figure()
Nptns = length( xAveP );
Hx = histogram( xAveP , bins);
title('Histogram: Ave of Particles'); xlabel('x'); ylabel('counts');

% Turn histogram into a probability density
BinCenter = ( Hx.BinEdges(1:end-1) + Hx.BinEdges(2:end) ) / 2;
Counts  = Hx.Values;
Percent = Counts ./ Nptns;
ProbDen = Percent ./ Hx.BinWidth;

% Gaussian
xStart = -deltaT;
xEnd   = deltaT;
xVec = linspace( xStart, xEnd, 100);
Mu = 0;
sigma2 = deltaT ./  Np ;
GaussX = 1 / sqrt( 2 * pi * sigma2 ) * ...
  exp( -(xVec - Mu) .^ 2 / (2 * sigma2 ) );

% probability density plot
figure()
bar( BinCenter, ProbDen)
hold all
plot( xVec, GaussX)
title('x: Averaged over particles'); 
xlabel('x'); ylabel('Probability denisty') 

%%
% Play with effect on averaging: Averaging over TimeSlices

bins  = length( unique( xAveT ) );
if bins > binMax; bins = binMax; end;

figure()
Nptns = length( xAveT );
Hx = histogram( xAveT , bins);
title('Histogram: Ave of TimeSlices'); xlabel('x'); ylabel('counts');

% Turn histogram into a probability density
BinCenter = ( Hx.BinEdges(1:end-1) + Hx.BinEdges(2:end) ) / 2;
Counts  = Hx.Values;
Percent = Counts ./ Nptns;
ProbDen = Percent ./ Hx.BinWidth;

% Gaussian
xStart = -deltaT;
xEnd   = deltaT;
xVec = linspace( xStart, xEnd, 100);
Mu = 0;
sigma2 = deltaT ./  numTimeSlices ;
GaussX = 1 / sqrt( 2 * pi * sigma2 ) * ...
  exp( -(xVec - Mu) .^ 2 / (2 * sigma2 ) );

% probability density plot
figure()
bar( BinCenter, ProbDen)
hold all
plot( xVec, GaussX)
title('x: Averaged over Time Slices'); 
xlabel('x'); ylabel('Probability denisty') 

%% x2 stuff

bins  = length( unique( x2All ) );
if bins > binMax; bins = binMax; end;

figure()
Nptns = length( x2All );
Hx = histogram( x2All , bins);
title('Histogram: All'); xlabel('x^2'); ylabel('counts');

% Turn histogram into a probability density
Counts  = Hx.Values;
BinCenter = ( Hx.BinEdges(1:end-1) + Hx.BinEdges(2:end) ) / 2;
Percent = Counts ./ Nptns;
% Plot probability now with poisson
Prob = Percent;

% Binomial stuff
% Find unique values 
UniX2  = unique( x2All );
NumPoints = length( x2All );
ProbabOcc = zeros( length( UniX2 ) , 1);
for i = 1:length(UniX2)
  ProbabOcc(i) = length( find( x2All == UniX2(i) ) ) ./ NumPoints;
end

xStart = 0;
xEnd   = deltaT .^ 2 ;
xVec = xStart:1:round(xEnd);
Mu = deltaT;
sigma2 = 2 .* deltaT .* (deltaT - 1);
Poisson = zeros( length(xVec), 1 );
Fact = 1;
for i = 1:length(xVec)
  Fact = Fact * i;
  Poisson(i) = Mu .^ i * exp( - Mu ) ./ Fact;
end

figure()
scatter( UniX2, ProbabOcc )
hold all
title('x^2'); xlabel('x'); ylabel('Probability') 

%%
%figure()
%Hx2 = histogram( x2AveT , bins);
%hold all
%title('x^2 average over time slices')


%figure()
%Hx2 = histogram( x2AveP , bins);
%hold all
%title('x^2 average over particles')
