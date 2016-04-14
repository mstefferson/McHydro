%   MDB 9/28/15 specialized to immobile obstacles, noninteracting tracers
%   so that moves can be done in parallel
%   MDB 9/28/15 set up to loop over parameters with parfor
% LEH vary binding energies, with each file having a different filling
% fraction

%tic;
% clear all;
%close all;

%%%%%%%% Beginning of section to copy to analyze script. 

%key parameters and constants
slide_barr_height=0;    %barrier height to sliding, in kT
%bind_energy=-20;         %binding energy of tracers to obstacles, in kT
bind_energy_vec = logspace(-5,5,32);
ffrac_obst=0.3;         %filling fraction of obstacles
%ffvec=[0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9];
% ffvec=[0 0.1 0.2];
ffrac_tracer=0.5;       %filling fraction of tracers
const.n_gridpoints=100;    %number of grid points, same in x and y
% const.n_gridpoints=10;    %number of grid points, same in x and y
const.ntimesteps=3e5;       %number of timesteps NOte 1e5 gives errors on my laptop. 
% const.ntimesteps=1e2;       %number of timesteps
       
%other constants and model options
const.size_obst=1;      %obstacle linear dimension, MUST BE odd integer
const.size_tracer=1;     %tracer linear dimension, MUST BE odd integer
modelopt.obst_excl=1;       %1 if obstacles sterically exclude each other, 0 if not
modelopt.tracer_excl=0;     %MUST BE 0 so tracers don't interact (ghosts)
modelopt.obst_trace_excl=1;  %1 if obstacles and tracers mutually exclude
modelopt.dimension=2; %system dimension, currently must be 2

%%% END of section to copy to analyze script. %%%%%%%


const.nequil=0;           %number of timesteps for initial equilibration

modelopt.animate=0;          %1 to show animation, 0 for no animation
modelopt.tpause=0.0;         %pause time in animation, 0.1 s is fast, 1 s is slow
modelopt.movie=0;           %1 to record movie

nparams=length(bind_energy_vec);
parfor j=1:nparams
    bind_energy = bind_energy_vec(j);
    pvec=[ffrac_obst ffrac_tracer slide_barr_height bind_energy]; %parameter vector

    filestring=['bar',num2str(slide_barr_height),'_bind',num2str(bind_energy),...
    '_fo',num2str(ffrac_obst),'_ft',num2str(ffrac_tracer),'_so',...
    num2str(const.size_obst),'_st',num2str(const.size_tracer),...
    '_oe',num2str(modelopt.obst_excl),'_ng',...
    num2str(const.n_gridpoints),'_nt',num2str(const.ntimesteps)];
    filename=['data_',filestring,'.mat'];
    
    %run the model!
    [tracer,obst] = diffusion_model(pvec,const,modelopt,filename);
    
end
%elapsed_time=toc;
