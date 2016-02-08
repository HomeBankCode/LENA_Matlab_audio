%%%% Put ITS files and WAV files in a directory.  Run this to extract
%%%% biteSize (here = 30) evenly spaced tokens from specified talkers (CHN,
%%%% FAN, MAN).  WAV files are output into same directory.
%%%% M. VanDam, 4/5/13,  www.vanDamMark.com

clear all;
tic
dname = uigetdir('')
flist = dname;
for j = 1:length(flist)
    cd(flist{j});
    currDir = pwd;
    subjName = currDir(length(currDir)-11:length(currDir)-8);
    dirFiles = ls;
    clear tCHN tFAN tMAN
    tCHN = [];
    tFAN = [];
    tMAN = [];
    for lx = 1:length(dirFiles(:,1))
        rowlx = dirFiles(lx,:);
        if strfind(rowlx, '.its')
            fname = deblank(dirFiles(lx,:));
        end
    end
    fid=fopen(fname);
    lineNo=0;
    matByLine(1).text = [];
    disp(['working on ITS file ', fname '... ' num2str(toc)]);
    while 1
        tline = fgetl(fid);
        if ~ischar(tline), break, end
        lineNo = lineNo + 1;
        matByLine(lineNo).text = tline; % read ITS file into STRUCT
    end
    fclose(fid);
    for jj = 3:length(matByLine)-3
        kLine = matByLine(jj).text;
        if strfind(kLine, 'spkr="CHN"') % look for CHN lines
            %%% get the number of utterances within segment
            uttCntIndx = regexpi(kLine, 'childUttCnt="', 'end');
            uttCnt = str2num(kLine(uttCntIndx+1)); % number utterances
            for m = 1:uttCnt
                %%% get startUtt time
                eval(['n1 = ''startUtt' num2str(m) '="PT'';']);
                eval(['n2 = ''S" endUtt' num2str(m) ''';' ]);
                i1 = regexp(kLine, n1, 'end') + 1;
                i2 = regexp(kLine, n2) - 1;
                tStartUtt = kLine(i1:i2);
                %%% get endUtt time
                eval(['n3 = ''endUtt' num2str(m) '="PT'';']);
                i3 = regexp(kLine, n3, 'end') + 1;
                n4 = regexp(kLine(i3:end),'S" ');
                i4 = i3 + (n4(1)-2);
                tEndUtt = kLine(i3:i4);
                %%% store Utt start and stop times to array
                tCHN = [tCHN; str2num(tStartUtt) str2num(tEndUtt)];
            end
        end
        %%%% look for FAN lines
        if strfind(kLine, 'spkr="FAN"')
            eval(['n1 = ''startTime="PT'';']);
            eval(['n2 = ''S" endTime'';' ]);
            i1 = regexp(kLine, n1, 'end') + 1;
            i2 = regexp(kLine, n2) - 1;
            tStartTime = kLine(i1:i2);
            %%% get endUtt time
            eval(['n3 = ''endTime="PT'';']);
            i3 = regexp(kLine, n3, 'end') + 1;
            n4 = regexp(kLine(i3:end),'S" ');
            i4 = i3 + (n4(1)-2);
            tEndTime = kLine(i3:i4);
            %%% store Utt start and stop times to array
            tFAN = [tFAN; str2num(tStartTime) str2num(tEndTime)];
        end
        %%%% look for MAN lines
        if strfind(kLine, 'spkr="MAN"')
            %%% get startUtt time
            eval(['n1 = ''startTime="PT'';']);
            eval(['n2 = ''S" endTime'';' ]);
            i1 = regexp(kLine, n1, 'end') + 1;
            i2 = regexp(kLine, n2) - 1;
            tStartTime = kLine(i1:i2);
            %%% get endUtt time
            eval(['n3 = ''endTime="PT'';']);
            i3 = regexp(kLine, n3, 'end') + 1;
            n4 = regexp(kLine(i3:end),'S" ');
            i4 = i3 + (n4(1)-2);
            tEndTime = kLine(i3:i4);
            %%% store Utt start and stop times to array
            tMAN = [tMAN; str2num(tStartTime) str2num(tEndTime)];
        end
    end
    clear matByLine;
    %% get random subset of onsets and offsets
    biteSize = 30; % number of samples from categorty, about evenly spaced 
    clear tCHNsub tFANsub tMANsub;
    tCHNsub=[]; tFANsub=[]; tMANsub=[];
    i=0;
    for ik = ceil(rand*10):floor(length(tCHN)/biteSize):length(tCHN)
        i=i+1;
        tCHNsub(i,:) = tCHN(ik,:);
    end
    i=0;
    for ik = ceil(rand*10):floor(length(tFAN)/biteSize):length(tFAN)
        i=i+1;
        tFANsub(i,:) = tFAN(ik,:);
    end
    i=0;
    for ik = ceil(rand*10):floor(length(tMAN)/biteSize):length(tMAN)
        i=i+1;
        tMANsub(i,:) = tMAN(ik,:);
    end
    %%
    fnWav = [flist{j} '\' fname(1:end-3) 'wav'];
    for j1 = 1:biteSize
        s1 = tCHNsub(j1,1) * 16000; s2 = tCHNsub(j1,2) * 16000;
        s1 = int64(s1); s1 = double(s1); s2 = int64(s2); s2 = double(s2);
        [Y,FS,NBITS]=wavread(fnWav,[s1 s2]);
        wavwrite(Y,FS,NBITS,['c' num2str(j1) '_' subjName]);
    end

    for j2 = 1:biteSize 
        s1 = tFANsub(j2,1) * 16000; s2 = tFANsub(j2,2) * 16000;
        s1 = int64(s1); s1 = double(s1); s2 = int64(s2); s2 = double(s2);
        [Y,FS,NBITS]=wavread(fnWav,[s1 s2]);
        wavwrite(Y,FS,NBITS,['f' num2str(j2) '_' subjName]);
    end
    for j3 = 1:biteSize 
        s1 = tMANsub(j3,1) * 16000; s2 = tMANsub(j3,2) * 16000;
        s1 = int64(s1); s1 = double(s1); s2 = int64(s2); s2 = double(s2);
        [Y,FS,NBITS]=wavread(fnWav,[s1 s2]);
        wavwrite(Y,FS,NBITS,['m' num2str(j3) '_' subjName]);
    end
    
end
disp(['total time to process is ' num2str(toc)])
