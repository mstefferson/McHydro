%%
% files = dir('msd_unBbar0_Bbar0_bind10_fo0.50_ft0.00_so1_st1_oe1_ng256_nt10000_nrec1000_t05.*');
% files = dir('msd_unBbar0_Bbar0_bind10_fo0.50_ft0.00_so1_st1_oe1_ng256_nt100000_nrec10000_t05.*');
files = dir('msd_unBbar0_Bbar0_bind3_fo0.65_ft0.00_so1_st1_oe1_ng256_nt100000_nrec10000_t05.*');
figure()
hold on
for ii = 1:length(files)
  load( files(ii).name )
  files(ii).name
  plot( msd(:,1) )
%   keyboard
end

