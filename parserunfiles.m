% parserunfiles.m
% Description: parse all the files in the runfiles folder to be
% used by the analysis program

function [FileCell] = parserunfiles()
% Get the long vector list of runfiles
FileListVec = ls('./runfiles');

% Find the blanks which tells you when we have a new file
Blanks = find( isspace(FileListVec) );
NumFiles = length(Blanks);

% Add a 0 to start of blanks for first file. This helps with pulling
% out the file names in the upcoming for loop
Blanks = [0 Blanks];

% Make sure your analyzing something
if NumFiles == 0
  error('There are no files to analyze')
end

% Make cell array to store these files names
FileCell = cell(NumFiles,1);

% Put all the files in the cell. Dance around the blanks
for i = 1:NumFiles
  FileCell{i} =  FileListVec( Blanks(i) + 1 : Blanks(i+1)-1 );
end
