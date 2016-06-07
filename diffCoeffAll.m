% Wrapper for diffCoeffCalc that analyzes all the files in the msdfiles folder.
% All these files need the same grid and trials. The parameters from the files
% should form a grid ( # bind energy) X ( # ffo )
clear
clc
close all

DiffSaveId = 'Diff1';

cd ~/McHydro/
% Add paths
addpath('~/McHydro/src')
addpath('~/McHydro/msdfiles')

fprintf('Startng diffCoeffAll. Analyzing all files in ./msdfiles \n');
% diffcoeffCal inputs
timestrMult = 10;
plotflag    = 0;

% Output directory
if ~exist('figs','dir'); mkdir('figs'); end;
if ~exist('diffcalc','dir'); mkdir('diffcalc'); end;

% Grab all the files in the msd folder
msdLall = filelist( '.mat','./msdfiles');
totFiles  = length(msdLall);

% Find the number of parameter configurations
% Get trial information
tRunIdtfy   = msdLall{1}( strfind( msdLall{1}, '_t' ) : end );

% Find all cell indices that have the same trial and run identifier 
% strfind goes through all cells and looks for the str while cellfunc
% applies 'isempty' to all strings;
uniquePind = find(~cellfun('isempty', strfind( msdLall, tRunIdtfy ) ));
msdLUnParam = msdLall(uniquePind);  % list of unique parameter files
numUnqParams = length(msdLUnParam); % number of unique parameter combinations

% Calculate the number of trails
numTrials = totFiles / numUnqParams;


if floor(numTrials) ~= numTrials; 
  error('Varying trial number for parameter config');
end;

fprintf('%d total files. %d parameter configs. %d trials/config\n',...
  totFiles, numUnqParams, numTrials);

% Allocate memory for everything
% m(:,1) : be; m(:,2) = ff; m(:,3) = D m(:,4) = sig D
BindFFDiff = zeros( numUnqParams ,  4); 

% cd into directory with msdfiles--- that's where diffcoeffCalc needs to be run
cd ./msdfiles

 for ii = 1:numUnqParams

    % Grab file and load it
    filename = msdLUnParam{ii};
    load( filename );
    if exist('paramlist','var')
      ffo  = floor( paramlist.ffo * 1e10 ) / 1e10;
      bindEn  = floor( paramlist.be * 1e10 ) / 1e10;
      clear paramlist % Just in case
    elseif exist('paramvec','var' )
      ffo = paramvec(1);
      bindEn = paramvec(4);
      clear paramvec % Just in case
    else
      error('I cannot find any parameters');
    end
    
    if isinf( bindEn )
      timestart = 0 ;
    else
      timestart = timestrMult * max( exp( bindEn ) , exp(-bindEn) );
    end
    
    % Run diffcoeffcalc
    [Dout] = diffCoeffCalc( filename, timestart, plotflag );

    % Display it
    disp(Dout);

    % Store it in mat
    BindFFDiff(ii,1) = bindEn;
    BindFFDiff(ii,2) = ffo;
    BindFFDiff(ii,3) = Dout.Dfit;
    BindFFDiff(ii,4) = Dout.DsigFit;

 end

% Move all figs to ~/McHydro/figs
if plotflag; movefile('*.fig', '~/McHydro/figs'); end;
cd ~/McHydro/

% Rearrang things into a more friendly matrix
% Find the num_ber of binding energies
beVec = uniquetol( BindFFDiff(:,1), 1e-9 );
num_be = length(beVec);

% Find the num_ber of filling fractions
ffoVec = uniquetol( BindFFDiff(:,2), 1e-9 );
num_ffo = length(ffoVec);

% Diffusion Mat
DiffMat    = zeros( length(beVec), length(ffoVec) );
DiffMatSig = zeros( length(beVec), length(ffoVec) );

for ii = 1:num_be
  for jj = 1:num_ffo
    % Use conditional statements to find row with given BE and FF
    row = (ii-1) * num_ffo + jj; 
    DiffMat(ii,jj) = BindFFDiff( row, 3 );
    DiffMatSig(ii,jj) = BindFFDiff( row, 4 );
  end
end

% Plot it
% All on one
figure()
hold all
for ii = 1:num_be
  errorbar( ffoVec, DiffMat(ii,: ), DiffMatSig(ii,: ) )
end
xlabel('\nu obstacles'); ylabel('D')

legcell = cell( num_be, 1 );

for i = 1:num_be
  legcell{i} = ['be = ' num2str( beVec(i) ) ];
end
legend( legcell,'location', 'best' );

%Color bar
figure()
imagesc( ffoVec, beVec, DiffMat );
colorbar;
title('Diffusion Coeff')
xlabel('\nu obstacles'); ylabel('binding energy')
% Save the Diffusion Coeff
DiffSaveName = [ DiffSaveId 'be' num2str(num_be)...
  'ffo' num2str(num_ffo) '.mat' ];
save( DiffSaveName, 'DiffMat', 'beVec','ffoVec');
movefile(DiffSaveName, '~/McHydro/diffcalc');

fprintf('Finished run\n');

