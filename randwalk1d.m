% Just to test a 1D random walk

Np = 2000;
Nt = 100;
TotPoints = Np * Nt;

Xrec = zeros(Np, Nt );

Xold = zeros(Np,1);
Xnew = zeros(Np,1);
steps = [-1; 1];
time = 1:Nt;

for t = 1:Nt 

  stepVec = randi( 2, Np, 1);
  Xnew( stepVec == 1 ) = Xold( stepVec == 1 ) + steps(1);
  Xnew( stepVec == 2 ) = Xold( stepVec == 2 ) + steps(2);
 
  Xrec(:,t) = Xnew;

  Xold = Xnew;

end

%%
% Average stuff

aveX = mean( Xrec, 1  );
aveX2 = mean( Xrec .^ 2, 1);
aveX4 = mean( Xrec .^ 4 , 1);


%% Time slice

deltaT = 10;

indexstart    = 1:(Nt - deltaT);
indexend      = indexstart + deltaT;
numTimeSlices = length( indexstart );

x_deltaT = Xrec(:,indexend) - Xrec(:,indexstart);

x2_deltaT = x_deltaT .^ 2;
x4_deltaT = x_deltaT .^ 4;

% Averages
xAll   = x_deltaT(:);
xAveP  = mean( x_deltaT , 1 );
xAveT  = mean( x_deltaT , 2 );
xAve   = mean(xAll);
xStd   = std(xAll);
xStd2   = xStd .^ 2;

x2All   = x2_deltaT(:);
x2AveP  = mean( x2_deltaT , 1 );
x2AveT  = mean( x2_deltaT , 2 );
x2Ave   = mean(x2All);
x2Std   = std(x2All);
x2Std2  = x2Std .^ 2;

x4All   = x4_deltaT(:);
x4AveP  = mean( x4_deltaT , 1 );
x4AveT  = mean( x4_deltaT , 2 );
x4Ave   = mean(x4All);
x4Std   = std(x4All);
x4Std2  = x4Std .^ 2;

DisplacementInfo.xTh     = 0;
DisplacementInfo.xMs     = xAve;
DisplacementInfo.xSigTh  = sqrt(deltaT);
DisplacementInfo.xSigMs  = xStd;

DisplacementInfo.x2Th     = deltaT;
DisplacementInfo.x2Ms     = x2Ave;
DisplacementInfo.x2SigTh  = sqrt( 2 * deltaT * ( deltaT-1 ) );
DisplacementInfo.x2SigMs  = x2Std;

DisplacementInfo.x4Th     = 3 * deltaT ^ 2 - 2* deltaT;
DisplacementInfo.x4Ms     = x4Ave;

disp(DisplacementInfo)


