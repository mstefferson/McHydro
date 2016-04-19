%   MDB 9/28/15 specialized to immobile obstacles, noninteracting tracers
%   so that moves can be done in parallel
%   MDB 9/28/15 set up to loop over parameters with parfor
%  LEH vary binding energies, with each file having a different filling
%  fraction
% MWS made edits to wrapper function to avoid having to copy and paster things

%tic;
% clear all;
%close all;

StartTime = datestr(now);
fprintf('In run_bindobs, %s\n', StartTime);
%load params. check if it exists, if not, run it
[status, result] =  system('ls Params.mat');
if status == 1
    paramsinit_bindobs
end
load Params.mat;

%display everything
fprintf('parameters read in\n');
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
RunTimeID = tic;

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
RunTime = toc(RunTimeID);
fprintf('Run time %.2g min\n', RunTime / 60);
EndTime = datestr(now);
fprintf('Completed run: %s\n',EndTime);
%elapsed_time=toc;
