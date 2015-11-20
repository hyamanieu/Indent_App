function [Result, rlegend, tlegend, tests] = ImportXls(filename)
%Import Nanoindetation data from xls or csv files to matlab arrays
%   [Result, rlegend, (tlegend), (tests)] = ImportXls(filename) imports the data from
%   the excel or csv file 'filename' and deals the different summary results in
%   the 'Result' array, the legend of the summary results in the 'rlegend'
%   array and the test data in the tests cell with its legend in the
%   tlegend cell. Importing tests is optional and take some time.
%   If csv is used, please target Result.csv, the function will detect the tests files.
%
%   /!\Note: importing tests takes less time with csv files.
%
%   version: 1.1d
%   Copyright 2015 Hugues-Yanis Amanieu
%    Licensed under the Apache License, Version 2.0 (the "License");
%    you may not use this file except in compliance with the License.
%    You may obtain a copy of the License at
%
%      http://www.apache.org/licenses/LICENSE-2.0
%
%    Unless required by applicable law or agreed to in writing, software
%    distributed under the License is distributed on an "AS IS" BASIS,
%    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%    See the License for the specific language governing permissions and
%    limitations under the License.

%Checks if 3 variables are given instead of 2 or 4.
if nargout==3
    error('You specified 3 variables. Please specify a fourth variable for the tests.');
end

%Get information concerning excel sheet.
if ~strcmpi(filename(end-3:end),'.CSV')
    [status, sheets, ~]=xlsfinfo(filename);
    if strcmp(status,'')
        error('Not an excel sheet or csv. Please insert an excel sheet or csv.');
    end
end



if strcmpi(filename(end-3:end),'.CSV')
    fid=fopen(filename);
    rlegend=fgetl(fid);%read legends
    fgetl(fid);%jump units
    
    %line format
    DataPos=ftell(fid);
    FirstLine=fgetl(fid);
    [~,noMatch]=regexp(FirstLine,',','match','split');%in future Matlab version, regexp can be replaced by strsplit.
    [A, status]=cellfun(@str2num,noMatch,'UniformOutput',0);
    A=cell2mat(A);
    status=cell2mat(status);
    format=num2str(status);
    format=strrep(format,'1','%f');
    format=strrep(format,'0','%*s');
    
    %data formatting
    fseek(fid,DataPos,'bof');%return to beginning of data
    nLines = 0;
    while (fgets(fid) ~= -1)%count number of lines
        nLines = nLines+1;
    end
    fseek(fid,DataPos,'bof');%return to beginning of data
    Result=zeros(nLines-3,length(A));
    for i=1:nLines-3;
        Result(i,:)=cell2mat(textscan(fgetl(fid),format,'Delimiter',',','EmptyValue', NaN,'CollectOutput',1));
    end
    
    %legend formatting
    [~,rlegend]=regexp(rlegend,',','match','split');
    rlegend=rlegend(status);
    fclose(fid);
    if nargout==2%Import tests?
        return
    end    
    if ispc
        PosName = strfind(filename,'\');
    else
        PosName = strfind(filename,'/');
    end
    
    Folder =filename(1:PosName(end));
    Files = ls(Folder);
    TestNumb=length(cell2mat(strfind(cellstr(Files),'Test ')));
    
    h=waitbar(0,'Importing test sheets');
    tests=cell(TestNumb,1);
    
    %process each Data
    for i=1:TestNumb
        Testname = [Folder,'Test ',sprintf('%03d',i),'.csv'];
        A=importdata(Testname);
        A.data(A.data>1e90)=NaN;%Big values are actually no value.
        tests{i}=A.data;
        
        waitbar(i /TestNumb,h,sprintf('Sheet %d of %d processed',round(i),round(TestNumb)));
    end
    
    
    %save tlegend
    tlegend=A.textdata(1:2,:);
    %[iscoma,noMatch]=regexp(tlegend{1},',','match','split');
    [iscoma,noMatch]=regexp(tlegend{1},',(?=\S|$)','match','split');%Update 2014_06_10: doesn't match comas followed by space. Useful for tests on thin film: a coma_space is used in some columns.
    if ~isempty(iscoma)%bug in import?
        tlegend(1,:)=noMatch(cellfun(@(x) ~isequal(x,''), noMatch));
    end
    
    %Calculate Stiffness Over Load
    if ~any(any(strcmpi('Stiffness Squared Over Load',tlegend)))
        [~,LCol]=find(strcmp('Load On Sample',tlegend));
        [~,SCol]=find(strcmp('Harmonic Contact Stiffness',tlegend));
        [~,ECol]=find(strcmp('Modulus',tlegend));
        if SCol
            tlegend{1,end+1}='P/(S*S)';
            tlegend{2,end}='1/mPa';
            for i=1:TestNumb
                tests{i,1}(:,end+1)=tests{i,1}(:,LCol)./(tests{i,1}(:,SCol).^2);
                tests{i,1}(isnan(tests{i,1}(:,ECol)),end)=NaN;
            end
        end
    end
    
    close(h);
    
  
    
else %for xls files
    %take data summary sheets
    [Result, rlegend, raw]=xlsread(filename,'Results');
    Result=Result(1:end-3,:);%Deletes statistic data given by Nanosuite.
    rlegend=rlegend(1:2,:);
    raw=raw(3,:);
    rlegend=rlegend(1,cellfun(@isnumeric,raw));%deletes non-numeric columns
    
    RCol=true(1,size(Result,2));
    for i=1:size(Result,2) %deletes non-numeric columns
        if all(isnan(Result(:,i)))
            RCol(i)=false;
        end
    end
    
    Result=Result(:,RCol);
    
    
    %     while size(rlegend,2) > size(Result,2) %Deletes the first terms in the legend which correspond to no data.
    %         rlegend(:,1)=[];
    %     end
    
    %Make an array of data for each test in the test cell.
    if nargout==4
        h=waitbar(0,'Importing test sheets');
        
        %Unload=[]
        TestPos=strfind(sheets,'Test ');
        TestPos=find(~cellfun(@isempty,TestPos));
        tests=cell(length(TestPos),1);
        EndOfLoad=zeros(length(TestPos),1);
        
        
        for i=1:length(TestPos)
            [tests{i},tleg,Search]=xlsread(filename,sheets{TestPos(i)});
            [row,~]=find(strcmp('Hold Segment Type',Search));%Search line where load stops
            if ~isempty(row)
                EndOfLoad(i)=row-2;%-2 due to the legend in the XLS file.
            end
            
            waitbar(i/length(TestPos),h,sprintf('Sheet %d of %d processed',i,length(TestPos)));
        end
        tlegend=tleg(1:2,:);

        close(h);
        if ~all(EndOfLoad==0)%Check if CSM or no CSM. If no-CSM, will save index of end of loading.
            Result(:,end+1)=EndOfLoad;
            rlegend{1,end+1}='End of load index';
        end
        tlegend=tlegend(1:2,cellfun(@isnumeric,Search(3,:)));%deletes non-numeric columns
        tests=cellfun(@TooBig ,tests, 'UniformOutput', false);
        if ~any(any(strcmpi('Stiffness Squared Over Load',tlegend)))
            [~,LCol]=find(strcmp('Load On Sample',tlegend));
            [~,SCol]=find(strcmp('Harmonic Contact Stiffness',tlegend));
            [~,ECol]=find(strcmp('Modulus',tlegend));
            if SCol
                tlegend{1,end+1}='P/(S*S)';
                tlegend{2,end}='1/kPa';
                for i=1:length(TestPos)
                    tests{i,1}(:,end+1)=tests{i,1}(:,LCol)./(tests{i,1}(:,SCol).^2);
                    tests{i,1}(isnan(tests{i,1}(:,ECol)),end)=NaN;
                end
            end
        end
        
    end
end
end

function D = TooBig(A)
D=A;
D(D>10^10)=NaN;
end