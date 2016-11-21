% short
load('/Users/mike/McHydro/tempConcatTest/aveGrid_msd_unBbar0_Bbar0_bind10_fo0.50_ng96_t10000_t05_concatTest.mat')

shortInd = 1:50:10^3;
time_short = aveGrid.time(shortInd);
msdW_short = aveGrid.msdW(shortInd);
sigW_short = aveGrid.sigW(shortInd);
msdUw_short = aveGrid.msdUw(shortInd);
sigUw_short = aveGrid.sigUw(shortInd);

% short
load('/Users/mike/McHydro/tempConcatTest/aveGrid_msd_unBbar0_Bbar0_bind10_fo0.50_ng96_t10000_t06_concatTest.mat')

shortInd = 1:50:10^3;
time_short2 = aveGrid.time(shortInd);
msdW_short2 = aveGrid.msdW(shortInd);
sigW_short2 = aveGrid.sigW(shortInd);
msdUw_short2 = aveGrid.msdUw(shortInd);
sigUw_short2 = aveGrid.sigUw(shortInd);
% mid
load('/Users/mike/McHydro/tempConcatTest/aveGrid_msd_unBbar0_Bbar0_bind10_fo0.50_ng96_t100000_t05_concatTest.mat')

midInd = 1:50:10^3;

time_mid = aveGrid.time( midInd );
msdW_mid = aveGrid.msdW( midInd );
sigW_mid = aveGrid.sigW( midInd );
msdUw_mid = aveGrid.msdUw( midInd );
sigUw_mid = aveGrid.sigUw( midInd );

% long
load('/Users/mike/McHydro/tempConcatTest/aveGrid_msd_unBbar0_Bbar0_bind10_fo0.50_ng96_t10000000_t05.mat')

longInd = 1:10;

time_long = aveGrid.time( longInd );
msdW_long = aveGrid.msdW( longInd );
sigW_long = aveGrid.sigW( longInd );
msdUw_long = aveGrid.msdUw( longInd );
sigUw_long = aveGrid.sigUw( longInd );

% plot
figure()
hold
plot( time_short, msdW_short )
plot( time_short, msdUw_short )

plot( time_short2, msdW_short2 )
plot( time_short2, msdUw_short2 )

legend( 'short W', 'short Uw', 'short 6 W', 'short 6 Uw', ...
  'location','best')

figure()
hold
errorbar( time_short, msdW_short, sigW_short )
errorbar( time_short, msdUw_short, sigUw_short)

errorbar( time_short2, msdW_short2, sigW_short2 )
errorbar( time_short2, msdUw_short2, sigUw_short2)

legend( 'short W', 'short Uw', 'short 6 W', 'short 6 Uw', ...
  'location','best')

figure()
hold
plot( log10( time_short ),log10( msdW_short ./ time_short ) )
plot( log10( time_short ), log10( msdUw_short ./ time_short ) )

plot( log10( time_short2 ),log10( msdW_short2 ./ time_short2 ) )
plot( log10( time_short2 ), log10( msdUw_short2 ./ time_short2 ) )

legend( 'short W', 'short Uw', 'short 6 W', 'short 6 Uw', ...
  'location','best')

figure()
hold
plot( time_short, msdW_short )
plot( time_short, msdUw_short )

plot( time_mid, msdW_mid )
plot( time_mid, msdUw_mid )

plot( time_long, msdW_long )
plot( time_long, msdUw_long )

legend( 'short W', 'short Uw', ...
  'mid W', 'mid Uw', 'long W', 'long Uw', 'location','best')

figure()
hold
errorbar( time_short, msdW_short, sigW_short )
errorbar( time_short, msdUw_short, sigUw_short)

errorbar( time_mid, msdW_mid, sigW_mid )
errorbar( time_mid, msdUw_mid, sigUw_mid )

errorbar( time_long, msdW_long, sigW_long)
errorbar( time_long, msdUw_long, sigUw_long )

legend( 'short W', 'short Uw', ...
  'mid W', 'mid Uw', 'long W', 'long Uw', 'location','best')

figure()
hold
plot( log10( time_short ), log10( msdW_short ./ time_short ) )
plot( log10( time_short ), log10( msdUw_short ./ time_short ) )

plot( log10( time_mid ), log10( msdW_mid ./ time_mid ) )
plot( log10( time_mid ), log10( msdUw_mid ./ time_mid ) )

plot( log10( time_long ), log10( msdW_long ./ time_long ) )
plot( log10( time_long ), log10( msdUw_long ./ time_long ) )

legend( 'short W', 'short Uw', ...
  'mid W', 'mid Uw', 'long W', 'long Uw', 'location','best')

