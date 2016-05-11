% parserunfiles.m
% Description: parse all the files in the runfiles folder to be
% used by the analysis program

function [FileCell] = parserunfiles()
% Get the long vector list of runfiles
 
  % Make sure your analyzing something
if ~isempty( dir('./runfiles/data*') );
    cd ./runfiles
    FileListVec = ls('data*');
    cd ../
    % Find the blanks which tells you when we have a new file
    Blanks = find( isspace(FileListVec) );
    NumFiles = length(Blanks);
    
    % Add a 0 to start of blanks for first file. This helps with pulling
    % out the file names in the upcoming for loop
    Blanks = [0 Blanks];

    % Make cell array to store these files names
    FileCell = cell(NumFiles,1);
    fprintf('%d files in ./runfiles\n', NumFiles);
    
else
    NumFiles = 0;
    FileCell = cell(0,1);
    fprintf('No files to analyze in ./runfiles\n');
end


% Put all the files in the cell. Dance around the blanks
for i = 1:NumFiles
    FileCell{i} =  FileListVec( Blanks(i) + 1 : Blanks(i+1)-1 );
end

% There is a chance of empty cells. Get rid of them
CellTemp = cell( NumFiles, 1 );

counter = 0;
for i = 1:NumFiles
  if ~isempty( FileCell{i} )
    counter = counter + 1;
    CellTemp{counter} = FileCell{i};
  end
end

FileCell = cell( counter , 1 );

for i = 1:counter
  FileCell{i} = CellTemp{i};
end

NumFiles = counter;
