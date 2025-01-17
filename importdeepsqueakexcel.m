% Specify the folder where the files live.

myFolder = uigetdir;
while ~isfolder(myFolder)
    errorMessage = sprintf('Error: The following folder does not exist:\n%s\nPlease specify a new folder.', myFolder);
    uiwait(warndlg(errorMessage));
    myFolder = uigetdir(); % Ask for a new one.
end

% Get a list of all files in the folder with the desired file name pattern.

% you can use getAllFiles(dir,extension), this should help there with
% nested folders
filePattern = fullfile(myFolder, '*.xlsx'); % Change to whatever pattern you need.
theFiles = dir(filePattern);

%% Initialize table options
%{
opts = spreadsheetImportOptions("NumVariables", 16);

% Specify column names and types
opts.VariableNames = ["Call_ID", "Label", "Accepted", "Score", "BeginTimes", "EndTimes", "CallLengths", "PrincipalFrequencykHz", "LowFreqkHz", "HighFreqkHz", "DeltaFreqkHz", "FrequencyStandardDeviationkHz", "SlopekHzs", "Sinuosity", "MeanPowerdBHz", "Tonality"];
opts.VariableTypes = ["double", "double", "string", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];

% Specify variable properties
opts = setvaropts(opts, "Accepted", "WhitespaceRule", "preserve");
opts = setvaropts(opts, "Accepted", "EmptyFieldRule", "auto");
opts.DataRange='A2';
%}

opts = spreadsheetImportOptions("NumVariables", 16);

% Specify sheet and range
opts.Sheet = "Sheet1";
opts.DataRange = "A2:P369";

% Specify column names and types
opts.VariableNames = ["ID", "Label", "Accepted", "Score", "BeginTimes", "EndTimes", "CallLengths", "PrincipalFrequencykHz", "LowFreqkHz", "HighFreqkHz", "DeltaFreqkHz", "FrequencyStandardDeviationkHz", "SlopekHzs", "Sinuosity", "MeanPowerdBHz", "Tonality"];
opts.VariableTypes = ["double", "categorical", "string", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];

% Specify variable properties
opts = setvaropts(opts, "Accepted", "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["Label", "Accepted"], "EmptyFieldRule", "auto");

%% Read in the first file to create a table to start with

combined_usvs = readtable(theFiles(1).name, opts, "UseExcel", false);

[pd, animal_id] = scrape_fileinfo(theFiles(1));
if isempty(pd)
    [pd, animal_id] = scrape_fileinfo2(theFiles(1));
end
    day_vec = repmat(str2double(pd),height(combined_usvs),1);
    id_vec = repmat(animal_id,height(combined_usvs),1);
    
    combined_usvs.day=day_vec;
    combined_usvs.ratID=id_vec;


%% Loop through folder and add all other files to the big table

for k = 2:length(theFiles)
    baseFileName = theFiles(k).name;
    fullFileName = fullfile(theFiles(k).folder, baseFileName);
    fprintf(1, 'Now reading %s\n', fullFileName);
    
    [pd,animal_id] = scrape_fileinfo(theFiles(k));
    if isempty(pd)
        [pd, animal_id] = scrape_fileinfo2(theFiles(k));
    end
    file_stats = readtable(theFiles(k).name, opts, "UseExcel", false);
    day_vec = repmat(str2double(pd),height(file_stats),1);
    id_vec = repmat(animal_id,height(file_stats),1);
    
    file_stats.day=day_vec;
    file_stats.ratID=id_vec;


    combined_usvs = [combined_usvs; file_stats];
end

%% lookup table for which animals are which genotype

lookuptable={'FF','FR','BR','BB','LL','BL','FL','RR';...
            'wt','het','fx','wt','wt','wt','het','wt';...
            'm', 'f', 'm', 'm', 'f', 'm', 'f', 'm';...
            '320','321','322','323','324','325','326','327'};
        
        % strcmpi strfind find contains 
for i=1:height(cohort2_full)
    tablematch=find(contains(lookuptable(1,:),cohort2_full.ratID(i,2:end)));
     cohort2_full.Genotype(i)=lookuptable(2,tablematch);
     cohort2_full.ratSex(i)=lookuptable(3,tablematch); 
     cohort2_full.ratNumber(i)=lookuptable(4,tablematch);  
     cohort2_full.cohort(i)=2;
end
        

%%

cohort1_lookuptable= {'1FL', '2FFLL', '1BL', '2FLBR', '2FRBL', '2LL', '1FR', '3FFLL', '2RR', '2BB', '1BR', '3FFRR';...
                      'fx', 'fx', 'wt', 'fx', 'wt', 'wt', 'fx', 'het', 'wt', 'wt', 'het', 'fx';...
                      'm',  'm', 'm', 'm', 'f', 'f', 'm', 'f', 'f', 'f', 'f', 'f';...
                      '301', '302', '303', '304','305', '306', '307','308', '309', '310', '311', '312'}; 
                  
 for i=1:height(cohort1_full)
     cellname= char(cohort1_full.ratID(i));
     tablematch=find(contains(cohort1_lookuptable(1,:), cellname));
     cohort1_full.Genotype(i)=cohort1_lookuptable(2,tablematch);
     cohort1_full.ratSex(i)=cohort1_lookuptable(3,tablematch);
     cohort1_full.ratNumber(i)=cohort1_lookuptable(4,tablematch);
     cohort1_full.cohort(i)=1; 
 end  
cohort1_full.Day=str2double(cohort1_full.Day);
                  
%% 
cohortfull=[cohort1_full; cohort2_full];
cohortfull(isnan(cohortfull.CallLengths),:)=[];
cohortfull.ratNumber=str2double(cohortfull.ratNumber);


        
