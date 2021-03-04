folder = pwd;
        cdnsFiles = dir(fullfile(folder,'*cdns.xlsx'));             %load in/save files into struct
        numFiles = length(cdnsFiles);                                  %number of files loaded

clearvars myData

for  m = 1:numFiles; 
     tx = cdnsFiles(m).name
     cdns{m} = [importdata(tx)];
     
%      folderName{m} = getAttachedFilesFolder(cdns})
end

listCdns = vertcat(cdns{:})

%Get rid of repeating elements
[b,m1,n1] = unique(listCdns,'first');


%Find the number of occurences for each condition
freq=hist(n1,(1:numel(m1))')'

%% 
for m = 1:numFiles;
    tx = cdnsFiles(m).name
    cdns{m} = [importdata(tx)];
    B =  convertCharsToStrings(tx);
    hist{m}=repmat(B,length(cdns{m}),1);
end
%% 

j = vertcat(hist{:});
% fld = j(n1);
% if b = listCdns(ml)
fldName = j(m1);
% fldName = fld(m1);
count = [b num2cell(freq) fldName]
%% Write File

xlswrite('count_cdns.xlsx',count)