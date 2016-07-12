G = 2;
%c = linspace(0.1,0.9);
c = [0.1:0.1:0.9];
Pbe = 1 - min( exp(-G) ,1 );
Pbo = 1 - min( exp(G) ,1);

ffte = (1 - c) ./ ( (1-c) + c .* exp(-G) );
ffto = ( c * exp(-G) ) ./ ( (1-c) + c .* exp(-G) );

Dch = @(x) (1-x) .* alpha .* ( abs( x - (1-x)*(1-alpha) / (2*alpha) ) -...
  ( x - (1-x)*(1-alpha) / (2*alpha) ) ) ./ ( (1-x)*(1-alpha) );

D = ffte .* Dch( Pbe .* c ) + ffto .* Dch ( Pbo .* (1-c) );

plot( c, D )
Ax = gca;
Ax.YLim = [0 1.2];
Ax.XLim = [0 1];
ylabel = 'D';
xlabel = 'ff obstacles';


%%% Sanity check %%
alpha = 1 - 2/pi;
gamma = 10000;

f0 = (1-alpha) / ( 1 + (2*gamma-1) * alpha );
fcgamma = ( ( ( (1-gamma)*(1-c).*f0 + c ).^2 + 4*gamma*(1-c)  *f0 .^ 2 ) .^ (1/2) ...
  -( (1-gamma)*(1-c)*f0 +c ) ) ./ ...
  ( 2*gamma*(1-c)*f0 ); 
fcInf = alpha * ( abs( c - (1-c)*(1-alpha) / (2*alpha) ) -...
  ( c - (1-c)*(1-alpha) / (2*alpha) ) ) ./ ( (1-c)*(1-alpha) );

Dcgamma = (1-c) .* fcgamma;
DcInf = (1-c) .* fcInf;
