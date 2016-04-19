% MWS edited original analyze program written by MB and LH to be more general  
%clear all;
%close all;

%make output directories if they don't exist
if exist('msdfiles','dir') == 0; mkdir('msdfiles');end;

% Get all the files you want to analyze
Files2Analyze = parserunfiles;
NumFiles = size(Files2Analyze,1);

tic

fprintf('Starting analysis\n');
for j=1:NumFiles  
   
     % Grab a file
     filename = Files2Analyze{j};

     % Put all variables in a struct
     S = load( ['./runfiles/' filename] );
 
     %test calling msd function
    [msd,dtime]=computeMSD(S.tracer_cen_rec_nomod);

    msdfilename=['msd_',filename(6:end)];
    %msdsave(msdfilename, msd, dtime, slide_barr_height, ffrac_obst, bind_energy,...
        %ffrac_tracer, const, modelopt);
    msdsave(msdfilename, msd, dtime, S.const, S.modelopt, ...
        S.obst, S.paramvec, S.tracer);
    movefile(msdfilename, './msdfiles');
 
end

end_time = toc;

fprintf('Finished analysis\n');


    %   HOW IT IS ALL DEFINED:
%         msd_distrib(dt,:) = [mean(squared_dis(:)); ... % average
%         std(squared_dis(:)); ...; % std
%         length(squared_dis(:)); ... % n (how many points used to compute mean)
%     	mean(quartic_dis(:)); ... %average
%     	std(quartic_dis(:))]'; %std
