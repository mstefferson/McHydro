%%
cd ./runfiles
FilesInRun = filelist('data',pwd);
S = load( FilesInRun{1} );
cd ../
%%
% Calculate the squared diplacement
dt = 5;  % Time interval you want to examine
x = S.tracer_cen_rec_nomod;
maxpts_msd = S.const.maxpts_msd;

number_timepnts = size(x,3);
number_delta_t  = number_timepnts - 1;
dtime = ( 1 : number_delta_t)';

% Find change in coordinates
if number_timepnts-dt >= maxpts_msd
  index_start = randperm(number_timepnts-dt, maxpts_msd);
  index_end = index_start+dt;
  delta_coords= x(:,:,index_start)-x(:,:,index_end);
else
  delta_coords=x(:,:,1+dt:end)-x(:,:,1 : end-dt );
end

% Calculate the squared and quartic displacement
squared_dis = sum(delta_coords.^2,2);
[nR, nC, nH] = size(squared_dis);
quartic_dis = sum(delta_coords.^4,2);

% Guassian parameters and histogram stuff
bins4hist = 10;
Nt = dt * const.rec_interval;
sigmaSqr = 2 * Nt * (Nt - 1) ;
Mu       = Nt;
sigma    = sqrt( sigmaSqr );
PlotRange = 0: 0.1 : 2*Nt;
GaussNorm1 = 1 / sqrt(2*pi*sigmaSqr) * ...
  exp( -( PlotRange - Nt ) .^ 2 ./ (2 * sigmaSqr ) );

% Calculate averages
% Reshape so we have all particle at all time points in an array
squared_disAll = reshape( squared_dis, ...
  [ nR * nH, nC ] );
squared_disAveT = mean( squared_dis, 3 );
squared_disAveP = mean( squared_dis, 1 );
squared_disAveP = squared_disAveP(:);
squared_disAveAll = mean( squared_disAveP);
squared_theory = Nt;

quartic_disAveT = mean( quartic_dis, 3 );
quartic_disAveP = mean( quartic_dis, 1 );
quartic_disAveP = quartic_disAveP(:);
quartic_disAveAll = mean( quartic_disAveP);
quartic_theory = 3 * Nt^2 - 2 * Nt; 

%squared_disAveP = reshape( mean( squared_dis, 1 ), [nH nC] );



%%
% Plot all the points
figure()
hist(squared_disAll);
title('All')
xlabel('x^2'); ylabel('counts');

%%
% Plot average over time
numPoints = sum( squared_disAveT );
Gauss =  numPoints  * GaussNorm1 ./ bins; 
figure()
H = histogram(squared_disAveT,bins);
hold all
plot(PlotRange,Gauss);
title('Averaged over time')
xlabel('x^2'); ylabel('counts');
%%
% Plot average over particles
numPoints = sum( squared_disAveP );
Gauss =  numPoints  * GaussNorm1; 
figure()
hist(squared_disAveP);
hold all
plot(PlotRange,Gauss);
title('Avergaed over Particles')
xlabel('x^2'); ylabel('counts');


