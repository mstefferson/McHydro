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

%% initialize
%parameters from pvec
if (length(paramvec)<4)
    error('diffusion_model: parameter vector too short');
elseif (length(paramvec)==4)
    ffrac_obst=paramvec(1);
    ffrac_tracer=paramvec(2);
    slide_barr=paramvec(3) ;
    bind_energy=paramvec(4);
elseif (length(paramvec)>4)
    error('diffusion_model: parameter vector too long');
end

%colors
obst_color=[0 0 0]; %black
obst_curv=0.2; %curvature for animations
tracer_color=[0 1 1]; %cyan
tracer_curv=1; %curvature for animations
red=[1 0 0];

%assign internal variables
n.gridpoints=const.n_gridpoints;
n.len_obst=const.size_obst;
n.len_tracer=const.size_tracer;
n.timesteps=const.ntimesteps;

%time
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

%model options
animate=modelopt.animate;    %1 to show animation, 0 for no animation
tpause=modelopt.tpause;      %pause time in animation

%derived parameters
n.obst=round(ffrac_obst*(n.gridpoints/n.len_obst)^modelopt.dimension); %square lattice
n.tracer=round(ffrac_tracer*(n.gridpoints/n.len_tracer)^modelopt.dimension);

% %square lattice definition - assume 2D for now
lattice.moves=[1 0;
    -1 0;
    0 1;
    0 -1];
lattice.size=[n.gridpoints,n.gridpoints];

obst=place_objects(n.obst,n.len_obst,n.gridpoints,modelopt,modelopt.obst_excl,...
    0,obst_color,obst_curv);
obst.color=obst_color;
obst.curvature=obst_curv;
obst.ffrac=ffrac_obst;

tracer=place_objects(n.tracer,n.len_tracer,n.gridpoints,modelopt,...
    modelopt.tracer_excl,1,tracer_color,tracer_curv,obst);
tracer.color=tracer_color;
tracer.curvature=tracer_curv;
tracer.ffrac=ffrac_tracer;
tracer.pmove=exp(-slide_barr);
tracer.state=sum(ismember(tracer.allpts, obst.allpts),2);

parsave(filename,paramvec,tracer,obst,const,modelopt);

%set up things for recording
obst.cen_nomod=obst.center;
tracer.cen_nomod=tracer.center;
%open file for incremental writing
fileObj = matfile(filename,'Writable',true);

% Allocate memory for recording
if n.ObRec
    obst_cen_rec_temp = zeros(n.obst,2,n.NrecChunk);
    obst_cen_rec_nomod_temp = zeros(n.obst,2,n.NrecChunk);
    
    fileObj.obst_cen_rec=zeros(n.obst,2,n.NrecTot);
    fileObj.obst_cen_rec_nomod=zeros(n.obst,2,n.NrecTot);
end

if n.TrRec
    tracer_cen_rec_temp = zeros(n.tracer,2,n.NrecChunk);
    tracer_cen_rec_nomod_temp = zeros(n.tracer,2,n.NrecChunk);
    tracer_state_rec_temp =zeros(n.tracer,n.NrecChunk);
    
    fileObj.tracer_cen_rec=zeros(n.tracer,2,n.NrecTot);
    fileObj.tracer_cen_rec_nomod=zeros(n.tracer,2,n.NrecTot);
    fileObj.tracer_state_rec=zeros(n.tracer,n.NrecTot);
end


%% loop over time points
for m=1:n.timesteps;
    
    %pick particles to attempt move based on probability
    rvec=rand(n.tracer,1);
    list.attempt=find(rvec<tracer.pmove);
    %pick direction of move
    list.tracerdir=randi(length(lattice.moves),length(list.attempt),1);
    
    %attempt new tracer positions
    center_old=tracer.center(list.attempt,:);
    center_temp= center_old+lattice.moves(list.tracerdir,:);
    %convert object points to coordinates
    [x_obj,y_obj] = ind2sub([n.gridpoints,n.gridpoints],... %*****
        tracer.allpts(list.attempt,:));
    x_obj_new=x_obj+lattice.moves(list.tracerdir,1);
    y_obj_new=y_obj+lattice.moves(list.tracerdir,2);
    %enforce periodic boundary conditions
    center_new = mod(center_temp-ones(size(center_temp)),...
        ones(size(center_temp))*n.gridpoints)+ones(size(center_temp));
    x_all_new = mod(x_obj_new-1,n.gridpoints)+1;
    y_all_new = mod(y_obj_new-1,n.gridpoints)+1;
    %%%%%%%%PLAN: make tracer.allptsX, tracer.allptsY, use those instead of
    %%%%%%%%indexing and sub2ind, ind2sub
    tracer.center(list.attempt,:)=center_new; %temporary update rule for drawing
    sites_new=sub2ind([n.gridpoints n.gridpoints], x_all_new, y_all_new); %********
    
    occ_old=sum(ismember(tracer.allpts(list.attempt,:), obst.allpts),2);
    occ_new=sum(ismember(sites_new, obst.allpts),2);
    rvec2=rand(length(occ_old),1);
    list.taccept=find(rvec2<exp(-(occ_new-occ_old)*bind_energy));
    list.accept=list.attempt(list.taccept);
    tracer.cen_nomod(list.accept,:)=tracer.cen_nomod(list.accept,:)+...
        lattice.moves(list.tracerdir(list.taccept),:); %center, no periodic wrapping
    tracer.allpts(list.accept,:)=sites_new(list.taccept,:); %update other sites
    tracer.state(list.accept)=occ_new(list.taccept);
    
    list.reject=setdiff(list.attempt,list.accept);
    tracer.center(list.reject,:)=center_old(list.reject,:);
    
    if animate
        for kTracer=1:n.tracer
            tracer=update_rectangle(tracer,kTracer,n.len_tracer,n.gridpoints,...
                tracer.color,tracer.curvature);
            pause(tpause);
        end
    end
    
    %recording
    
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
