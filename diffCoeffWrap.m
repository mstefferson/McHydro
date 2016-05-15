% Wrapper for diffcoeffcalc

% inputs for diffcoeffcalc. Allow user to just put in
% desired parameters to analyze. Must be in the directory with in
% files for this to work

% timestrmul: timestart = timestrMult * exp( +/- be )
% plotflag: plot flag on or off
% alphaFit: Confindence inverval of fit

function [DiffMat] = diffCoeffWrap( ...
  bindVec, ffoVec, timestrMult, plotflag, alphaFit )

% Add paths
addpath('~/McHydro/src')
addpath('~/McHydro/msdfiles')

% Currently, barrier height is zero
barEn = 0;

% Output directory
if ~exist('figs','dir'); mkdir('figs'); end;

% Diffusion Mat
DiffMat = zeros( length(bindVec), length( ffoVec ) );

for ii = 1:length(bindVec)
   for jj = 1:length(ffoVec)
      
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
      [Dout] = diffCoeffCalc( filename, timestart, plotflag, alphaFit );

      % Display it
      disp('Dout');

      % Store it in mat
      DiffMat(ii,jj) = Dout.Dfit;

      movefile('*.fig', './figs')
      
   end
end

