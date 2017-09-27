% testTimeDependence

% load file
tempdir = 'bd1be2fo03/';
bd = 1;
be = 2;
fo = 0.3;

dirPath = ['./runfiles/' tempdir];
files = dir( [dirPath '*.mat'] );
dSlice = 100;

% load first one out of loop
numFiles = length(files);
S = load( [dirPath files(1).name] );
x = S.tracer_cen_rec_nomod;
% time stuff
number_timepnts = size(x,3);
number_delta_t  = number_timepnts - 1;
dtime= ( 1 : number_delta_t)' ;
index_end = number_timepnts:-dSlice:1+dSlice;
index_start = index_end - dSlice;
numIntervals = length( index_end );



% calculate first one
delta_coords = x(:,:,index_end) - x(:,:,index_start);
% calculate displacement ^ 2
squared_dis = sum(delta_coords.^2,2); % dx^2+dy^2+...

particleAve = mean( squared_dis, 1);

%allocate
gridStore = zeros( numFiles, numIntervals );

particleAve = reshape( particleAve, [ 1, numIntervals ] );
gridStore(1,:) = particleAve;

for ii = 2:numFiles
  S = load( [dirPath files(ii).name] );
  x = S.tracer_cen_rec_nomod;
  
  delta_coords = x(:,:,index_end) - x(:,:,index_start);
  % calculate displacement ^ 2
  squared_dis = sum(delta_coords.^2,2); % dx^2+dy^2+...
  
  particleAve = mean( squared_dis, 1);
  
  particleAve = reshape( particleAve, [ 1, numIntervals ] );
  gridStore(ii,:) = particleAve;
end

% average over ensemble
emsembleAve = mean( gridStore, 1 );
timeEnsembleAve = mean( emsembleAve );

figure()
subplot(1, 2, 1)
plot( 1:numIntervals, particleAve, ...
  1:numIntervals, timeEnsembleAve .* ones(1, numIntervals) );
xlabel('simulation time'); ylabel('value');
titstr = sprintf(' bd = %d be = %d fo = %.2f \n', bd, be, fo );
title( titstr );
subplot(1, 2, 2)
loglog( 1:numIntervals, particleAve );
xlabel('simulation time'); ylabel('value');
titstr = sprintf(' time delay = %d \n', dSlice );
title( titstr );

