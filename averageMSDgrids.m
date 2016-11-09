ffo = [0.05:0.05:0.45];
bind = [Inf];
bBar = Inf;
Id = 1;


for hh = 1:length(bind)
  
  bindTemp = bind(hh);
  
if bBar == 0
 parentpath = '/home/mws/McHydro/msdfiles/pando/saxtonParams/hopbnd0/';
elseif isinf( bBar )
  parentpath = '/home/mws/McHydro/msdfiles/pando/saxtonParams/hopbndInf/';
end
fullpath = [parentpath 'be' num2str(bindTemp ) '/'];
if isinf(bind)
  parentpath = '/home/mws/McHydro/msdfiles/pando/saxtonParams/nobind/';
  fullpath = [parentpath 'OTE1' '/'];
end


% load first out here

for ii = 1:length(ffo)
  ffoTemp = ffo(ii);
  fileId = [ 'msd_unBbar0_Bbar' num2str(bBar) ...
    '_bind' num2str(bindTemp ) '_fo' num2str(ffoTemp, '%.2f') '*'];
  files = dir( [fullpath fileId] );
  numGrids = length(files);
  
  load( [ fullpath files(ii).name ] );
  msdAve = msd(:,1);
  timeAve = dtime;
  errorAve = msd(:,2) ./ sqrt( msd(:,3) );
  
  for jj = 2:numGrids
    load( [fullpath files(jj).name] );
    msdAve =  msdAve + msd(:,1);
    timeAve = timeAve + dtime;
    errorAve = errorAve + msd(:,2) ./ sqrt( msd(:,3) );
  end
  
  msdAve = msdAve ./ numGrids;
  timeAve = timeAve ./ numGrids;

  % Save
  aveGrid.ffo = ffoTemp;
  aveGrid.be  = bindTemp ;
  aveGrid.bBar = Inf;
  aveGrid.msd = msdAve;
  aveGrid.stdev = errorAve;
  aveGrid.time = timeAve;
  aveGrid.gridConfigs = numGrids;

  savename = [ 'aveGrid_' fileId(1:end-1) '.mat' ];

  save(savename, 'aveGrid');
  movefile(savename, 'gridAveMSDdata/');
end

end

