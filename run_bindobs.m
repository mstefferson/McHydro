%   MDB 9/28/15 specialized to immobile obstacles, noninteracting tracers
%   so that moves can be done in parallel
%   MDB 9/28/15 set up to loop over parameters with parfor
% LEH vary binding energies, with each file having a different filling
% fraction

%tic;
% clear all;
%close all;

%key parameters and constants
slide_barr_height=0;    %barrier height to sliding, in kT
bind_energy_vec = [1 6];
ffrac_obst_vec= [ 0.1 0.2 0.3];         %filling fraction of obstacles
ffrac_tracer=0.1;       %filling fraction of tracers

%declare a params struct for organization as well
params.slide_barr_height = slide_barr_height;
params.bind_energy_vec = bind_energy_vec;
params.ffrac_obst_vec = ffrac_obst_vec;
params.ffrac_tracer = ffrac_tracer;

%grid stuff
const.n_trials    = 4;
const.n_gridpoints=100;    %number of grid points, same in x and y
const.ntimesteps=1e1;       %number of timesteps NOte 1e5 gives errors on my laptop.

%other constants and model options
const.size_obst=1;      %obstacle linear dimension, MUST BE odd integer
const.size_tracer=1;     %tracer linear dimension, MUST BE odd integer
modelopt.obst_excl=1;       %1 if obstacles sterically exclude each other, 0 if not
modelopt.tracer_excl=0;     %MUST BE 0 so tracers don't interact (ghosts)
modelopt.obst_trace_excl=0;  %1 if obstacles and tracers mutually exclude
modelopt.dimension=2; %system dimension, currently must be 2

const.nequil=0;           %number of timesteps for initial equilibration

%model stuff
modelopt.animate=0;          %1 to show animation, 0 for no animation
modelopt.tpause=0.0;         %pause time in animation, 0.1 s is fast, 1 s is slow
modelopt.movie=0;           %1 to record movie

%display everything
disp(params); disp(const); disp(modelopt);

%build a parameter matrix
nbe      = length( bind_energy_vec );
nffo     = length( ffrac_obst_vec );
nt       = const.n_trials;
nparams  = nbe * nffo * nt;
%param matrix.  (:,1) = trial (:,2) = binding (:,3) = ffrc obs
param_mat = zeros( nparams, 3 );
for i = 1:nt
    for j = 1:nbe
        for k = 1:nffo
            rowind = k + nffo * (j-1) + nffo * nbe * (i - 1);
            param_mat( rowind, 1 ) = i;
            param_mat( rowind, 2 ) = bind_energy_vec(j);
            param_mat( rowind, 3 ) = ffrac_obst_vec(k);  
        end
    end
end

% For some reason, param_mat gets "sliced". Create vectors to get arround
% this
param_trial = param_mat(:,1);
param_bind  = param_mat(:,2);
param_ffo   = param_mat(:,3);

fprintf('Starting paramloop \n')

parfor j=1:nparams
    
    trial = param_trial(j); 
    bind_energy = param_bind(j); 
    ffrac_obst = param_ffo(j);
    
    pvec=[ffrac_obst ffrac_tracer slide_barr_height bind_energy]; %parameter vector
    
    filestring=['bar',num2str(slide_barr_height),'_bind',num2str(bind_energy),...
        '_fo',num2str(ffrac_obst),'_ft',num2str(ffrac_tracer),'_so',...
        num2str(const.size_obst),'_st',num2str(const.size_tracer),...
        '_oe',num2str(modelopt.obst_excl),'_ng',...
        num2str(const.n_gridpoints),'_nt',...
        num2str(const.ntimesteps),'_t', num2str(trial)];
    filename=['data_',filestring,'.mat'];
    %fprintf(fileid,'%s',filename);
    
    %run the model!
    [tracer,obst] = diffusion_model(pvec,const,modelopt,filename);
    movefile(filename,'./runfiles');
    
end

fprintf('Completed run\n');
%elapsed_time=toc;
