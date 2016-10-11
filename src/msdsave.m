function [ output_args ] = msdsave( filename, msd, dtime,  ...
  const, modelopt, obst, paramlist, tracer, occupancy)
%msdsave Very simple function to write msd to file within a parfor.
%   Detailed explanation goes here
if nargin == 8
  save(filename,'msd','dtime', 'const', 'modelopt', 'obst',...
    'paramlist','tracer');
elseif nargin == 9
  save(filename,'msd','dtime', 'const', 'modelopt', 'obst',...
    'paramlist','tracer','occupancy');
end
end

