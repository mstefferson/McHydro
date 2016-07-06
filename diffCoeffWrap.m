% Wrapper for diffcoeffcalc 
% [DiffMat] = diffCoeffWrap(bindVec, ffoVec, timestrMult, plotflag)

% inputs for diffcoeffcalc. Allow user to just put in
% desired parameters to analyze. Must be in the directory with in
% files for this to work

% timestrmul: timestart = timestrMult * exp( +/- be )
% plotflag: plot flag on or off
% alphaFit: Confindence inverval of fit

function [DiffMat] = diffCoeffWrap( ...
  bindVec, ffoVec, timestrMult, plotflag, verbose)

if nargin == 2
  timestrMult = 1; 
  plotflag = 0;
  verbose = 0;
end
if nargin == 3 
  plotflag = 0;
  verbose = 0;
end
if nargin == 4 
  verbose = 0;
end

% Vector lengths
num_be = length( bindVec );
num_ffo = length( ffoVec );

fprintf('num_be = %d num_ff = %d\n',num_be,num_ffo);

% Add paths
addpath('~/McHydro/src')

% cd into msd files
cd ./msdfiles

% Currently, barrier height is zero
barEn = 0;

% Output directory
if ~exist('figs','dir'); mkdir('figs'); end;

% Diffusion Mat
DiffMat   = zeros( length(bindVec), length( ffoVec ) );
DiffMatSig = zeros( length(bindVec), length( ffoVec ) );

for ii = 1:num_be
   for jj = 1:num_ffo
      
      bindEn = bindVec(ii);
      ffo = ffoVec(jj);

      timestart = timestrMult * max( exp( bindEn ) , exp(-bindEn) );
      msd2analyze = ['msd_bar' num2str(barEn)...
        '_bind' num2str(bindEn) '_fo' num2str(ffo) ] ;
      % Grab file and load it
      msdlist     = filelist( msd2analyze, pwd); 
      filename = msdlist{1};
      load(filename);
      
      % Run diffcoeffcalc
      [Dout] = diffCoeffCalc( filename, timestart, plotflag, verbose );

      % Display it
      disp(Dout);

      % Store it in mat
      DiffMat(ii,jj) = Dout.Dfit;
      DiffMatSig(ii,jj) = Dout.DsigFit;

      if plotflag
        movefile('*.fig', './figs')
      end
      
   end
end

cd ../

% Plot if
% All on one
figure()
hold all
for ii = 1:num_be
  errorbar( ffoVec, DiffMat(ii,: ), DiffMatSig(ii,: ) )
end
xlabel('\nu obstacles'); ylabel('D')

legcell = cell( num_be, 1 );

for i = 1:num_be
  legcell{i} = ['be = ' num2str( bindVec(i) ) ];
end
legend( legcell,'location', 'best' );

% color map
figure()
imagesc( ffoVec, bindVec, DiffMat );
colorbar;
title('Diffusion Coeff')
xlabel('\nu obstacles'); ylabel('binding energy')
