% diffwrapper

% Wrapper for grabmultmsdruns
addpath('~/McHydro/src')
if ~exist('figs','dir'); mkdir('figs'); end;
alphaFit = 0.68;
trialind = 1;
runstart = 1;


bindenVec  = -5;

ffoVec     = [0.1:0.1:0.9];

for ii = 1:length(bindenVec)
   for jj = 1:length(ffoVec)
      
      binden = bindenVec(ii);
      ffo = ffoVec(jj);
      grabmultmsdruns
      movefile('*.fig', './figs')
      
   end
end
   
   
