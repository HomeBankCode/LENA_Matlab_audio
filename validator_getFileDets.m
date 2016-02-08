% generate a random ordering of WAV files in a directory and get some basic stats about those files
% M. VanDam   12/12/12   labs.wsu.edu/vandam
close all; clear all;
dstart = pwd;
dname = uigetdir('/Users/', 'Pick the directory.');
cd(dname);
%get all the WAVs in some directory
clear sName1 sName2
dirFs = ls; kwIndx=0;

for kw = 1:length(dirFs(:,1))
    rowkw = dirFs(kw,:);
    if strfind(rowkw, '.wav')
        kwIndx = kwIndx+1;
        sName1{kwIndx} = deblank(dirFs(kw,:));
    end
end
%reorder randomly
sOrd = randperm(length(sName1));
for hw = 1:length(sName1)
    sName2{hw} = sName1{sOrd(hw)};
end
save sName2 sName2
load sName2
x=[];
for jw = 1:length(dirFs-3)
    clc
    [y fs] =audioread(sName2{jw});
    x = [x length(y)/fs];
end
disp(['mean is ' num2str(mean(x)*1000) ' std dev is ' num2str(std(x)*1000) ' range is ' num2str(min(x)*1000) '-' num2str(max(x)*1000)])
disp('goodbye')
cd(dstart);

