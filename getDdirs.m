% detDdirs( path2dirs, dirs2analyze, filename )
%
% Function loops over directorys of unique binding energies and puts all the
% output diffusion info into a structure. 
% path2dirs: the location of the dirs you want to loop over
% dirs2analyze: use matlabs 'dir' to generate the names of the dirs you want to
% analyze
% filename: save the data to this mname

function masterD = getDdirs( path2dirs, dirs2analyze, filename )

currentDir = pwd;
addpath( currentDir );
filename = [filename '.mat'];
cd(path2dirs);
for ii = 1:length(dirs2analyze);
  % cd in for diffCoeffAll to work
  cd( dirs2analyze(ii).name );
  % run diffCoeffAll
  [diffTemp, sigTemp, p1Temp, p2Temp, numTrials] = ...
    diffCoeffAll( 1, 0, 0, 0, 0, '', [0 1 0] );

  if length(p1Temp) == 1
    pConst = p1Temp;
    pVary = p2Temp;
  else
    pConst = p2Temp;
    pVary = p1Temp;
  end
  
  % fix size
  [rM, cM] = size( diffTemp );
  [rT, ~] = size( pVary );
  
  if rT > rM;
    pVary = pVary';
  end

  masterD(ii).pConst = pConst;
  masterD(ii).pVary = pVary;
  masterD(ii).D = diffTemp;
  masterD(ii).sig = sigTemp;
  masterD(ii).numConfigs = numTrials;
  save(filename, 'masterD');
  movefile( filename, currentDir );
  cd ../

end
% Return home
cd('~/McHydro');
% sort D struct and resave

v = zeros( length( masterD ), 1);
for ii = 1:length( v)
  v(ii) = masterD(ii).pConst;
end
[~, sortInd] = sort( v );
masterD(:) = masterD( sortInd );
save(filename, 'masterD');
