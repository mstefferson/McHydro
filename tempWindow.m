%%
Nt = 1000;
NwDesired = 100;
n  = 999;


NwMax = ceil( Nt / n ) -1; % minus cause ind start at 1
nStartPoss = 1:n: NwMax * n ;

randInd = randperm( NwMax, min(NwMax,NwDesired) );
nStartSelect = nStartPoss(randInd);
nEndSelect = nStartSelect + n;
