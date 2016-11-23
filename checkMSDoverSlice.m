function checkMSDoverSlice( path2files )

files = dir( [path2files 'data*'] );
numfiles = length(files);

dt2check = [10 100 1000];

% load out here to for memory allocation
%load( files(1).name );
%data = tracer_cen_rec_nomod;
%number_timepnts = size(data,3);
%NwMax = ceil( number_timepnts ./ dt2check ) - 1;

msdt10 = 0;
msdt100 = 0;
msdt1000 = 0;
data = 0;

keyboard

for ii = 1:numfiles
  load( [path2files files(ii).name] )
  dataTemp = tracer_cen_rec_nomod;
  data = data + dataTemp;
  msdtemp10 = calcMSDforAllSlice( dataTemp, dt2check(1) );
  msdt10 = msdt10 + msdtemp10;

  msdtemp100 = calcMSDforAllSlice( dataTemp, dt2check(2) );
  msdt100 = msdt100 + msdtemp100;

  msdtemp1000 = calcMSDforAllSlice( dataTemp, dt2check(3) );
  msdt1000 = msdt1000 + msdtemp1000;

end

msdt10 = msdt10 ./ numfiles;
msdt100 = msdt100 ./ numfiles;
msdt1000 = msdt1000 ./ numfiles;
data = data ./ numfiles;

figure()
plot( msdt10 )
figure()
plot( msdt100 )
figure()
plot( msdt1000 )

save( 'aveGridData','data' )
keyboard

