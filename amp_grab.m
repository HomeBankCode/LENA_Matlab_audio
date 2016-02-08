% This takes LENA-generated WAV files and CSV files and outputs the the
% amplitude values for selected segment labels into a data file.  It then
% plots the results and some descriptive stats.
% M. VanDam 04 Oct 2011, www.vanDamMark.com
clear all;
tic
today = date;
progress = [ '|' '/' '-' '\' '|' '/' '-' '\'];
directory = 'I:\LENA_scratch\';
disp(['current directory is ', directory])
cd(directory);
filesDat = dir('*.csv');
filesWav = dir('*.wav');
rate = 16000;
rep = 0; rep2=0;

F=[];
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
    %% get the onset and offset times of the segs
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
    for i = 2: length(talker)-1
        if (talker{i} == 'FAN') | (talker{i} == 'MAN')
            rep = rep + 1;
            t1 = tElapsed(i);
            t2 = tElapsed(i+1);
            durSeg = (t2-t1) * 1000; % rendered in ms
            s1 = (t1 * rate) - 80; % 80 samples is 5ms
            s2 = (t2 * rate) + 80;
            s1 = int64(s1); s1 = double(s1);
            s2 = int64(s2); s2 = double(s2);
            cWav = wavread(fnWav, [s1 s2]);
            rmsAmp = sqrt(mean(cWav .^2));
            %%% rms2 = sqrt(sum(cWav.^2)/length(cWav)) % another way to do it
            %%% rms1 = norm(cWav)/sqrt(length(cWav)) % another way to do it
            F(rep).rep      = rep;
            F(rep).runDate  = today;
            F(rep).tOfDay   = tOfDay{i};
            F(rep).chKey    = chKey{i};
            F(rep).chID     = chID{i};
            F(rep).chAge    = chAge(i);
            F(rep).chSex    = chSex{i};
            F(rep).talker   = talker{i};
            F(rep).t1       = t1;
            F(rep).t2       = t2;
            F(rep).dur      =  durSeg;
            F(rep).fnDat    = fnDat;
            F(rep).rms      = rmsAmp;
%             F(rep).rms2      = rmsAmp2;  % uncomment matched var above 
%             F(rep).rms1      = rmsAmp1;  % uncomment matched var above
        end
        if (talker{i} == 'OLN') | (talker{i} == 'TVN') |...
                (talker{i} == 'NON') % | (talker{i} == 'FUZ')
            rep = rep + 1;
            t1 = tElapsed(i);
            t2 = tElapsed(i+1);
            durSeg = (t2-t1) * 1000; % rendered in MS
            s1 = (t1 * rate) - 80; % 80 samples is 5ms
            s2 = (t2 * rate) + 80;
            s1 = int64(s1); s1 = double(s1);
            s2 = int64(s2); s2 = double(s2);
            cWav = wavread(fnWav, [s1 s2]);
            rmsAmp = sqrt(mean(cWav .^2));
            clc;
            disp(['working on MAN: ', num2str(rep) ' file ' fnDat ' of ' num2str(length(talker))])
            F(rep).rep = rep;
            F(rep).runDate = today;
            F(rep).tOfDay = tOfDay{i};
            F(rep).chKey = chKey{i};
            F(rep).chID = chID{i};
            F(rep).chAge = chAge(i);
            F(rep).chSex = chSex{i};
            F(rep).talker = talker{i};
            F(rep).t1 = t1;
            F(rep).t2 = t2;
            F(rep).dur =  durSeg;
            F(rep).fnDat = fnDat;
            F(rep).rms = rmsAmp;
        end
    end
    clear s1 s2 cWav
    save(['ampDataAll_' fnDat '.mat'], 'F')
end
fclose('all');
%%
clear blockType chAge chID chKey chSex fNameSource recording segDuration tElapsed tOfDay talker
tDone = toc;
disp(['done in ' num2str(tDone) ' secs'])

rmsAll=[];
rmsF=[]; rmsM=[]; rmsJ=[]; rmsO=[]; rmsT=[]; rmsN=[];
for ii = 1:length(F)
    if F(ii).talker == 'FAN'
        rmsF = [rmsF F(ii).rms];
    end
    if F(ii).talker == 'MAN'
        rmsM = [rmsM F(ii).rms];
    end
    if F(ii).talker == 'OLN'
        rmsO = [rmsO F(ii).rms];
    end
    if F(ii).talker == 'TVN'
        rmsT = [rmsT F(ii).rms];
    end
    if F(ii).talker == 'NON'
        rmsN = [rmsN F(ii).rms];
    end
    rmsAll = [rmsAll F(ii).rms];
end
rmsJ = [rmsO rmsT rmsN];

[p h stats] = ranksum(rmsF, rmsM);  %%% test for diff between moms and dads

plot(rmsF, 'ko'); hold on; 
plot(rmsM, 'g>'); hold on;
plot(rmsO, 'm.'); hold on;
plot(rmsT, 'rs'); hold on;
plot(rmsN, 'c*'); hold on;

plot([1:5], [mean(rmsF) mean(rmsM) mean(rmsO) mean(rmsT) mean(rmsN)])
[mean(rmsF) std(rmsM) std(rmsO) std(rmsT) std(rmsN)]

hist(rmsF, 20), hold on;
h1 = findobj(gca, 'type', 'patch')
set(h1, 'facecolor', 'b', 'edgecolor', 'w')
hist(rmsM, 20)
h2 = findobj(gca, 'type', 'patch')
set(h2, 'facecolor', 'r', 'edgecolor', 'w')


