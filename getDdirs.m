path2dirs = '~/McHydro/msdfiles/pando/saxtonParams/nobind/';
beKey = 'OTE*';
addpath(pwd);
filename = 'noBind';
filename = [filename '.mat'];
dirs2analyze = dir( [path2dirs beKey] );

cd(path2dirs);
for ii = 1:length(dirs2analyze);
  % cd in for diffCoeffAll to work
  cd( dirs2analyze(ii).name );
  % run diffCoeffAll
  [diffTemp, sigTemp, p1Temp, p2Temp] = ...
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
  [rT, cT] = size( pVary );
  
  if rT > rM;
    pVary = pVary';
  end

  masterD(ii).pConst = pConst;
  masterD(ii).pVary = pVary;
  masterD(ii).D = diffTemp;
  masterD(ii).sig = sigTemp;
  save(filename, 'masterD');
  cd ../

end

cd('~/McHydro');
save(filename, 'masterD');
