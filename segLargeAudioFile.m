% take in large audio files and split them into ordered 1-hr files (plus a
% remainder file.  M. VanDam   labs.wsu.edu/vandam  January 2016 

clear all;
fname = input('\n\n\n\n   Enter directory where files are stored: ', 's');
[y, Fs] = audioread(fname);
seconds = length(y)/Fs;
minutes = seconds/60;
hours   = minutes/60;
[pathstr,name,ext] = fileparts(fname);
dirOut = pathstr;

for j = 1:floor(hours)
    sampPerHour = 5.76e7;
    s1=sampPerHour*(j-1) + 1;
    s2=sampPerHour*j;
    s1 = int64(s1); s1 = double(s1);
    s2 = int64(s2); s2 = double(s2);    
    [cWav Fs] = audioread(fname, [s1 s2]);
    audiowrite([dirOut '\' name '_h' num2str(j) '.wav'], cWav, Fs);
end
[cWav Fs] = audioread(fname, [(s2) (length(y))]);
audiowrite([dirOut '\' name '_h' num2str(j+1) '.wav'], cWav, Fs);