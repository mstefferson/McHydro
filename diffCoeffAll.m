% Wrapper for diffCoeffCalc that analyzes all the files in the msdfiles folder.
% All these files need the same grid and trials. The parameters from the files
% should form a grid ( # bind energy) X ( # ffo )
clear
clc
close all

cd ~/McHydro/
% Add paths
addpath('~/McHydro/src')
addpath('~/McHydro/msdfiles')

fprintf('Startng diffCoeffAll. Analyzing all files in ./msdfiles \n');
% diffcoeffCal inputs
timestrMult = 10;
alphaFit    = 0.68;
plotflag    = 1;

% Output directory
if ~exist('figs','dir'); mkdir('figs'); end;

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
BindFFDiff = zeros( numUnqParams ,  3); % m(:,1) : be; m(:,2) = ff; m(:,3) = D

% cd into directory with msdfiles--- that's where diffcoeffCalc needs to be run
cd ./msdfiles

 for ii = 1:numUnqParams

    % Grab file and load it
    filename = msdLUnParam{ii};
    load( filename );
    if exist('paramlist','var')
      ffo  = paramlist.ffo;
      bindEn  = paramlist.be;
    elseif exist('paramvec','var' )
      ffo = paramvec(1);
      bindEn = paramvec(4);
    else
      error('I cannot find any parameters');
    end
    
    if isinf( bindEn )
      timestart = 0 
    else
      timestart = timestrMult * max( exp( bindEn ) , exp(-bindEn) );
    end
    
    % Run diffcoeffcalc
    [Dout] = diffCoeffCalc( filename, timestart, plotflag, alphaFit );

    % Display it
    disp(Dout);

    % Store it in mat
    BindFFDiff(ii,1) = bindEn;
    BindFFDiff(ii,2) = ffo;
    BindFFDiff(ii,3) = Dout.Dfit;

 end

% Move all figs to ~/McHydro/figs
if plotflag; movefile('*.fig', '~/McHydro/figs'); end;
cd ~/McHydro/

% Rearrang things into a more friendly matrix
% Find the number of binding energies
beVec = unique( BindFFDiff(:,1) );

% Find the number of filling fractions
ffoVec = unique( BindFFDiff(:,2) );

% Diffusion Mat
DiffMat = zeros( length(beVec), length(ffoVec) );

for ii = 1:length(beVec)
  for jj = 1:length(ffoVec)
    % Use conditional statements to find row with given BE and FF
    row =  BindFFDiff(:,1) == beVec(ii) & BindFFDiff(:,2) == ffoVec(jj) ; 
    DiffMat(ii,jj) = BindFFDiff( row, 3 );
  end
end

% Display the Diffusion Coeff

fprintf('Finished run\n');

