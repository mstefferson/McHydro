function [tracer,obst] = diffusion_model(paramvec,const,modelopt,filename)
% DIFFUSION_MODEL run model of tracers diffusing through obstacles
%   inputs are:
%   pvec = parameter vector containing
%     growth speed (micron/min)
%   --also for ...
%   const = structure of constant parameters, must include
%     t_tot=total simulation timesteps,
%   modelopt = structure of model options, can include
%     wt=1 for wild-type model, causes length-dependent catastrophe
%   returns:
%   kc = structure of kinetochore trajectories and info
%   MDB 8/18/15 created
%   MDB 9/28/15 specialized to immobile obstacles, noninteracting tracers
%   so that moves can be done in parallel

% initialize everythin 
% Parameters from pvec
if (length(paramvec)<6)
  error('diffusion_model: parameter vector too short');
elseif (length(paramvec)==6)
  ffrac_tracer = paramvec(1);
  tr_hop_unb = paramvec(2);
  tr_hop_bnd = paramvec(3);
  ffrac_obst = paramvec(4);
  bind_energy = paramvec(5);
  size_obst = paramvec(6);
elseif (length(paramvec)>6)
  error('diffusion_model: parameter vector too long');
end

% Paramvec as a struct
paramslist.fft = ffrac_tracer; %filling frac tracer
paramslist.tr_hop_unb = tr_hop_unb; %unbound hop energy 
paramslist.tr_hop_bnd = tr_hop_bnd ; % bound hop energy
paramslist.ffo = ffrac_obst; %filling frac obs
paramslist.be = bind_energy; % bind energy
paramslist.so = size_obst;

% Colors
obst_color=[0 0 0]; %black
obst_curv=0.2; %curvature for animations
tracer_color=[0 1 1]; %cyan
tracer_curv=1; %curvature for animations
red=[1 0 0];

% binding flag stuff
% Take exponential of binding energy out of time loop, then pick a value
% based on occupancy change.
% expBE(1): unbinding expBE(2): no change expBE(3): binding
if isinf( paramslist.be );
  bindFlag = 0;
else
  bindFlag = 1;
  expBE = [ exp(bind_energy) 1 exp(-bind_energy) ];
end

% Assign internal variables
n.gridpoints=const.n_gridpoints;
n.len_obst=size_obst;
n.len_tracer=const.size_tracer;
n.timesteps=const.ntimesteps;

% Time
n.TrRec     = const.TrRecFlag;
n.ObRec     = const.ObsRecFlag;
n.Rec       = n.TrRec + n.ObRec;
n.timesteps = const.ntimesteps;
n.rec_interval = const.rec_interval;
n.twait     = const.twait;
n.rec_chunk = const.rec_chunk;
n.NrecChunk = const.NrecChunk;
n.NrecTot   = const.NrecTot;
jrectemp = 1;
jrec     = 1;
jchunk   = 1;

% Model options
animate=modelopt.animate;    %1 to show animation, 0 for no animation
tpause=modelopt.tpause;      %pause time in animation
if animate; figure; end;

% Derived parameters
n.obst=round(ffrac_obst*(n.gridpoints/n.len_obst)^modelopt.dimension); %square lattice
n.tracer=round(ffrac_tracer*(n.gridpoints/n.len_tracer)^modelopt.dimension);

% Square lattice definition - assume 2D for now
lattice.moves=[1 0;
  -1 0;
  0 1;
  0 -1];

% obstacle fields
obst=place_objects(n.obst,n.len_obst,n.gridpoints,modelopt,modelopt.obst_excl,...
  0,obst_color,obst_curv);
obst.color=obst_color;
obst.curvature=obst_curv;
obst.ffrac=ffrac_obst;

% tracer fields
tracer=place_objects(n.tracer,n.len_tracer,n.gridpoints,modelopt,...
  modelopt.tracer_excl,1,tracer_color,tracer_curv,obst);
tracer.color=tracer_color;
tracer.curvature=tracer_curv;
tracer.ffrac=ffrac_tracer;
tracer.pmove_unb=exp(-tr_hop_unb);
tracer.pmove_bnd=exp(-tr_hop_bnd);
tracer.state=ismember(tracer.allpts, obst.allpts);
tracer.probmov = zeros(n.tracer,1);

parsave(filename,paramslist,tracer,obst,const,modelopt);

% Set up things for recording
obst.cen_nomod=obst.center;
tracer.cen_nomod=tracer.center;
% Open file for incremental writing
fileObj = matfile(filename,'Writable',true);

% Allocate memory for recording. for matfile---fileobj---just let it know
% what some of it's fields is 3d. You don't need to allocate space for
% everything though

if n.ObRec
  obst_cen_rec_temp = zeros( n.obst, 2, n.NrecChunk );
  obst_cen_rec_nomod_temp = zeros( n.obst,2, n.NrecChunk );
  
  fileObj.obst_cen_rec = zeros( n.obst, 2, 2 );
  fileObj.obst_cen_rec_nomod = zeros( n.obst, 2, 2);
end

if n.TrRec
  tracer_cen_rec_temp = zeros( n.tracer, 2, n.NrecChunk );
  tracer_cen_rec_nomod_temp = zeros( n.tracer, 2, n.NrecChunk );
  tracer_state_rec_temp = zeros( n.tracer, n.NrecChunk );
  
  fileObj.tracer_cen_rec = zeros( n.tracer, 2, 2 );
  fileObj.tracer_cen_rec_nomod = zeros( n.tracer, 2, 2 );
  fileObj.tracer_state_rec = zeros( n.tracer, 2 );
end

%% loop over time points
for m=1:n.timesteps;
  
  % Try and move everything
  list.tracerdir=randi(length(lattice.moves),n.tracer,1);
  
  % Attempt new tracer positions
  center_old=tracer.center;
  center_temp= center_old+lattice.moves(list.tracerdir,:);
  
  % Enforcing periodic boundary conditions
  center_new = mod( center_temp-ones(size(center_temp)),...
    ones(size(center_temp))*n.gridpoints )+ones(size(center_temp));
  sites_new = ...
    sub2ind([n.gridpoints n.gridpoints], center_new(:,1), center_new(:,2));
  
  % Find old and new occupancy, i.e, when tracer and obs on same site
  occ_old=tracer.state;
  occ_new=ismember(sites_new, obst.allpts);
  sum_occ = occ_old + occ_new;
 
  % Make a vector and try and move see what we can move based on hop prob
  rvec=rand(n.tracer,1);
  tracer.probmov( sum_occ == 2  ) = tracer.pmove_bnd;
  tracer.probmov( sum_occ == 1  ) = 1;
  tracer.probmov( sum_occ == 0  ) = tracer.pmove_unb;
  list.attempt=find(rvec<tracer.probmov);

  % Accept moves based on binding energetics
  if bindFlag
    % Accept or not due to binding. 
    % taccept in (1, numAttempts);  accept in (1, numTracer)
    % Generate random vector, if it's less than exp( \DeltaBE ) accept
    rvec2=rand(length(list.attempt),1);
     % Calc change in occupancy +2 to give index of expBE (-1,0,1)->(1,2,3)
    deltaOcc = occ_new(list.attempt) - occ_old(list.attempt) + 2;
    ProbAcceptBind = expBE( deltaOcc )';
    list.taccept=find( rvec2 <= ProbAcceptBind );
  else 
    % accept unbinding, obs-obs movement, free movement 
    list.taccept = occ_new(list.attempt) - occ_old(list.attempt) < 1; 
  end
  list.accept=list.attempt(list.taccept);

  % Move all accepted changes
  tracer.center(list.accept,:) = center_new(list.accept,:); %temporary update rule for drawing
  tracer.cen_nomod(list.accept,:) = tracer.cen_nomod(list.accept,:)+...
    lattice.moves(list.tracerdir(list.accept),:); %center, no periodic wrapping

  tracer.allpts(list.accept,:)=sites_new(list.accept,:); %update other sites
  tracer.state(list.accept)=occ_new(list.accept);
  
  % Track reject changes
  list.reject=setdiff(list.attempt,list.accept);
 
  % Animations
  if animate
    for kTracer=1:n.tracer
      tracer=update_rectangle(tracer,kTracer,n.len_tracer,n.gridpoints,...
        tracer.color,tracer.curvature);
      pause(tpause);
    end
  end
  
  % Recording
  if n.Rec > 0
    if m >= n.twait
      if mod( m, n.rec_interval  ) == 0
        if n.ObRec
          obst_cen_rec_temp(1:n.obst,1:2,jrectemp) = obst.center;
          obst_cen_rec_nomod_temp(1:n.obst,1:2,jrectemp) = obst.cen_nomod;
        end
        if n.TrRec
          tracer_cen_rec_temp(1:n.tracer,1:2,jrectemp) = tracer.center;
          tracer_cen_rec_nomod_temp(1:n.tracer,1:2,jrectemp) = tracer.cen_nomod;
          tracer_state_rec_temp(1:n.tracer,jrectemp) = tracer.state;
        end
        
        if mod( m, const.rec_chunk  ) == 0
          %                     fprintf('Recording %d\n', jchunk);
          RecIndTemp = (jchunk-1) *  const.NrecChunk + 1 : jchunk * const.NrecChunk;
          if n.ObRec
            fileObj.obst_cen_rec(1:n.obst,1:2,RecIndTemp) = ...
              obst_cen_rec_temp;
            fileObj.obst_cen_rec_nomod(1:n.obst,1:2,RecIndTemp) = ...
              obst_cen_rec_nomod_temp;
          end
          if n.TrRec
            fileObj.tracer_cen_rec(1:n.tracer,1:2,RecIndTemp) = ...
              tracer_cen_rec_temp;
            fileObj.tracer_cen_rec_nomod(1:n.tracer,1:2,RecIndTemp) = ...
              tracer_cen_rec_nomod_temp;
            fileObj.tracer_state_rec(1:n.tracer,RecIndTemp) = ...
              tracer_state_rec_temp;
          end
          jrectemp = 0;
          jchunk = jchunk + 1;
        end % write mod(m, chuck)
        jrectemp = jrectemp + 1;
        jrec = jrec + 1;
      end % rec mod(m,trec)
    end % m > twait
  end % record
  
end %loop over time

if modelopt.movie
  movie_diffusion(obst,fileObj.obst_cen_rec,tracer,fileObj.tracer_cen_rec,...
    const,n,modelopt.movie_timestep,modelopt.movie_filename);
end
