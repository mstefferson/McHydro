% just a test to fit 
load('./msdfiles/msd_bar0_bind0_fo0.1_ft0.1_so1_st1_oe1_ng100_nt1000_nrec1000_t1.3.mat')

%%
tPnts = length(dtime);
tInd  = 2:tPnts;
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
% ci = confint(fitobjec,0.68);

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

legend('data','ls w/ errors','polyfit','location','best')

fprintf('D = %.2e\n',Diff);
fprintf('Shift = %.2e\n',Shift);

fprintf('No error bars: D = %.2e\n',p(1) );
fprintf('No error bars: Shift = %.2e\n',p(2) );






