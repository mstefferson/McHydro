function msdout = calcMSDforAllSlice( data, dt )

number_timepnts = size(data,3);
NwMax = ceil( number_timepnts / dt ) - 1;
index_start = 1:dt:NwMax*dt;
index_end = index_start + dt;

delta_coords = data(:,:, index_end) - data(:,:,index_start);

squared_dis = sum(delta_coords.^2,2); % dx^2+dy^2+...

% msd vs time. average over particles
msdout = mean( squared_dis, 1 );

msdout = reshape( msdout, [1 NwMax] );

