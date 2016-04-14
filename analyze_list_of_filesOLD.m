function [] = analyze_list( listfile )
% TO run, the argument is a text file with the list of file names to be analyzed. 
%   MDB 9/28/15 specialized to immobile obstacles, noninteracting tracers
%   so that moves can be done in parallel
% LEH 1/31/16 set up to run parfor with new computeMSD function.
%clear all;
%close all;
%set(0, 'DefaultFigureWindowStyle', 'docked')

fileid = fopen(listfile)

% Deff=zeros(size(ffvec));
% Deff_err=Deff;
% beta=Deff;
% beta_err=Deff;
% slidevec=0;


tic
filename = fgetl(fileid);
while filename~=-1;
     
     S = load(filename);


     %test calling msd function
    [msd,dtime]=computeMSD(S.tracer_cen_rec_nomod);

    msdfilename=['msd_',filename,'.mat'];
    msdsave(msdfilename, msd, dtime, slide_barr_height, ffrac_obst, bind_energy,...
        ffrac_tracer, const, modelopt);
    
    filename = fgetl(fileid);
end

end_time = toc

    %   HOW IT IS ALL DEFINED:
%         msd_distrib(dt,:) = [mean(squared_dis(:)); ... % average
%         std(squared_dis(:)); ...; % std
%         length(squared_dis(:)); ... % n (how many points used to compute mean)
%     	mean(quartic_dis(:)); ... %average
%     	std(quartic_dis(:))]'; %std
