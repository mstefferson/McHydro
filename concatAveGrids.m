allfiles = dir('*.mat');

% all bBar = 0 
fileID = 'aveGrid_msd_unBbar0_Bbar0*';

bBar0files = dir( fileID );

for ii = 1:length( allfiles ) / 2;
  % load
  counter = 2 * (ii - 1) + 1;
  fileShort = allfiles(counter).name;
  s = load( fileShort );
  aveShort = s.aveGrid;
  fileLong =  allfiles(counter+1).name;
  s = load( fileLong );
  aveLong = s.aveGrid;

  if aveShort.be ~= aveLong.be || abs( aveShort.ffo - aveLong.ffo) > 1e-12 || aveShort.bBar ~= aveLong.bBar
    error('files do not match')
  end
  
  % name stuff
  tempId = strfind( fileLong, 'ng96');
  nameStrt = fileLong(1:tempId+3);
  tempId = strfind( fileLong, 't600.mat');
  nameEnd = fileLong(tempId:end);
  saveName = [ nameStrt '_t' num2str( aveShort.time(end) + aveShort.time(1) )...
    '_t' num2str( aveLong.time(end) + aveLong.time(1) ) '_concat_' nameEnd];
  
  % concat grids
  ind = aveShort.time < aveLong.time(1);
  aveGrid.ffo = aveLong.ffo;
  aveGrid.be = aveLong.be;
  aveGrid.bBar = aveLong.bBar;
  aveGrid.gridConfigs = aveLong.gridConfigs;
  aveGrid.time = [aveShort.time(ind); aveLong.time];
  aveGrid.msdW = [aveShort.msdW(ind); aveLong.msdW];
  aveGrid.stdW = [aveShort.stdW(ind); aveLong.stdW];
  aveGrid.sigW = [aveShort.sigW(ind); aveLong.sigW];
  aveGrid.msdUw = [aveShort.msdUw(ind); aveLong.msdUw];
  aveGrid.stdUw = [aveShort.stdUw(ind); aveLong.stdUw];
  aveGrid.sigUw = [aveShort.sigUw(ind); aveLong.sigUw];
  aveGrid.nPts = [aveShort.nPts(ind); aveLong.nPts];

  save( saveName, 'aveGrid' );
end

  
  
  
  
