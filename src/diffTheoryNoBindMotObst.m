% DInf = diffTheoryNoBindMotObst( c, alpha, gamma) 
% Theoretical diffusion coefficient at given concetration for fixed obstacles.
% Alpha depends on lattice type (square, hex, etc)
% Note: square lattice: alpha = 1-2/pi; 

function D = diffTheoryNoBindMotObst( c, alpha, gamma)

D = 0;
fprintf( 'not written\n')
%D= @(x,gamma,a) (1-x) .* a .* ( abs( x - (1-x)*(1-a) / (2*a) ) -...
 % ( x - (1-x)*(1-a) / (2*a) ) ) ./ ( (1-x)*(1-a) );
end

