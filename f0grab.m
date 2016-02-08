% This script takes as input LENA-gerenated .WAV files and the
% ADEX-generated .CSV file specified with all parameters at the
% Vocalization Activity Block level.  This uses X. Sun's pitch
% determination algorithm SHRP
% (http://www.mathworks.com/matlabcentral/fileexchange/1230-pitch-determination-algorithm/content/shrp.m),
% but any could be substituted.  Once F0 values are estimated (here only
% for the CHN segments), various methods of interpreting those values are
% given: Snow, Hunter, D'Odorico & Franco.  Results are saved in a data
% file.
% M. VanDam 18 March 2010, www.vanDamMark.com
clear all;
tic
today = date;
progress = [ '|' '/' '-' '\' '|' '/' '-' '\'];
directory = 'G:\scratch\f1';
disp(['current directory is ', directory])
dirQuest = input(['Blank to continue, or ''n'' for difft dir: ',], 's');
if dirQuest == 'n'
    directory = input('enter the desired DIR:', 's');
else
end
cd(directory);
filesDat = dir('*.csv');
filesWav = dir('*.wav');

rate = 16000;
F0MinMax = [200 600]; %might want to change this
frame_length = 40; % in ms
TimeStep = 3; % in ms
SHR_Threshold = 0.4; %range 0:1
Ceiling = 1250;
med_smooth = 0;
CHECK_VOICING = 1;
rep = 0; rep2=0;
Y=[]; hunter=[];
for j = 1 : length(filesDat)
    fnDat = filesDat(j).name;
    fid = fopen(fnDat);
    %%%%%%%%%%%%%%%%%   1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 %%
    C = textscan(fid, '%f %s %s %s %s %f %f %f %s %s %s %s %s %f %s %s %f %s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %s %f %f %f %s %s %f %s %s %f %f %s %s', ...
        'HeaderLines', 1, 'delimiter', ',' ,'emptyValue', -Inf);
    tElapsed = C{42};
    talker = C{50};
    recording = C{41};
    segDuration = C{49};
    blockType = C{47};
    fNameSource = C{4};
    chKey = C{11};
    chID = C{12};
    chAge = C{14};
    chSex = C{15};
    tOfDay = C{43};
    yvals=[];
    %%
    if recording(1) ~= recording(length(recording))
        zs=[]; yIndx=[];
        for ix = 2:length(tElapsed)-1
            if recording(ix) ~= recording(ix+1)
                y = ix; % index of last line in recording
                z = 0;
                while segDuration(y) == segDuration(y-z)
                    z = z + 1; % number of lines in last block
                end
                z = z - 1;
                zs = [zs z];
                yIndx = [yIndx y]; % indexes of last lines of recordings
            end
        end
        for jx = 1:length(zs)
            yVals(yIndx(jx)) = tElapsed(yIndx(jx)-zs(jx)) + segDuration(yIndx(jx)-zs(jx)+1);
        end
        yVals = nonzeros(yVals);
        for kx = 2:length(yVals)
            yVals(kx) = yVals(kx) + yVals(kx-1);
        end
        yVals = [0 yVals'];
        yIndx = [1 yIndx length(tElapsed)];
        tElapsedNew = tElapsed;
        for lx = 1:length(yVals)
            yMat(lx).vals = tElapsed + yVals(lx);
        end
        yNew = yMat(1).vals(yIndx(1):yIndx(2));
        for mx = 2:length(yMat)
            yNew = [yNew; yMat(mx).vals(yIndx(mx)+1:yIndx(mx+1))];
        end
        tElapsed = yNew;
    end
    %%
    fnWav = filesWav(j).name;
    clear C
    for i = 1: length(talker)-1
        if talker{i} == 'CHN'
            rep = rep + 1;
            t1 = tElapsed(i);
            t2 = tElapsed(i+1);
            durSeg = (t2-t1) * 1000; % rendered in MS
            s1 = (t1 * rate) - 80; % 80 samples is 5ms
            s2 = (t2 * rate) + 80;
            s1 = int64(s1); s1 = double(s1);
            s2 = int64(s2); s2 = double(s2);
            cWav = wavread(fnWav, [s1 s2]);
            [f0t, f0] = shrp(cWav,rate,F0MinMax,frame_length,...
                TimeStep,SHR_Threshold,Ceiling,med_smooth,CHECK_VOICING);
            %% D'Odorico & Franco 1991 transform
            f0DF = round(nonzeros(f0)/47.8);
            f0Change = [];
            for k = 1:(length(f0DF)-1)
                if f0DF(k) == f0DF(k+1); % level
                    f0Change(k) = 0;
                end
                if f0DF(k) < f0DF(k+1); % rising
                    f0Change(k) = 1;
                end
                if f0DF(k) > f0DF(k+1); % falling
                    f0Change(k) = -1;
                end
            end
            unVoiced = 1;
            level = 0;
            simpRise = 0; simpFall = 0;
            complexRise = 0; complexFall = 0;
            if ~isempty(f0DF)
                unVoiced = 0;
                if ~any(f0Change), level = 1;
                else
                    if f0DF == sort(f0DF, 'ascend'), simpRise = 1; end
                    if f0DF == sort(f0DF, 'descend'), simpFall = 1; end
                    if ~any([simpRise simpFall])
                        changeVector = nonzeros(f0Change);
                        if changeVector(length(changeVector)) == 1, complexRise = 1; end
                        if changeVector(length(changeVector)) == -1, complexFall = 1; end
                    end
                end
            end
            %% Snow 2006
            [maxf0 maxi] = max(f0);
            [minf0 mini] = min(nonzeros(f0));
            accentRange = (1200/log10(2)) * (log10(maxf0/minf0));
            accRange2 = log10(maxf0) - log10(minf0);
            snowRise = 0; snowFall = 0;
            if maxi > mini, snowRise = 1; end
            if maxi < mini, snowFall = 1; end
            %% Hunter 2008
            % note: Hunter collected these measures every voiced 30ms, but this is the
            % whole 'utterance' labeled "CHN"
            f0z = nonzeros(f0);
            f0mean = mean(f0z);
            f0mode = mode(round(f0z));
            f0median = median(f0z);
            f0sd = std(nonzeros(f0z));
            % here are the values collected every 30ms
            ab = 1:10:length(f0z);
            if length(f0z) > 10
                for jj = 1:length(ab)
                    rep2=rep2+1;
                    f030ms =[];
                    for jjj = 0:9
                        f030ms = [f030ms f0z(jj+jjj)];
                    end
                    hunter(rep2).rep2 = rep2;
                    hunter(rep2).runDate = today;
                    hunter(rep2).tOfDay = tOfDay{i};
                    hunter(rep2).tRecord = tOfDay{i}((length(tOfDay{i}))-7: length(tOfDay{i}));
                    hunter(rep2).chKey = chKey{i};
                    hunter(rep2).chID = chID{i};
                    hunter(rep2).chAge = chAge(i);
                    hunter(rep2).chSex = chSex{i};
                    hunter(rep2).fnDat = fnDat;
                    hunter(rep2).f030ms = f030ms;
                    hunter(rep2).f0mean = mean(f030ms);
                end
            end
            clc;
            disp(['working on: ', num2str(rep) ' file ' fnDat])
            Y(rep).rep = rep;
            Y(rep).runDate = today;
            Y(rep).tOfDay = tOfDay{i};
            Y(rep).chKey = chKey{i};
            Y(rep).chID = chID{i};
            Y(rep).chAge = chAge(i);
            Y(rep).chSex = chSex{i};
            Y(rep).t1 = t1;
            Y(rep).t2 = t2;
            Y(rep).fnDat = fnDat;
            Y(rep).level = level;
            Y(rep).simpRise = simpRise;
            Y(rep).simpFall = simpFall;
            Y(rep).complexRise = complexRise;
            Y(rep).complexFall = complexFall;
            Y(rep).unVoiced = unVoiced;
            Y(rep).maxf0 = maxf0;
            Y(rep).minf0 = minf0;
            Y(rep).accentRange = accentRange;
            Y(rep).accRange2 = accRange2;
            Y(rep).snowRise = snowRise;
            Y(rep).snowFall = snowFall;
            Y(rep).f0mean = f0mean;
            Y(rep).f0mode = f0mode;
            Y(rep).f0median = f0median;
            Y(rep).f0sd = f0sd;
        end
    end
    clear s1 s2 cWav
    save(['f0Data_' fnDat '.mat'], 'Y', 'hunter')
end
fclose('all');
%%
tDone = toc;
disp(['done in ' num2str(tDone) ' secs'])