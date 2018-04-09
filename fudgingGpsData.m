% Script written by MTP on 09/04/2018 for bringing elevation data from 2016 and 2018
% surveys conducted in Morocco in line with those of 2012. This script
% requires the Mapping Toolbox (4.5.1 or later) to work.

% Example command to run the script:
% fudgingGpsData ('\\campus\home\home37\nmp65\Desktop\Morocco GIS Data')
% this would process all shapefiles found within the Morocco GIS Data
% folder and subsequent subfolders.

function [] = fudgingGpsData (folderIn)
allSubFolders = genpath(folderIn);% Get list of all subfolders.
remain = allSubFolders;% Parse into a cell array.
listOfFolderNames = {};

while true
	[singleSubFolder, remain] = strtok(remain, ';');
	if isempty(singleSubFolder)
		break;
	end
	listOfFolderNames = [listOfFolderNames singleSubFolder];
end

numberOfFolders = length(listOfFolderNames);
for k = 1 : numberOfFolders% Process all text files in those folders.
	thisFolder = listOfFolderNames{k};	% Get this folder and print it out.
	filePattern = sprintf('%s/*.shp', thisFolder);	% Get filenames of all shp files.
	baseFileNames = dir(filePattern);
	numberOfFiles = length(baseFileNames);
	% Now we have a list of all shapefiles in this folder.
	
	if numberOfFiles >= 1
		% Go through all those shapefiles files.
		for f = 1 : numberOfFiles
			fullFileName = fullfile(thisFolder, baseFileNames(f).name);
			fprintf('     Processing shapefile %s\n', fullFileName);
            if strcmp(fullFileName(end-9:end),'fudged.shp') == 1
                break % break loop if file has already been processed
            end
            try
                [S,A] = shaperead(fullFileName); % Read in the shapefile
                aModifiedFinal = A; % Create a duplicate of the attributes
                for a = 1:length(A)
                    C(a,1:3) = str2double(strsplit(A(a).projected,' ')); % Pull out the attributes
                    [S(a).X_out] = deal(S(a).X);% Add x to attribute table
                    [S(a).Y_out] = deal(S(a).Y);% Add y to attribute table
                    [S(a).Z_out] = deal(C(a,3) - 41.3);% Apply the offset to the z value
                    [S(a).name] = deal(A(a).name);% Add the point name
                    [S(a).antenna_height] = deal(A(a).antennaHe);% Add the antenna height
                    [S(a).lateral_rms] = deal(A(a).lateralRm);% Add the lateral rms
                    [S(a).rms] = deal(A(a).rms);% Add the rms
                    [S(a).sample_count] = deal(A(a).sampleCou);% Add the occupation time
                    [S(a).solution_type] = deal(A(a).solutionS);% Add the solution type
                end
            catch
                fprintf('Looks like this is not a 2D shapefile - ignoring')
            end
            shapewrite(S,strjoin({char(fullFileName(1:end-4)), 'fudged'},'_'))
		end
	end
end