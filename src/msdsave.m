function [ output_args ] = msdsave( filename, msd, dtime,  ...
        const, modelopt, obst, paramlist, tracer)
%msdsave Very simple function to write msd to file within a parfor. 
%   Detailed explanation goes here

save(filename,'msd','dtime', 'const', 'modelopt', 'obst',...
    'paramlist','tracer');
end

