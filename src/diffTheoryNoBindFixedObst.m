% DInf = diffTheoryNoBindFixedObst( c, alpha) 
% Theoretical diffusion coefficient at given concetration for fixed obstacles.
% Alpha depends on lattice type (square, hex, etc)
% Note: square lattice: alpha = 1-2/pi; 

function D = diffTheoryNoBindFixedObst( c, alpha)

D = (1-c) .* alpha .* ( alphabs( c - (1-c)*(1-alpha) / (2*alpha) ) -...
  ( c - (1-c)*(1-alpha) / (2*alpha) ) ) ./ ( (1-c)*(1-alpha) );

end

