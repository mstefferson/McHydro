function [tracer,obst] = setupAndAnimate(paramvec,const,modelopt,obstParamAll, filename)
% initialize everythin
% Parameters from pvec
totParams = 3;
if length(paramvec) ~= totParams
  error('diffusion_model: incorrect parameter vector length');
else
  num_tracer = paramvec(1);
  tr_diff_unb = paramvec(2);
  obstInpt = obstParamAll{ paramvec(3) };
end

% Paramvec as a struct
paramlist.num_tracer = num_tracer; %filling frac tracer
paramlist.tr_diff_unb = tr_diff_unb; %unbound hop energy

% verbose
verbose = const.verbose;

% get number of obstacles
num_obst_types = length( obstInpt );

% Assign internal variables
n = const;
n.numSites = n.n_gridpoints .^ n.dim;
n.num_obst_types = num_obst_types;
n.num_obst = zeros( num_obst_types );

% set up grid
grid.sizeV = repmat( n.n_gridpoints, [1 n.dim] );
grid.dim = n.dim;
grid.totPnts = n.numSites;

% Records
if n.trPosRecNoModFlag || n.trPosRecModFlag ||  n.obsPosRecNoModFlag ||...
    n.obsPosRecModFlag ||  n.trStateRecFlag || n.trackOcc
  n.Rec = 1;
else
  n.Rec = 0;
end
jrectemp = 1;
jrec     = 1;
jchunk   = 1;

% Model options
animate=modelopt.animate;    %1 to show animation, 0 for no animation
tpause=modelopt.tpause;      %pause time in animation

%define box for plotting
if animate && n.dim == 2
  colorArray = colormap(['lines(' num2str(num_obst_types) ')']);
else
  colorArray = rand( num_obst_types, 3 );
end

% obstacle fields
if verbose
  fprintf('Placing obstacles\n');
  tFill = zeros( num_obst_types, 1);
end

% place some obstacles
[obst, obstInfo] =  buildObstMaster( obstInpt, tr_diff_unb, grid, colorArray );
% rough check for errors
for ii = 1:num_obst_types-1
  if any( ismember( obst{ii}.AllPts, obst{ii+1}.AllPts ) )
    error('differect obstacles are overlapping')
  end
end

% tracer fields
if verbose
  fprintf('Placing tracers\n');
  tic
end

% set-up tracers
tracer = TracerClass(  paramlist.num_tracer, obst, obstInfo.be, grid, ...
  modelopt.place_tracers_obst);
% Derived parameters and store
n.num_tracer = tracer.Num;
% animation
% init
ax = initAnimation(grid);
obstRectangle = cell( 1, num_obst_types );
tracerRectangle = struct;
% update positions
for ii = 1:num_obst_types
  for kObst=1:obst{ii}.Num
    obstRectangle{ii}=update_rectangle(obst{ii}.Centers,obstRectangle{ii},...
      kObst,obst{ii}.Length,n.n_gridpoints,...
      obst{ii}.Color,obst{ii}.Curvature);
  end
end
for kTracer=1:tracer.Num
  tracerRectangle=update_rectangle(tracer.Centers, tracerRectangle, ...
    kTracer,tracer.Length,n.n_gridpoints,...
    tracer.Color,tracer.Curvature);
end
