% Get rid of huge saved files

files =  dir( 'msd_*');

for ii = 1:length(files)
  load( files(ii).name )
  if isfield(obst,'edgeInds')
    obst = rmfield( obst, 'edgeInds');
    save(files(ii).name , 'const', 'dtime', 'modelopt',...
      'msd', 'obst', 'occupancy', 'paramlist','tracer');
  end
end