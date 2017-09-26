function [tracer,obst] = diffusion_model(paramvec,const,modelopt,obstCell,filename)
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
totParams = 2;
if length(paramvec) ~= totParams
  error('diffusion_model: incorrect parameter vector length');
else 
  num_tracer = paramvec(1);
  tr_diff_unb = paramvec(2);
end

% Paramvec as a struct
paramlist.num_tracer = num_tracer; %filling frac tracer
paramlist.tr_diff_unb = tr_diff_unb; %unbound hop energy

% verbose
verbose = const.verbose;
% Animation features
obst_curv=0.2; %curvature for animations
tracer_color=[0 1 1]; %cyan
tracer_curv=1; %curvature for animations

% get number of obstacles
num_obst_types = length( obstCell );

% Assign internal variables
n = const;
n.numSites = n.n_gridpoints .^ n.dim;
n.num_obst_types = num_obst_types;
n.num_obst = zeros( num_obst_types );
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
[obst, obstInfo] =  buildObstMaster( obstCell, tr_diff_unb, n.grid, colorArray );

%filledObstSites = [];
%% scramble the order unless there are bigger obstacles. No favorites!!!
%obstOrder = zeros( 1, num_obst_types);
%% [~, obstOrder] = sort( paramlist.so );
%uniqueSizes = fliplr( unique(paramlist.so,'sorted') );
%holder = 1;
%for ii = 1:length(uniqueSizes)
  %inds = find( paramlist.so == uniqueSizes(ii) );
  %numInds = length(inds);
  %obstOrder(holder:holder+numInds-1) = inds( randperm( numInds ) );
  %%   paramlist.so( uniqueSizes(ii) );
  %holder = holder+numInds;
%end
%% rescale filling fractions if they are too high
%fillFracScale = min(  1 / ( sum(paramlist.ffo) ), 1 );
%% allocate a vector of actuall fffrac for placing tracers later
%ffoAct = zeros( num_obst_types, 1 );
%% First initialize the empty 'obstactle' for allocation
%ind = num_obst_types+1;
%obst{ind}.ffoWant = 1 - sum( paramlist.ffo );
%obst{ind}.ffrac = 0;
%obst{ind}.allpts = 0;
%obst{ind}.num = 0;
%obst{ind}.be = 0;
%obst{ind}.color = [0 0 0];
%obst{ind}.curvature = 0;
%obst{ind}.edgePlace = 0;
%obst{ind}.tracersOccNum = 0; % reset later
%obst{ind}.tracerOccFrac = 0; % reset later
%ffoAct(ind) = 0;
%n.num_obst(ind) = obst{ind}.num;
%% update forbidden sites
%filledObstSites = [] ;
%% Loop over obstacle types to initialize
%for ii = 1:num_obst_types
  %if verbose
    %tic
  %end
  %ind = obstOrder(ii);
  %ffWant = fillFracScale .* paramlist.ffo(ind);
  %obst{ind} = place_obstacles( ffWant, paramlist.so(ind), ...
    %n.grid, modelopt.obst_excl, filledObstSites );
  %obst{ind}.be = bind_energy(ind);
  %obst{ind}.color = colorArray(ind,:);
  %obst{ind}.curvature = obst_curv;
  %obst{ind}.edgePlace = modelopt.edges_place{ind};
  %obst{ind}.tracersOccNum = 0; % reset later
  %obst{ind}.tracerOccFrac = 0; % reset later
  %n.num_obst(ind) = obst{ind}.num;
  %ffoAct(ind) = obst{ind}.ffrac;
  %% update forbidden sites
  %filledObstSites = [ filledObstSites; obst{ind}.allpts ] ;
  %if verbose
    %tFill(ii) = toc;
  %end
%end

%% Fix empty sites
%emptySites = setdiff( 1:n.numSites, filledObstSites );
%numEmpty = length(emptySites);
%ind = num_obst_types + 1;
%obst{ind}.ffrac = numEmpty / n.numSites;
%obst{ind}.allpts = emptySites';
%obst{ind}.numobst = numEmpty;

%if verbose
  %for ii = 1:num_obst_types
    %fprintf('Overlap = %d\n', ~modelopt.obst_excl );
    %fprintf('Placed %d obstacles in %d tries is %f sec\n', ...
      %obst{ii}.num, obst{ii}.trys2fill, tFill(ii));
    %fprintf('ff want: %f ff actual: %f \n', obst{ii}.ffWant, obst{ii}.ffrac);
  %end
%end

%% create binding transition matrix bindT(f,i) ( row/col = obst 1, 2, ..., n, empty )
%% treate empty as N + 1 obstacle
%deltaG = [paramlist.be 0]' - [paramlist.be 0];
%bindT = exp( -deltaG );
%bindT( bindT > 1 ) = 1;
%tSize = size(bindT);
%% Probability to move
%hopProb = [tr_diff_bnd tr_diff_unb];
%hopT = repmat( hopProb, [num_obst_types+1, 1] ) ;
%% accept probability
%acceptT = hopT .* bindT;

% tracer fields
if verbose
  fprintf('Placing tracers\n');
  tic
end


% place tracers
% Handle exclusion
%{be4place = paramlist.be;%}
%% place 'em!
%tracer = place_tracers( paramlist.num_tracer, obst, be4place, ffoAct, n.grid );
%% reset empty state 0 to # obst types + 1
%tracer.state( tracer.state == 0 ) = num_obst_types + 1;
%% update obstacles to say how many tracer should be on them
%for ii = 1:num_obst_types + 1
  %obst{ii}.tracersOccNum = tracer.occNum(ii);
  %obst{ii}.tracerOccFrac = tracer.occFrac(ii);
%end

%if verbose
  %tOut = toc;
  %fprintf('Placed %d tracers %f sec\n', tracer.num, tOut);
%end
%% the rest of the tracer fields
%tracer.color = tracer_color;
%tracer.curvature = tracer_curv;
%tracer.pmove_unb = tr_diff_unb;
%tracer.pmove_bnd = tr_diff_bnd;
%{tracer.probmov = zeros(num_tracer,1);%}
tracer = TracerClass(  paramlist.num_tracer, obst, obstInfo.be, n.grid, ...
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
  fileObj.tracer_cen_rec = zeros( n.num_tracer, n.dim, n.NrecChunk );
end
if n.trPosRecNoModFlag
  tracer_cen_rec_nomod_temp = zeros( n.num_tracer, n.dim, n.NrecChunk );
  fileObj.tracer_cen_rec_nomod = zeros( n.num_tracer, n.dim, n.NrecChunk);
end
if n.trStateRecFlag
  tracer_state_rec_temp = zeros( n.num_tracer, n.NrecChunk );
  fileObj.tracer_state_rec = zeros( n.num_tracer, n.NrecChunk );
end
if n.trackOcc
  occupancy_temp = zeros( num_obst_types, n.NrecChunk );
  fileObj.occupancy = zeros( num_obst_types, n.NrecChunk );
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
NgsNt2 = repmat( n.grid, [n.num_tracer, 1] ) .* ones( n.num_tracer, n.dim ); % matix of Ng ( Ntracer x n.dimension ) used for mod
% Animate first position
if animate && n.dim == 2
  obstRectangle = cell( 1, num_obst_types );
  tracerRectangle = cell( 1, 1 );
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
    tracerRectangle{1}=update_rectangle(tracer.Corners, tracerRectangle{1}, ...
      kTracer,tracer.Length,n.n_gridpoints,...
      tracer.Color,tracer.Curvature);
  end
  pause(2);
end
if any( ismember( obst{1}.AllPts, obst{2}.AllPts ) )
  error('differect obstacles are overlapping')
end

% preallocate some things to prevent errors
center_new = ones( tracer.Num, 3 );
all_tracer_inds = 1:n.num_tracer;
occ_new_save = (num_obst_types+1) .* ones( n.num_tracer,1 );
keyboard
% loop over time points
if verbose; fprintf('Starting time loop\n'); tic; end
for m=1:n.ntimesteps
  % Try and move everything
  list.tracerdir=randi(length(lattice.moves),n.num_tracer,1);
  % Attempt new tracer positions
  center_old=tracer.AllPts;
  center_temp= center_old+lattice.moves(list.tracerdir,:);
  
  % Enforcing periodic boundary conditions
  center_new(:,1:n.dim) = mod( center_temp - onesNt2 , NgsNt2 ) + onesNt2;
  sites_new = ...
    sub2ind(n.grid, center_new(:,1), center_new(:,2), center_new(:,3) );
  
  % Find old and new occupancy, i.e, when tracer and obs on same site
  rvec=rand(n.num_tracer,1);
  occ_old = tracer.state;
  occ_new = occ_new_save;
  for ii = 1:num_obst_types
    occ_new( ismember(sites_new, obst{ii}.allpts ) ) = ii;
  end
  transInds = sub2ind( tSize, occ_new, occ_old);
  tracer.probmov = acceptT( transInds );
  list.accept = find(rvec<tracer.probmov);
  list.reject = setdiff( all_tracer_inds,list.accept );
  
  % Move all accepted changes
  tracer.AllPts(list.accept,1:n.dim) = center_new(list.accept,1:n.dim); %temporary update rule for drawing
  tracer.PosNoMod(list.accept,1:n.dim) = tracer.PosNoMod(list.accept,1:n.dim)+...
    lattice.moves(list.tracerdir(list.accept),1:n.dim); %center, no periodic wrapping
  
  tracer.allpts(list.accept)=sites_new(list.accept); %update other sites
  tracer.state(list.accept)=occ_new(list.accept);
  
  % Animations
  if animate && n.dim == 2
    for kTracer=1:n.num_tracer
      tracer=update_rectangle(tracer,kTracer,n.size_tracer,n.n_gridpoints,...
        tracer.color,tracer.curvature);
    end
    pause(tpause);
  end
  % Recording
  if n.Rec > 0
    if m >= n.twait
      if mod( m, n.rec_interval  ) == 0
        % tracer temp records
        if n.trPosRecModFlag
          tracer_cen_rec_temp(1:n.num_tracer,1:n.dim,jrectemp) = tracer.AllPts;
        end
        if n.trPosRecNoModFlag
          tracer_cen_rec_nomod_temp(1:n.num_tracer,1:n.dim,jrectemp) = tracer.PosNoMod;
        end
        if n.trStateRecFlag
          tracer_state_rec_temp(1:n.num_tracer,jrectemp) = tracer.state;
        end
        if n.trackOcc
          for ii = 1:num_obst_types
            occupancy_temp(ii,jrectemp) = ...
              length( find( tracer.state == ii )) ./ tracer.num;
          end
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
            fileObj.occupancy(1:num_obst_types,RecIndTemp) = occupancy_temp;
          end
          jchunk = jchunk + 1;
          jrectemp = 0;
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
