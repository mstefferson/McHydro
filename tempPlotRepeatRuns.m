%%
files = dir('msd_unBbar0_Bbar0_bind0_fo0.05*');

figure()
hold on
for ii = 1:length(files)
  load( files(ii).name )
  files(ii).name
  plot( msd(:,1) )
  keyboard
end

