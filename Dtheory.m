G = 1000;
c = [0.1:0.1:0.9];
gamma = 10000;
% alpha = 1 - 2/pi;
% alpha = 0.5;
%  alpha = 0.2820;
% alpha = 0.43;

Pbe = 1 - min( exp(-G) ,1 ); % Probability a hop empty to obst will be blocked
Pbo = 1 - min( exp(G) ,1);   % Probability a hop obst to empty will be blocked

ffte = (1 - c) ./ ( (1-c) + c .* exp(-G) );
ffto = ( c * exp(-G) ) ./ ( (1-c) + c .* exp(-G) );

DchInf = @(x,a) (1-x) .* a .* ( abs( x - (1-x)*(1-a) / (2*a) ) -...
  ( x - (1-x)*(1-a) / (2*a) ) ) ./ ( (1-x)*(1-a) );

DchGam = @(x,gamma,a) (1-x) .* a .* ( abs( x - (1-x)*(1-a) / (2*a) ) -...
  ( x - (1-x)*(1-a) / (2*a) ) ) ./ ( (1-x)*(1-a) );

D = ffte .* DchInf( Pbe .* c,alpha) + ffto .* DchInf ( Pbo .* (1-c),alpha );
% Dgam = ffte .* DchGam( Pbe .* c, gamma ) + ffto .* DchGam( Pbo .* (1-c),gamma );

% D2 = ffte .* DchInf( c ) + ffto .* DchInf ( (1-c) );

plot( c, D,'--',c,Dgam,'x' )
Ax = gca;
Ax.YLim = [0 1.2];
Ax.XLim = [0 1];
ylabel = 'D';
xlabel = 'ff obstacles';


%% Sanity check %%
c = linspace(0,1,100);
% alpha = 1 - 2/pi;
%alpha = 0.5;
% alpha = 0.2820;
alpha = 0.4; %Fits inf data
alpha = 0.42; % Gives correct perc

gamma = 10000;


% figure
plot(c,DchGam(c,gamma,alpha),c,DchInf(c,alpha));
