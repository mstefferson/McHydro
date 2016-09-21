 function [wAve, wSig] = wmean(x,sig)

 w = 1 ./ sig.^2;
 if length(x) ~= length(w)
   error( 'vectors must be the same length' );
 end

 sumW = sum(w);
 wAve = sum( w .* x ) / sumW; 
 wSig = sum( w .* (x-wAve) .^ 2 ) / sumW;

 end
