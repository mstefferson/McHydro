files = dir('msd*');

for ii = 1:length(files)
  filename = files(ii).name;
  fprintf('Working on file %d: %s\n', ii, filename);
  load(filename);
  fields2go = {'allpts', 'center', 'centerInds',...
     'corner' ,'cornerInds'};
   try
      obst = rmfield( obst, fields2go );
      fprintf('deleting\n');
   catch
      fprintf('failed\n');
   end
  save(filename, 'const','modelopt','obst','occupancy','paramlist', 'tracer','tracer_cen_rec_nomod')
  fprintf('Finished file %d: %s\n', ii, filename);
end