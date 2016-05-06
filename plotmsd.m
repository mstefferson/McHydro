% just a test to fit 
load('./msdfiles/msd_bar0_bind0_fo0.1_ft0.1_so1_st1_oe1_ng100_nt1000_nrec1000_t1.3.mat')
load('./msdfiles/msd_bar0_bind0_fo0_ft0.1_so1_st1_oe1_ng100_nt10000_nrec10000_t4.1.mat')
%%
tPnts = length(dtime);
tInd  = 2:round(tPnts);
% Calculate standard error bars. Skip first point because SE is zero
errors  = ( msd(tInd,2) ./ sqrt( msd(tInd,3) ) ) ; % Column vector 

% Specify options like we want to take error bars into account
% w_i = 1 / sigma_i ^2. 
w = 1 ./ errors .^ 2;

fo = fitoptions( 'weights', w);

% Specify fitting type. I believe this can be as general
% as you want. Need to look into. For now, choose a
% polynomial y = p1 x + p2. 
ft = fittype( 'poly1' );


% fitobject: summary of everything and what you plot. fields are the 
% fit parameters. Confidence interval is .95
% gof: goodness of fit object
% output: info from the fitting algorithm
[fitobject,gof,output] = fit( dtime(tInd), msd(tInd,1), ft, fo );
Diff = fitobject.p1;
Shift = fitobject.p2;

% % Change confidence interval. This isn't used, just noting here
ci = confint(fitobject,0.68);
Dave = ( ci(1,1) + ci(2,1) ) / 2;
Dsig = ci(2,1) - Dave;

% Polyfits: Note- polyfit assumes all error bars are the same
% Compare to polyfit of average
p = polyfit( dtime(tInd), msd(tInd,1), 1 );
pwZ = polyfit( dtime, msd(:,1), 1 );
% Compare to polyfit of everything

% Plot everything
figure()
plot( dtime, msd(:,1),'o' );
hold all
plot(dtime, Diff * dtime + Shift, '--')
plot(dtime, p(1) * dtime + p(2), '--')
xlabel('t');
ylabel('r^2');
title('MSD')
legend('data','ls w/ errors','polyfit','location','best')

fprintf('D   = %.2e\n',Diff);
fprintf('D (ci = 0.68) = %.4e +/- %.4e\n', Dave, Dsig);

fprintf('Shift = %.2e\n',Shift);

fprintf('No error bars: D = %.2e\n',p(1) );
fprintf('No error bars: Shift = %.2e\n',p(2) );

figure()
plot( dtime,  msd(:,2) )
xlabel('N = steps');
ylabel('\sigma_N');

figure()
errorbar( dtime, msd(:,2), ( msd(:,2) ./ sqrt( msd(:,3) ) ) ,'-' );
xlabel('t');
ylabel('r^2');
title('MSD')



%% See if diffusion is anomolous 

figure()
plot( log10( dtime(tInd) ), log10( msd(tInd, 1)./ dtime(tInd) ) ) 
xlabel('log(t)'); ylabel('log( r^2 / t )');
title(' log plots testing anomalous diffusion')

figure()
loglog( dtime(tInd) , msd(tInd, 1) ./ dtime(tInd) ) 
xlabel('t'); ylabel('r^2 / t ');
title(' log plots testing anomalous diffusion')


figure()
plot( log10( dtime(tInd) ) , log10( msd(tInd, 1) ) ) 
xlabel('log(t)'); ylabel('log( r^2 )');
title(' log plots testing anomalous diffusion')

figure()
loglog( dtime(tInd) , msd(tInd, 1) ) 
xlabel('t'); ylabel('r^2');
title(' log plots testing anomalous diffusion')








