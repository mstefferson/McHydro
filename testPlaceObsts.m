%% 
ff = 0.3;
nG = 10;
lobst = 3;
% number of sites to fill
maxFilledObst = round( ff .* nG .^ 2 / lobst);
maxFilledSites = round( ff .* nG .^ 2 );
% all Sites
allSite = 1:nG^2;
% number of filled
numFilledSites = 0;
% do Initial fill
obstCenters = randperm( allSite, numFilledObst );
% Find coordinates
[i, j] = ind2sub( [nG nG], obstCenters );
:x



