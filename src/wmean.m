 function [wAve, wSig] = wmean(x,w)

 if length(x) ~= length(w)
   error( 'vectors must be the same length' );
 end

 sumW = sum(w);
 wAve = sum( w .* x ) / sumW; 
 wSig = sum( w .* (x-wAve) .^ 2 ) / sumW;

 end
