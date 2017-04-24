% concatAveGrids()
% concatinates all files aveGrid* files in a directory. Assumes
% that they are similarly named, just with different times
function concatAveGrids(path2files,trID)
if nargin == 1
  trID = '';
end
% get files
allfiles = dir([path2files '*.mat']);
% loop over
for ii = 1:length( allfiles ) / 2
  % load
  counter = 2 * (ii - 1) + 1;
  file1 = allfiles(counter).name;
  s = load( [path2files file1]);
  ave1 = s.aveGrid;
  file2 =  allfiles(counter+1).name;
  s = load( [path2files file2]);
  ave2 = s.aveGrid;
  % determine which is short or long
  if ave1.time(end) > ave2.time(end)
    aveShort = ave2;
    aveLong = ave1;
  else
    aveShort = ave1;
    aveLong = ave2;
  end
  % make sure they match
  if aveShort.be ~= aveLong.be || abs( aveShort.ffo - aveLong.ffo) > 1e-12 || aveShort.bDiff ~= aveLong.bDiff
    error('files do not match')
  end
  % name stuff
  tempId = strfind( file2, 'ng96');
  nameStrt = file2(1:tempId+3);
  tempId = strfind( file2, [ trID '.mat' ] );
  nameEnd = file2(tempId:end);
  saveName = [ nameStrt '_t' num2str( aveShort.time(end) + aveShort.time(1) )...
    '_t' num2str( aveLong.time(end) + aveLong.time(1) ) '_concat_' nameEnd];
  % concat grids
  ind = aveShort.time < aveLong.time(1);
  aveGrid.ffo = aveLong.ffo;
  aveGrid.be = aveLong.be;
  aveGrid.bDiff = aveLong.bDiff;
  aveGrid.so = aveLong.so;
  aveGrid.obstExclude = aveShort.obstExclude;
  aveGrid.gridConfigs = aveLong.gridConfigs;
  aveGrid.time = [aveShort.time(ind); aveLong.time];
  aveGrid.msdW = [aveShort.msdW(ind); aveLong.msdW];
  aveGrid.stdW = [aveShort.stdW(ind); aveLong.stdW];
  aveGrid.sigW = [aveShort.sigW(ind); aveLong.sigW];
  aveGrid.msdUw = [aveShort.msdUw(ind); aveLong.msdUw];
  aveGrid.stdUw = [aveShort.stdUw(ind); aveLong.stdUw];
  aveGrid.sigUw = [aveShort.sigUw(ind); aveLong.sigUw];
  aveGrid.nPts = [aveShort.nPts(ind); aveLong.nPts];
  % save
  save( saveName, 'aveGrid' );
end
% move 'em
movefile( 'aveGrid_msd_*', path2files );
