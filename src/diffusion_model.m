function [tracer,obst] = diffusion_model(paramvec,const,modelopt,obstParamAll, filename)
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
  tFill = zeros( num_obst_types, 1);
end

% place some obstacles
[obst, obstInfo] =  buildObstMaster( obstInpt, tr_diff_unb, grid, colorArray );

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
% Open file for incremental writing
fileObj = matfile(filename,'Writable',true);

% Allocate memory for recording. for matfile---fileobj---just let it know
% what some of it's fields is 3d. You don't need to allocate space for
% everything though. Let the fileObj field to at least be the size of the temp
% tracer temp records
if n.trPosRecModFlag
  tracer_cen_rec_temp = zeros( n.num_tracer, n.dim, n.NrecChunk );
  fileObj.tracer_cen_rec = zeros( n.num_tracer, n.dim, n.NrecTot );
end
if n.trPosRecNoModFlag
  tracer_cen_rec_nomod_temp = zeros( n.num_tracer, n.dim, n.NrecChunk );
  fileObj.tracer_cen_rec_nomod = zeros( n.num_tracer, n.dim, n.NrecTot );
end
if n.trStateRecFlag
  tracer_state_rec_temp = zeros( n.num_tracer, n.NrecChunk );
  fileObj.tracer_state_rec = zeros( n.num_tracer, n.NrecTot  );
end
if n.trackOcc
  occupancy_temp = zeros( num_obst_types, n.NrecChunk );
  fileObj.occupancy = zeros( num_obst_types, n.NrecTot  );
end
% obstacles temp records
if n.obsPosRecModFlag
  error('Not written for multiple obstacles. However, they do not move! Position saved in obst');
  %   obst_cen_rec_temp = zeros( n.num_obst, n.dim, n.NrecChunk, n.num_obst_types );
  %   fileObj.obst_cen_rec = zeros( n.num_obst, n.dim, 2, n.num_obst_types );
end
if n.obsPosRecNoModFlag
  error('Not written for multiple obstacles. However, they do not move! Position saved in obst');
  %   obst_cen_rec_nomod_temp = zeros( n.num_obst,n.dim, n.NrecChunk, n.num_obst_types  );
  %   fileObj.obst_cen_rec_nomod = zeros( n.num_obst, n.dim, 2, n.num_obst_types );
end

% Pre-Allocate some commonly used matrices
onesNt2 = ones( n.num_tracer, n.dim ); % matrix of ones ( Ntracer x 2 ) used for mod
NgsNt2 = repmat( grid.sizeV, [n.num_tracer, 1] ) .* ones( n.num_tracer, n.dim ); % matix of Ng ( Ntracer x n.dimension ) used for mod
% Animate first position
if animate && n.dim == 2
  clf
  obstRectangle = cell( 1, num_obst_types );
  tracerRectangle = struct;
  ax=gca;axis square;ax.XGrid='on';ax.YGrid='on';
  ax.XLim=[0.5 n.n_gridpoints+0.5];ax.YLim=[0.5 n.n_gridpoints+0.5];
  ax.XTick=[0:ceil(n.n_gridpoints/20):n.n_gridpoints];
  ax.YTick=ax.XTick;
  ax.XLabel.String='x position';ax.YLabel.String='y position';
  ax.FontSize=14;
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
  pause(2);
end
if any( ismember( obst{1}.AllPts, obst{2}.AllPts ) )
  error('differect obstacles are overlapping')
end
if modelopt.movie
  fprintf('Making movie\n')
  Fig = gcf;
  Fig.WindowStyle = 'normal';
  movObj = VideoWriter(modelopt.movie_name);
  movObj.FrameRate = modelopt.movie_framerate;
  open(movObj);
  numMovieRec = 1;
  printFinish = 1;
end

% preallocate some things to prevent errors
center_new = ones( tracer.Num, 3 );
all_tracer_inds = 1:n.num_tracer;
state_new_save = (num_obst_types+1) .* ones( n.num_tracer,1 );

% set-up flux Counter
fluxCounter = FluxCounterClass( const.fluxCountInpt, grid );

% loop over time points
if verbose; fprintf('Starting time loop\n'); tic; end
for m=0:n.ntimesteps
  % Try and move everything
  list.tracerdir=randi(length(lattice.moves),n.num_tracer,1);
  
  % get current positions, called old
  center_old=tracer.Centers;
  sites_old = tracer.AllPts;
  state_old = tracer.State;
  
  % Attempt new tracer positions
  center_temp= center_old+lattice.moves(list.tracerdir,:);
  
  % Enforcing periodic boundary conditions
  center_new(:,1:n.dim) = mod( center_temp - onesNt2 , NgsNt2 ) + onesNt2;
  
  sites_new = ...
    sub2ind(grid.sizeV, center_new(:,1), center_new(:,2), center_new(:,3) );
  
  % Find old and new occupancy, i.e, when tracer and obs on same site
  rvec=rand(n.num_tracer,1);
  state_new = state_new_save;
  for ii = 1:num_obst_types
    state_new( ismember(sites_new, obst{ii}.AllPts ) ) = ii;
  end
  transInds = sub2ind( obstInfo.sizeT, state_new, state_old);
  probmov = obstInfo.acceptT( transInds );
  list.accept = find(rvec<probmov);
  list.reject = setdiff( all_tracer_inds,list.accept );
  
  % Move all accepted changes
  tracer.Centers(list.accept,1:n.dim) = center_new(list.accept,1:n.dim); %temporary update rule for drawing
  tracer.PosNoMod(list.accept,1:n.dim) = tracer.PosNoMod(list.accept,1:n.dim)+...
    lattice.moves(list.tracerdir(list.accept),1:n.dim); %center, no periodic wrapping
  
  tracer.AllPts(list.accept)=sites_new(list.accept); %update other sites
  tracer.State(list.accept)=state_new(list.accept);
  
  % Animations
  if animate && n.dim == 2
    for kTracer=1:n.num_tracer
      tracerRectangle=update_rectangle(tracer.Centers, tracerRectangle, ...
        kTracer,tracer.Length,n.n_gridpoints,...
        tracer.Color,tracer.Curvature);
    end
    pause(tpause);
  end
  
  % Flux counting
  if fluxCounter.Flag == 1
    fluxCounter.updateFlux( tracer.Centers, center_old );
  end
    if modelopt.movie
      numMovieRec = numMovieRec + 1;
      if numMovieRec < modelopt.movie_steps
        Fr = getframe(Fig);
        writeVideo(movObj,Fr);
      elseif printFinish == 1
        printFinish = 0;
        fprintf('Finished movie\n')
        close(movObj)
      end
  end
  
  % Recording
  if n.Rec > 0
    if m == n.twait
      % tracer write to file
      if n.trPosRecModFlag
        fileObj.tracer_cen_rec(1:n.num_tracer,1:n.dim,1) = sites_old;
      end
      if n.trPosRecNoModFlag
        fileObj.tracer_cen_rec_nomod(1:n.num_tracer,1:n.dim,1) = center_old;
      end
      if n.trStateRecFlag
        fileObj.tracer_state_rec(1:n.num_tracer,1) = state_old;
      end
      if n.trackOcc
        for ii = 1:num_obst_types
          occupancy_temp(ii,1) = ...
            length( find( state_old == ii )) ./ tracer.Num;
        end
        fileObj.occupancy(1:num_obst_types,1) = length( find( state_old == ii )) ./ tracer.Num;
      end
      jrectemp = 1;
      jrec = 2;
    elseif m > n.twait
      % store first point
      if mod( m - n.twait, n.rec_interval  ) == 0
        % tracer temp records
        if n.trPosRecModFlag
          tracer_cen_rec_temp(1:n.num_tracer,1:n.dim,jrectemp) = tracer.AllPts;
        end
        if n.trPosRecNoModFlag
          tracer_cen_rec_nomod_temp(1:n.num_tracer,1:n.dim,jrectemp) = center_old;
        end
        if n.trStateRecFlag
          tracer_state_rec_temp(1:n.num_tracer,jrectemp) = state_old;
        end
        if n.trackOcc
          for ii = 1:num_obst_types
            occupancy_temp(ii,jrectemp) = ...
              length( find( state_old == ii )) ./ tracer.Num;
          end
        end
        if mod( m-n.twait, const.write_interval  ) == 0
          jrecEnd = jrec + const.NrecChunk - 1;
          recIndTemp = jrec:jrecEnd;
          % tracer write to file
          if n.trPosRecModFlag
            fileObj.tracer_cen_rec(1:n.num_tracer,1:n.dim,recIndTemp) = ...
              tracer_cen_rec_temp;
          end
          if n.trPosRecNoModFlag
            fileObj.tracer_cen_rec_nomod(1:n.num_tracer,1:n.dim,recIndTemp) = ...
              tracer_cen_rec_nomod_temp;
          end
          if n.trStateRecFlag
            fileObj.tracer_state_rec(1:n.num_tracer,recIndTemp) = ...
              tracer_state_rec_temp;
          end
          if n.trackOcc
            fileObj.occupancy(1:num_obst_types,recIndTemp) = occupancy_temp;
          end
          jrec = jrecEnd + 1;
          jrectemp = 0;
          if verbose
            fprintf('%d done\n', round(100 * m ./ n.ntimesteps ) )
          end
        end % write mod(m, chuck)
        jrectemp = jrectemp + 1;
      end % rec mod(m,trec)
    end % m > twait
  end % record
end %loop over time

if verbose
  tOut = toc;
  tOut =  tOut / 3600;
  fprintf('\nFinished loop %f hours\n\n', tOut)
end

% save it
fileObj.const = const;
fileObj.paramlist = paramlist;
fileObj.obst = obstInpt;
fileObj.modelopt = modelopt;
fileObj.flux = fluxCounter.Counts;
