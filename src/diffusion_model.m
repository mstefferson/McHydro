function [tracer,obst] = diffusion_model(paramvec,const,modelopt,filename)
% DIFFUSION_MODEL run model of tracers diffusing through obstacles
%   inputs are:
%   pvec = parameter vector containing
%     growth speed (micron/min)
%   --also for ...
%   const = structure of constant parameters, must include
%     t_tot=total simulation ntimesteps,
%   modelopt = structure of model options, can include
%     wt=1 for wild-type model, causes length-dependent catastrophe
%   returns:
%   kc = structure of kinetochore trajectories and info
%   MDB 8/18/15 created
%   MDB 9/28/15 specialized to immobile obstacles, noninteracting tracers
%   so that moves can be done in parallel

% initialize everythin
% Parameters from pvec
totParams = 7;

if (length(paramvec)<totParams)
  error('diffusion_model: parameter vector too short');
elseif (length(paramvec)==totParams)
  num_tracer = paramvec{1};
  num_obst_types = paramvec{2};
  tr_diff_unb = paramvec{3};
  tr_diff_bnd = paramvec{4};
  ffrac_obst = paramvec{5};
  bind_energy = paramvec{6};
  size_obst = paramvec{7};
elseif (length(paramvec)>totParams)
  error('diffusion_model: parameter vector too long');
end

% Paramvec as a struct
paramlist.num_tracer = num_tracer; %filling frac tracer
paramlist.tr_diff_unb = tr_diff_unb; %unbound hop energy
paramlist.tr_diff_bnd = tr_diff_bnd ; % bound hop energy
paramlist.ffo = ffrac_obst; %filling frac obs
paramlist.be = bind_energy; % bind energy
paramlist.so = size_obst;

% verbose
verbose = const.verbose;
% Animation features
% Colors
colorArray = colormap(['lines(' num2str(num_obst_types) ')']);
obst_color = colorArray;
obst_curv=0.2; %curvature for animations
tracer_color=[0 1 1]; %cyan
tracer_curv=1; %curvature for animations

% Assign internal variables
n = const;
n.numSites = n.n_gridpoints .^ n.dim;
if n.dim == 2
  n.grid = [ n.n_gridpoints n.n_gridpoints ];
elseif n.dim == 3
  n.grid = [ n.n_gridpoints n.n_gridpoints n.n_gridpoints ];
else
  fprintf('Error!!! Cannot handle this dimension. Must be 2 or 3')
  error('Error!!! Cannot handle this dimension. Must be 2 or 3')
end

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
  figure()
end

% Square lattice definition
if n.dim == 2
  lattice.moves=[1 0; -1 0; 0 1; 0 -1];
elseif n.dim == 3
  lattice.moves=[1 0 0; -1 0 0; 0 1 0; 0 -1 0; 0 0 1; 0 0 -1];
else
  lattice.moves = 0;
end

% obstacle fields
if verbose
  fprintf('Placing obstacles\n');
  tic
end

% place some obstacles
filledObstSites = [];
% scramble the order. No favorites!!!
obstOrder = randperm( num_obst_types );
% rescale filling fractions if they are too high
fillFracScale = max(  1 / ( sum(paramlist.ffo) ), 1 );
% allocate a vector of actuall fffrac for placing tracers later
ffoAct = zeros( num_obst_types, 1 );
% First initialize the last obstacle for allocation
ind = obstOrder(end);
ffoWant = paramlist.ffo(ind) * fillFracScale;
obst{ind} = place_obstacles( ...
  ffoWant, paramlist.so(ind), ...
  n.grid, modelopt.obst_excl, filledObstSites );
obst{ind}.color = obst_color(end,:);
obst{ind}.curvature = obst_curv;
obst{ind}.be = bind_energy(ind);
obst{ind}.ffrac = obst{ind}.ffActual;
ffoAct(ind) = obst{ind}.ffrac;

% binding flag stuff
% Take exponential of binding energy based on occupcany change
% expBE(1): unbinding expBE(2): no change expBE(3): binding
if isinf( obst{ind}.be )
  obst{ind}.bindFlag = 0;
else
  bobst{ind}.indFlag = 1;
  obst{ind}.expBE = ...
    [ exp( bind_energy(ind) ) 1 exp( -bind_energy(ind) ) ];
end
obst{ind}.edgePlace = modelopt.edges_place{ind};
obst{ind}.tracersOccNum = 0;
obst{ind}.tracerOccFrac = 0;
% update forbidden sites
forbidden_sites = [ obst{ind}.allpts ] ;
% Loop over obstacle types to initialize
for ii = 1:num_obst_types-1
  ind = obstOrder(ii);
  obst{ind} = place_obstacles( paramlist.ffo(ind), paramlist.so(ind), ...
    n.grid, modelopt.obst_excl, forbidden_sites );
  obst{ind}.color = obst_color(ind,:);
  obst{ind}.curvature = obst_curv;
  obst{ind}.be = bind_energy(ind);
  obst{ind}.ffrac = obst{ind}.ffActual;
  % binding flag stuff
  % Take exponential of binding energy based on occupcany change
  % expBE(1): unbinding expBE(2): no change expBE(3): binding
  if isinf( obst{ind}.be )
    obst{ind}.bindFlag = 0;
  else
    obst{ind}.bindFlag = 1;
    obst{ind}.expBE = [ exp( bind_energy(ind) ) 1 exp( -bind_energy(ind) ) ];
  end
  ffoAct(ind) = obst{ind}.ffrac;
  obst{ind}.edgePlace = modelopt.edges_place{ind};
  obst{ind}.tracersOccNum = 0;
  obst{ind}.tracerOccFrac = 0;
  % update forbidden sites
  filledObstSites = [ filledObstSites; obst{ind}.allpts ] ;
end

if verbose
  tOut = toc;
  fprintf('Overlap = %d\n', ~modelopt.obst_excl );
  fprintf('Placed %d obstacles in %d tries is %f sec\n', obst.num, obst.trys2fill, tOut);
  fprintf('ff want: %f ff actual: %f \n', obst.ffWant, obst.ffActual);
end

% tracer fields
if verbose
  fprintf('Placing tracers\n');
  tic
end

% place tracers
% Handle exclusion
if modelopt.obst_trace_excl == 1
  be4place = -Inf * ones( num_obst_types, 1 );
else
  be4place = paramlist.be;
end
% place 'em!
tracer = place_tracers( paramlist.num_tracer, obst, be4place, ffoAct, n.grid );
% update obstacles
for ii = 1:num_obst_types
  obst{ii}.tracersOccNum = tracer.occNum(ii);
  obst{ii}.tracerOccFrac = tracer.occFrac(ii);
end
 keyboard 
if verbose
  tOut = toc;
  fprintf('Placed %d tracers %f sec\n', tracer.num, tOut);
end

tracer.color = tracer_color;
tracer.curvature = tracer_curv;
tracer.pmove_unb = tr_diff_unb;
tracer.pmove_bnd = tr_diff_bnd;
tracer.probmov = zeros(num_tracer,1);

% Derived parameters and store
n.num_obst = obst.num; %square lattice
n.num_tracer = tracer.num;

% Derived parameters and store
paramlist.ffo_act = obst.ffActual;

% Set up things for recording
tracer.cen_nomod=tracer.center;
% Open file for incremental writing
fileObj = matfile(filename,'Writable',true);

% Allocate memory for recording. for matfile---fileobj---just let it know
% what some of it's fields is 3d. You don't need to allocate space for
% everything though
% tracer temp records
if n.trPosRecModFlag
  tracer_cen_rec_temp = zeros( n.num_tracer, n.dim, n.NrecChunk );
  fileObj.tracer_cen_rec = zeros( n.num_tracer, n.dim, 2 );
end
if n.trPosRecNoModFlag
  tracer_cen_rec_nomod_temp = zeros( n.num_tracer, n.dim, n.NrecChunk );
  fileObj.tracer_cen_rec_nomod = zeros( n.num_tracer, n.dim, 2 );
end
if n.trStateRecFlag
  tracer_state_rec_temp = zeros( n.num_tracer, n.NrecChunk );
  fileObj.tracer_state_rec = zeros( n.num_tracer, 2 );
end
if n.trackOcc
  occupancy_temp = zeros( 1, n.NrecChunk );
end
% obstacles temp records
if n.obsPosRecModFlag
  obst_cen_rec_temp = zeros( n.num_obst, n.dim, n.NrecChunk );
  fileObj.obst_cen_rec = zeros( n.num_obst, n.dim, 2 );
end
if n.obsPosRecNoModFlag
  obst_cen_rec_nomod_temp = zeros( n.num_obst,n.dim, n.NrecChunk );
  fileObj.obst_cen_rec_nomod = zeros( n.num_obst, n.dim, 2);
end

% Pre-Allocate some commonly used matrices
onesNt2 = ones( n.num_tracer, n.dim ); % matrix of ones ( Ntracer x 2 ) used for mod
NgsNt2 = repmat( n.grid, [n.num_tracer, 1] ) .* ones( n.num_tracer, n.dim ); % matix of Ng ( Ntracer x n.dimension ) used for mod

% Animate first position
if animate && n.dim == 2
  ax=gca;axis square;ax.XGrid='on';ax.YGrid='on';
  ax.XLim=[0.5 n.n_gridpoints+0.5];ax.YLim=[0.5 n.n_gridpoints+0.5];
  ax.XTick=[0:ceil(n.n_gridpoints/20):n.n_gridpoints];
  ax.YTick=ax.XTick;
  ax.XLabel.String='x position';ax.YLabel.String='y position';
  ax.FontSize=14;
  for obstType = 1:num_obst_types
    for kObst=1:n.num_obst
      obst{ii}=update_rectangle(obst{ii},kObst,obst{ii}.length,n.n_gridpoints,...
       obst{ii}.color,obst{ii}.curvature);
      pause(tpause);
    end
  end
  for kTracer=1:n.num_tracer
    tracer=update_rectangle(tracer,kTracer,n.size_tracer,n.n_gridpoints,...
      tracer.color,tracer.curvature);
    pause(tpause);
  end
end

keyboard
% preallocate some things to prevent errors
center_new = ones( n.num_tracer, 3 );
% loop over time points
if verbose; fprintf('Starting time loop\n'); tic; end
for m=1:n.ntimesteps
  % Try and move everything
  list.tracerdir=randi(length(lattice.moves),n.num_tracer,1);
  % Attempt new tracer positions
  center_old=tracer.center;
  center_temp= center_old+lattice.moves(list.tracerdir,:);
  
  % Enforcing periodic boundary conditions
  center_new(:,1:n.dim) = mod( center_temp - onesNt2 , NgsNt2 ) + onesNt2;
  sites_new = ...
    sub2ind(n.grid, center_new(:,1), center_new(:,2), center_new(:,3) );
  
  % Find old and new occupancy, i.e, when tracer and obs on same site
  occ_old=tracer.state;
  occ_new=ismember(sites_new, obst.allpts);
  sum_occ = occ_old + occ_new;
  
  % Make a vector and try and move see what we can move based on hop prob
  rvec=rand(n.num_tracer,1);
  tracer.probmov( sum_occ == 2  ) = tracer.pmove_bnd;
  tracer.probmov( sum_occ == 1  ) = 1;
  tracer.probmov( sum_occ == 0  ) = tracer.pmove_unb;
  list.attempt=find(rvec<tracer.probmov);
  
  % Accept moves based on binding energetics
  if ~isempty( list.attempt )
    if obst.bindFlag
      % Accept or not due to binding.
      % taccept in (1, numAttempts);  accept in (1, numTracer)
      % Generate random vector, if it's less than exp( \DeltaBE ) accept
      rvec2=rand(length(list.attempt),1);
      % Calc change in occupancy +2 to give index of expBE (-1,0,1)->(1,2,3)
      deltaOcc = occ_new(list.attempt) - occ_old(list.attempt) + 2;
      ProbAcceptBind = obst.expBE( deltaOcc )';
      list.taccept=find( rvec2 <= ProbAcceptBind );
    else
      % accept unbinding, obs-obs movement, free movement
      list.taccept = occ_new(list.attempt) - occ_old(list.attempt) < 1;
    end
    list.accept=list.attempt(list.taccept);
  else
    list.accept = [];
  end
  
  % Move all accepted changes
  tracer.center(list.accept,1:n.dim) = center_new(list.accept,1:n.dim); %temporary update rule for drawing
  tracer.cen_nomod(list.accept,1:n.dim) = tracer.cen_nomod(list.accept,1:n.dim)+...
    lattice.moves(list.tracerdir(list.accept),1:n.dim); %center, no periodic wrapping
  
  tracer.allpts(list.accept)=sites_new(list.accept); %update other sites
  tracer.state(list.accept)=occ_new(list.accept);
  
  % Track reject changes
  list.reject=setdiff(list.attempt,list.accept);
  
  % Animations
  if animate && n.dim == 2
    for kTracer=1:n.num_tracer
      tracer=update_rectangle(tracer,kTracer,n.size_tracer,n.n_gridpoints,...
        tracer.color,tracer.curvature);
      pause(tpause);
    end
  end
  
  % Recording
  if n.Rec > 0
    if m >= n.twait
      if mod( m, n.rec_interval  ) == 0
        % tracer temp records
        if n.trPosRecModFlag
          tracer_cen_rec_temp(1:n.num_tracer,1:n.dim,jrectemp) = tracer.center;
        end
        if n.trPosRecNoModFlag
          tracer_cen_rec_nomod_temp(1:n.num_tracer,1:n.dim,jrectemp) = tracer.cen_nomod;
        end
        if n.trStateRecFlag
          tracer_state_rec_temp(1:n.num_tracer,jrectemp) = tracer.state;
        end
        if n.trackOcc
          occupancy_temp(jrectemp) = ...
            length( find( tracer.state == 1 )) ./ length(tracer.state);
        end
        % obstacles temp records
        if n.obsPosRecModFlag
          obst_cen_rec_temp(1:n.num_obst,1:n.dim,jrectemp) = obst.center;
        end
        if n.obsPosRecNoModFlag
          obst_cen_rec_nomod_temp(1:n.num_obst,1:n.dim,jrectemp) = obst.center;
        end
        
        if mod( m, const.write_interval  ) == 0
          RecIndTemp = (jchunk-1) *  const.NrecChunk + 1 : jchunk * const.NrecChunk;
          % tracer write to file
          if n.trPosRecModFlag
            fileObj.tracer_cen_rec(1:n.num_tracer,1:n.dim,RecIndTemp) = ...
              tracer_cen_rec_temp;
          end
          if n.trPosRecNoModFlag
            fileObj.tracer_cen_rec_nomod(1:n.num_tracer,1:n.dim,RecIndTemp) = ...
              tracer_cen_rec_nomod_temp;
          end
          if n.trStateRecFlag
            fileObj.tracer_state_rec(1:n.num_tracer,RecIndTemp) = ...
              tracer_state_rec_temp;
          end
          if n.trackOcc
            fileObj.occupancy(1,RecIndTemp) = occupancy_temp;
          end
          % obstacles temp records
          if n.obsPosRecModFlag
            fileObj.obst_cen_rec(1:n.num_obst,1:n.dim,RecIndTemp) = ...
              obst_cen_rec_temp;
          end
          if n.obsPosRecNoModFlag
            fileObj.obst_cen_rec_nomod(1:n.num_obst,1:n.dim,RecIndTemp) = ...
              obst_cen_rec_nomod_temp;
          end
          jrectemp = 0;
          jchunk = jchunk + 1;
          if verbose
            fprintf('%d done\n', round(100 * m ./ n.ntimesteps ) )
          end
        end % write mod(m, chuck)
        jrectemp = jrectemp + 1;
        jrec = jrec + 1;
      end % rec mod(m,trec)
    end % m > twait
  end % record
end %loop over time

if verbose
  tOut = toc;
  tOut =  tOut / 3600;
  fprintf('\nFinished loop %f hours\n\n', tOut)
end

% rm obst field in 3d. Way too much data
if n.dim == 3
  fields2go = {'allpts', 'center', 'centerInds',...
    'corner' ,'cornerInds','cen_nomod','edgeInds'};
  obst = rmfield( obst, fields2go );
end

% save it
fileObj.const = const;
fileObj.paramlist = paramlist;
fileObj.obst = obst;
fileObj.tracer = tracer;
fileObj.modelopt = modelopt;

if modelopt.movie
  movie_diffusion(obst,fileObj.obst_cen_rec,tracer,fileObj.tracer_cen_rec,...
    const,n,modelopt.movie_timestep,modelopt.movie_filename);
end

