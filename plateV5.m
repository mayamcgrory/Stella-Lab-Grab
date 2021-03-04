clear all; close all; clc
%% Part 1 Read in and process initial mass and time data
% Pre.txt is the raw pre-reading data and post.txt for the post-reading
% data. These will need to line up with an additional conditions file to
% append data appropriately for analysis

fds = fileDatastore('*pre.txt', 'ReadFcn', @importdata); 
fds2 = fileDatastore('*post.txt', 'ReadFcn', @importdata);
fds3 = fileDatastore('*cdns.xlsx','ReadFcn', @importdata);
fullFilePre = fds.Files;
fullFilePost = fds2.Files;
fullFileCdns = fds3.Files;
numFiles = length(fullFilePre);
% Prompt the user for how many conditions and to input the names of the
% conditions. This way we know the parameters to parse the data with.
cdnsnumber = inputdlg({'How many conditions would you like to display?'},'Conditions', [1 50]); 
        cdnsnumber = str2num(char(cdnsnumber));
        for i = 1: cdnsnumber
             cdnsName{i} = inputdlg({'What are the names of conditions?'},'Conditions', [1 50]); 
        end
title_name=input('Title? ','s')
cdnsName = string(cdnsName);
%This inital loop is to create text files that are associated with each
%individual experiment. In the text file there will be data in x columns
%for x conditions prompted. These files will go through the second part of
%this program with a series of analysis.
for k = 1:numFiles

    pre = read(fds);
    post = read(fds2);
    cdns = read(fds3);
    
    % Reading in the data
    x = pre.data;
    y = post.data;
    [rownum,colnum]=size(y);                                                    % Call the number of columns & rows
    
    %With how the reader sets up the columns. We want to take data from
    %array 3 to end as the numbers we'll be doing elemetary calculations
    %on.
    f= x(:,3:end);
    g= y(:,3:end);
    for i=1:colnum
          Mn = mean(f, 1);                                                  % Loop through to take the mean of the first four rows
          B = (g - Mn)./Mn;                                                 % Take A from columns 3 on to subtract Mn and divide.
    end
    
    %We read the time from array 4 to end - 2 and indicate the format so it
    %can read it as a datetime
    T = post.textdata(4:(end-2),1);
    Time = datetime(T,'InputFormat','mm:ss');
    
    %A small glitch not sure how to get around in a more efficent way.
    %Basically sometimes the last file has a time that is LESS than the max
    %time. So I won't be able to create PrismTable because of this, it
    %needs the max time so that I can create a buffered table etc. SO
    %what I did to fix this was grab a specific file for the time to
    %reference later.
    if k == 23
        Time2 = datetime(T,'InputFormat','mm:ss');
    end
    
    %Change the \ to / if running on a mac. This is to grab the appropriate
    %name as x so that I can name the output text file with the prefix
    x = fds.Files{k};
    name = strsplit(x, '\');
    name  = string(name{7});
    name = strsplit(name, '_');
    x = name(1);

     
%% Plot Prompt 
    B( :, all( isnan( B ), 1 ) ) = [];                                      %If there are nan values replace them with a blank
    C = reshape(B,rownum,3,[]);                                             %Reshape to take a mean between every 3rd column, this is how the reader
    D = mean(C,2);                                                          %Organizes readings. Seems to conventional.
    E = reshape(D,rownum,[]);
    
    [C,ia,idx] = unique(cdns(:,1),'stable');                                %Cool part! If there are repeating conditions we can combine them
    idxLength = max(size(idx));                                             %We use these to find the indexes of where the repeating condtions are
    
    for m = 1:rownum
    tableEE(:,m) = accumarray(idx,E(m,:),[],@mean);                         %Creating a new table where the repeating conditons are averaged and representative in a new
                                                                            %tableEE stored as E
    end
    E = tableEE';
    %% if cdns repeats take corresponding values in table E and average, this is new table E
    
    tableE = array2table(E);                                                %Now we take array to table and find the variable names
    vars = 1:width(tableE);                                                 %Renaming the columns in the table with the variable names(This is created by appending
    tableE = renamevars(tableE,vars,C');                                    %The conditions that the user inputed as cdns                     
    Date = table(Time);                                                     %Earlier we found Time as a datetime and we will attach this to the table
    PrismTable = [Date,tableE];                                             %Now we have a table fit to input data into PRISM
    clear tableEE

%     writetable(PrismTable, strcat(x,'_','PrismData.xlsx'));


       status = mkdir(title_name);                                          %Find the name so that later we can just pull all these into a new folder with
       status2 = fullfile(title_name);                                      %The title name that user was prompted for
        %% 
       D=zeros(max(size(T)),cdnsnumber);                                    %Create empty array to pad any data that is less than the max length
       D2=zeros(max(size(T)),1);                                            %We want to do this so we can output the data all as the same length otherwise
                                                                            %Matlab will freak out
       for o = 1:cdnsnumber
       index = find(strcmp(cdns,cdnsName(o)));                              %This is to go through and place zeroes where there is no data
       
       if index >= 1
           cdnsnewName{o}= cdnsName(o);
           cdnsnewName = [cdnsnewName{:}];
           T2 = table2array(PrismTable(:,cdnsnewName(:)))
           clearvars cdnsnewName;
           D(:,o) = T2;
       end 
       if isempty(index); 
           D(:,o) = D2
           continue
       end 
       end
       
        
        writematrix(D, strcat(x,'_',title_name,'data.txt'));
 
end


%% Averaging Files
        folder = pwd;
        txtFiles = dir(fullfile(folder,'*data.txt'));                      %load in/save text files saved from previous loop into struct
        numFiles;                                                          %number of files loaded

clearvars myData;

for m = 1:numFiles                                                        %myData holds all the imported data
     tx = txtFiles(m).name;
     myData{m} = [importdata(tx)];
end

%% need to load in data with vars so that we can average based on the name 
cnm = cdnsnumber - 1;
% sum(all(myDatas == 0)) 
for i = 1:numFiles
    myDatas = cell2mat(myData(i));                                          %This loop is to get rid of any data that only has one column of data for the control DMSO
    if sum(all(myDatas ==0)) < cnm
    Dsize = 181-max(size(myDatas));                                         %So if the data has less than cnm columns == 0, as in it has data for DMSO and another conditons
    Ddatas{i} = padarray(myDatas,[Dsize 0],0,'post');                       %Take it and pad the array for averaging later. But if it only has DMSO as in ==0 is greater than cnm
                                                                            %Skip. We don't want to average controls in an experiment that didn't run the conditions we're interested in.
    end
    if sum(all(myDatas == 0)) >= cnm
        continue
    end
     
end


%% Reshape data, average and created an avg Table

myData = cell2mat(Ddatas);
avgDatas = reshape(myData,181,cdnsnumber,[]);

avgData = sum(avgDatas,3) ./ sum(avgDatas~=0,3);

avgDataTable = cell2table(num2cell((avgData)));
avgDataTable.Properties.VariableNames = cdnsName;

%%find n

nvalue = myData(1,:)~=0;
nValue = reshape(nvalue,1,cdnsnumber,[]);
nValue = sum(nValue,3);
n = (reshape(nValue,1,[]));
m = zeros(cdnsnumber,181-1)';
n = cell2table(num2cell(vertcat(n,m)));


%find SEM
SD = std(avgDatas,[],3);
sdlength = max(size(SD));
SEM = SD./sqrt(sdlength);
SEMtable = cell2table(num2cell(SEM));
%% Find BASIL

DMSO = avgData(1:end,1);

for i = 1:cdnsnumber
    
    basil = avgData(:,i);
    
    t = basil < 0;
    basil(t) = basil(t) + DMSO(t);
    
    t2 = basil > 0;
    basil(t2) = basil(t2) - DMSO(t2);
    
basil2(:,i) = basil;
end
basil2(:,1) = 0;

basilTable = cell2table(num2cell(basil2));
%% Final Output Table with BASIL and SEM columns
%Name Columns of Table
for t = 1:cdnsnumber
%     nName(t,:) = [strcat("N count",num2str(t))];
    semName(t,:) = [strcat("SEM", num2str(t))];
    basilName(t,:) = [strcat("Basil", num2str(t))];

end

%Assign names to table
% n.Properties.VariableNames = nName;
SEMtable.Properties.VariableNames = semName;
basilTable.Properties.VariableNames = basilName;

%Create a final data table with the columns you'd like for each cndn
for t = 1:cdnsnumber
    dataTable{t} =[avgDataTable(:,t) basilTable(:,t) SEMtable(:,t)];
end


datasTable = cat(2, dataTable{:});

%% DOSE RESPONSE
%Dose Response AVG Table
drTime = table(Time2);
drTable = [drTime,datasTable];
writetable(drTable, strcat(title_name,'_','kinetic.xlsx'));

%For mean of response and mean of SD new table
drTable2 = [drTime,avgDataTable];

%% MOA
%MOA AVG Table
fourMin = ismember(Time2, datetime('00:04:00'));
fourMin2 = find(fourMin, 1);
fiveMin = ismember(Time2, datetime('00:05:00'));

fiveMin2 = find(fiveMin, 1);
moaTable = drTable(fourMin2:fiveMin2,:);

%MOA STD & MEAN Table
avgResponse = table(mean(basilTable{fourMin2:fiveMin2,:},1)');
avgResponse.Properties.VariableNames = {'Mean Basil'};

meanSEM = table(mean(SEMtable{fourMin2:fiveMin2,:},1)');
meanSEM.Properties.VariableNames = {'Mean(SEM)'};

cdnsMOA = table(cdnsName');
cdnsMOA.Properties.VariableNames = {'Conditions'};

MOATable = [cdnsMOA avgResponse meanSEM];
writetable(MOATable, strcat(title_name,'_','5-Min.xlsx'));
%% PLOT averages

%OG Avg Table
% dataTable = horzcat(dataTable{:});
% writetable(dataTable, strcat(title_name,'Avg_Data.xlsx'));


        fig = figure(1);
        lineProps.col{1}=[1 0 0];
        plot(Time2, avgData);


        hold on;
        title(strcat('Avg',title_name));
        legend(cdnsName,'Location','northeast');
        xlabel('Time (MM:SS)');
        hold off 
        saveas(fig, strcat(title_name, '.pdf'));
%% Move all files containing title name to title name folder
        
movefile(['*',title_name,'*'],status2);



