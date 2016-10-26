G = 1;
c = [0.:0.1:1];
% gamma = 10000;
alpha = 1-2/pi; %square lattice
% alpha = 0.5;
%  alpha = 0.2820;
% alpha = 0.43;

Pbe2o = 1 - min( exp(-G) ,1 ); % Probability a hop empty to obst will be blocked
Pbo2e = 1 - min( exp(G) ,1);   % Probability a hop obst to empty will be blocked

ffte = (1 - c) ./ ( (1-c) + c .* exp(-G) );
ffto = ( c * exp(-G) ) ./ ( (1-c) + c .* exp(-G) );

DInf = @(x,a) (1-x) .* a .* ( abs( x - (1-x)*(1-a) / (2*a) ) -...
  ( x - (1-x)*(1-a) / (2*a) ) ) ./ ( (1-x)*(1-a) );

fInf = @(x,a) a .* ( abs( x - (1-x)*(1-a) / (2*a) ) -...
  ( x - (1-x)*(1-a) / (2*a) ) ) ./ ( (1-x)*(1-a) );

DGam = @(x,gamma,a) (1-x) .* a .* ( abs( x - (1-x)*(1-a) / (2*a) ) -...
  ( x - (1-x)*(1-a) / (2*a) ) ) ./ ( (1-x)*(1-a) );

% fGam = @(x,gamma,a) a .* ( abs( x - (1-x)*(1-a) / (2*a) ) -...
%   ( x - (1-x)*(1-a) / (2*a) ) ) ./ ( (1-x)*(1-a) );

Dfnc = ffte .* DInf( Pbe2o .* c,alpha) + ffto .* DInf( Pbo2e .* (1-c),alpha );
% Dgam = ffte .* DchGam( Pbe .* c, gamma ) + ffto .* DchGam( Pbo .* (1-c),gamma );

% D2 = ffte .* DchInf( c ) + ffto .* DchInf ( (1-c) );

figure()
plot( c, Dfnc,'--' )
Ax = gca;
Ax.YLim = [0 1.2];
Ax.XLim = [0 1];

% Interpolation method


ffte = (1 - c) ./ ( (1-c) + c .* exp(-G) );
ffto = ( c * exp(-G) ) ./ ( (1-c) + c .* exp(-G) );

Pbe2o = 1 - min( exp(-G) ,1 ); % Probability a hop empty to obst will be blocked
Pbo2e = 1 - min( exp(G) ,1);   % Probability a hop obst to empty will be blocked

dinf = DbeInf';
xinf = p2Inf;
extraPnts = [0.65:0.05:0.95];
extraZeros = zeros( length(extraPnts), 1 );
xinf = [xinf; extraPnts'];
dinf = [dinf; extraZeros];
Demp = interp1( xinf, dinf, Pbe2o .* c );
Dobs = interp1( xinf, dinf, Pbo2e .* (1-c) );

Dinf = interp1( xinf, dinf, c );
fact = 1;
ffteInpt = ffte * fact;
Dinterp =  ffteInpt .* Demp + (1-ffteInpt) .* Dobs;
% Dinterp = ffte .* Demp;
% Dinterp = ffto .* Dobs;
% figure()
%%
figure()
plot(xinf, dinf)
hold on
scatter(c,Dinf)
% plot( xinf, dinf);
%%

hold on
scatter( c, Dinterp,'o');
% scatter( c, Dfnc,'x');



%% Sanity check %%
c = linspace(0,1,100);
% alpha = 1 - 2/pi;
%alpha = 0.5;
% alpha = 0.2820;
alpha = 0.4; %Fits inf data
alpha = 0.42; % Gives correct perc

gamma = 10000;


% figure
plot(c,DGam(c,gamma,alpha),c,fInf(c,alpha));
