%   MDB 9/28/15 specialized to immobile obstacles, noninteracting tracers
%   so that moves can be done in parallel
% LEH 1/31/16 set up to run parfor with new computeMSD function.
%clear all;
%close all;
%set(0, 'DefaultFigureWindowStyle', 'docked')

%%% COPY first portion of run program here

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
const.ntimesteps=1e2;       %number of timesteps NOte 1e5 gives errors on my laptop. 
% const.ntimesteps=1e2;       %number of timesteps
       
%other constants and model options
const.size_obst=1;      %obstacle linear dimension, MUST BE odd integer
const.size_tracer=1;     %tracer linear dimension, MUST BE odd integer
modelopt.obst_excl=1;       %1 if obstacles sterically exclude each other, 0 if not
modelopt.tracer_excl=0;     %MUST BE 0 so tracers don't interact (ghosts)
modelopt.obst_trace_excl=1;  %1 if obstacles and tracers mutually exclude
modelopt.dimension=2; %system dimension, currently must be 2

%%%% END of copy from run program

% Deff=zeros(size(ffvec));
% Deff_err=Deff;
% beta=Deff;
% beta_err=Deff;
% slidevec=0;
nparams=length(bind_energy_vec);

tic

for j=1:nparams  
%for j=1
    bind_energy = bind_energy_vec(j);
    filestring=['bar',num2str(slide_barr_height),'_bind',num2str(bind_energy),...
        '_fo',num2str(ffrac_obst),'_ft',num2str(ffrac_tracer),'_so',...
        num2str(const.size_obst),'_st',num2str(const.size_tracer),...
        '_oe',num2str(modelopt.obst_excl),'_ng',...
        num2str(const.n_gridpoints),'_nt',num2str(const.ntimesteps)];
    filename=['data_',filestring,'.mat'];
    S = load(filename);
    
     %test calling msd function
    [msd,dtime]=computeMSD(S.tracer_cen_rec_nomod);

    msdfilename=['msd_',filestring,'.mat'];
    msdsave(msdfilename, msd, dtime, slide_barr_height, ffrac_obst, bind_energy,...
        ffrac_tracer, const, modelopt);
    
end

end_time = toc

    %   HOW IT IS ALL DEFINED:
%         msd_distrib(dt,:) = [mean(squared_dis(:)); ... % average
%         std(squared_dis(:)); ...; % std
%         length(squared_dis(:)); ... % n (how many points used to compute mean)
%     	mean(quartic_dis(:)); ... %average
%     	std(quartic_dis(:))]'; %std
