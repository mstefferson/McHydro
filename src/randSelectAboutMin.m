%%
% Returns random +/- i intervals about a minimum of a vector followed by
% increasing distance from min after one side has been reached.

function bins2Check = randSelectAboutMin (v,minInd)
bins = length(v);
vecInd = zeros(  1, bins );
steps = [-1 1];
for ii = 1:bins;

  randStep =  ii * steps( randperm( 2 , 1 ) );
  vecInd(ii) = randStep;
  
end
  
vecPerp = zeros( 1, 2 * bins );
vecPerp(1:2:2*bins) = vecInd;
vecPerp(2:2:2*bins) = -vecInd;
bins2Check = [minInd minInd+vecPerp];
bins2Check = bins2Check(bins2Check <= bins) ;
bins2Check = bins2Check(bins2Check > 0 );
  
end

