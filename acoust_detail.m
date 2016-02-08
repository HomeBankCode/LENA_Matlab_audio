%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% This script does acoustic analysis of any number of paired .WAV + .ITS
%%% files in some directory.  It collects by talker (CHN, FAN, MAN) and
%%% certain selected conversational type (eg., AICM).  The acoustic
%%% analysis here uses an PDA/F0-estimation algorithm from X. Sun availble
%%% here: http://www.mathworks.com/matlabcentral/fileexchange/1230-pitch-determination-algorithm/content/shrp.m
%%% Mark VanDam, mark.vandam@wsu.edu, Jan. 2013
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;
tic
ages = [2.53 2.41 2.59 2.36 2.37 2.72 2.10 2.41 2.35 2.23...
    2.39 2.63 2.53 2.42 2.44 2.41 2.24 2.94 2.29 2.45 2.49 2.46 ];
flist = input('\n\n\n\n   Enter directory where ITS files are stored: ', 's');
rate = 16000;
frame_length = 20; % in ms
TimeStep = 3; % in ms
SHR_Threshold = 0.4; %range 0:1
Ceiling = 1250;
med_smooth = 0;
CHECK_VOICING = 1;

for ik = 4:length(flist)
    cd(flist{ik});
    currDir = pwd;
    subjName = currDir(length(currDir)-11:length(currDir)-8); % subj name is part of file name
    fileList = dir; % enumerate file details in this directory
    clear tCHN tCHN2FAN tCHN2MAN tFAN tMAN
    tCHN = [];
    tCHN2FAN = [];
    tCHN2MAN = [];
    tFAN = [];
    tMAN = [];

    dirFiles = ls;
    for lx = 1:length(dirFiles(:,1))
        rowlx = dirFiles(lx,:);
        if strfind(rowlx, '.its')
            fname = deblank(dirFiles(lx,:));
        end
    end
    fid=fopen(fname);
    lineNo=0;
    matByLine(1).text = [];
    disp(['working on ITS file ', fname '...']);
    while 1
        tline = fgetl(fid);
        if ~ischar(tline), break, end
        lineNo = lineNo + 1;
        matByLine(lineNo).text = tline; % read ITS file into STRUCT
    end
    fclose(fid);

    for k = 1:length(matByLine)
        kk=0;
        cBlock=[];
        while 1
            kk = kk+1;
            if k+kk > length(matByLine)-1, break, end
            if strfind(matByLine(k+kk).text, '</Conversation>'), break, end
            if strfind(matByLine(k).text, 'type="AICM"')
                cBlock(kk).text = matByLine(k+kk).text;
            end
        end

        for jj = 1:length(cBlock)
            kLine = cBlock(jj).text;
            if strfind(kLine, 'spkr="CHN"') % only look for CHN lines
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
                    if (1 < jj) && (jj < length(cBlock)-1)
                        if strfind([cBlock(jj+1).text cBlock(jj-1).text], 'spkr="FAN"')
                            tCHN2FAN = [tCHN2FAN; str2num(tStartUtt) str2num(tEndUtt)];
                        end
                        if strfind([cBlock(jj+1).text cBlock(jj-1).text], 'spkr="MAN"')
                            tCHN2MAN = [tCHN2MAN; str2num(tStartUtt) str2num(tEndUtt)];
                        end
                    end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%  do some analysis here  %%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                end
            end
            if strfind(kLine, 'spkr="FAN"')
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
                tFAN = [tFAN; str2num(tStartTime) str2num(tEndTime)];
            end
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
    end
    clear matByLine;
    disp(['tCHN= ' num2str(length(tCHN)) '  tFAN= ' num2str(length(tFAN)),...
        'tMAN= ' num2str(length(tMAN))])
    
    %%%%%%%%%%%%%%%%%%

    clear dataF0c2f dataF0c2m dataF0c dataF0f dataF0m;
    if isempty(tCHN2FAN), tCHN2FAN=0; end
    if isempty(tCHN2MAN), tCHN2MAN=0; end
    if isempty(tCHN), tCHN=0; end
    if isempty(tFAN), tFAN=0; end
    if isempty(tMAN), tMAN=0; end
    dataF0c2f(length(tCHN2FAN)).fname = [];
    dataF0c2m(length(tCHN2MAN)).fname = [];
    dataF0c(length(tCHN)).fname = [];
    dataF0f(length(tFAN)).fname = [];
    dataF0m(length(tMAN)).fname = [];
    %%% calculate F0 at utterance times
if numel(tCHN2FAN) > 4
    for q = 1:length(tCHN2FAN)
        s1 = (tCHN2FAN(q,1) * rate);% - 80; % 80 samples is 5ms
        s2 = (tCHN2FAN(q,2) * rate);% + 80;
        s1 = int64(s1); s1 = double(s1);
        s2 = int64(s2); s2 = double(s2);
        fnWav = [fname(1:end-3) 'wav'];
        cWav = wavread(fnWav, [s1 s2]);
        F0MinMax = [200 600]; %might want to change this
        [f0t, f0] = shrp(cWav,rate,F0MinMax,frame_length,...
            TimeStep,SHR_Threshold,Ceiling,med_smooth,CHECK_VOICING);
        [ii jj ss] = find(f0);
        f0tNoZ=[];
        for kk = 1:length(jj), f0tNoZ = [f0tNoZ f0t(ii(kk))];, end
        if length(f0tNoZ) > 2
            fx = nonzeros(f0);
            %%% some basic descriptive stats
            fmean = mean(fx);
            fstd  = std(fx);
            durUtt = (length(cWav)/rate)*1000;
            durVx  = length(fx)*TimeStep;
            durPct = durVx / durUtt;
            %%% write to data structure
            dataF0c2f(q).age           = ages(ik);
            dataF0c2f(q).subjName      = subjName;
            dataF0c2f(q).fname         = fname;
            dataF0c2f(q).durUtt        = durUtt;
            dataF0c2f(q).pctUttVx      = durPct;
            dataF0c2f(q).f0mean        = fmean;
            dataF0c2f(q).f0std         = fstd;
        end
        clc;
        disp(['working on C2F ' num2str(q) ' of ' num2str(length(tCHN2FAN))]);
    end
end
    if length(tCHN2MAN) > 2 %% required for limited dad talk
        for q = 1:length(tCHN2MAN)
            s1 = (tCHN2MAN(q,1) * rate);% - 80; % 80 samples is 5ms
            s2 = (tCHN2MAN(q,2) * rate);% + 80;
            s1 = int64(s1); s1 = double(s1);
            s2 = int64(s2); s2 = double(s2);
            fnWav = [fname(1:end-3) 'wav'];
            cWav = wavread(fnWav, [s1 s2]);
            F0MinMax = [200 600]; %might want to change this, mvd: 3/25/10
            [f0t, f0] = shrp(cWav,rate,F0MinMax,frame_length,...
                TimeStep,SHR_Threshold,Ceiling,med_smooth,CHECK_VOICING);
            [ii jj ss] = find(f0);
            f0tNoZ=[];
            for kk = 1:length(jj), f0tNoZ = [f0tNoZ f0t(ii(kk))];, end
            if length(f0tNoZ) > 2
                fx = nonzeros(f0);
                %%% some basic descriptive stats
                fmean = mean(fx);
                fstd  = std(fx);
                durUtt = (length(cWav)/rate)*1000;
                durVx  = length(fx)*TimeStep;
                durPct = durVx / durUtt;
                %%% write to data structure
                dataF0c2m(q).age           = ages(ik);
                dataF0c2m(q).subjName      = subjName;
                dataF0c2m(q).fname         = fname;
                dataF0c2m(q).durUtt        = durUtt;
                dataF0c2m(q).pctUttVx      = durPct;
                dataF0c2m(q).f0mean        = fmean;
                dataF0c2m(q).f0std         = fstd;
            end
            clc;
            disp(['working on C2M ' num2str(q) ' of ' num2str(length(tCHN2MAN))]);
        end
    end
    for q = 1:length(tCHN)
        s1 = (tCHN(q,1) * rate);% - 80; % 80 samples is 5ms
        s2 = (tCHN(q,2) * rate);% + 80;
        s1 = int64(s1); s1 = double(s1);
        s2 = int64(s2); s2 = double(s2);
        fnWav = [fname(1:end-3) 'wav'];
        cWav = wavread(fnWav, [s1 s2]);
        F0MinMax = [200 600]; %might want to change this, mvd: 3/25/10
        [f0t, f0] = shrp(cWav,rate,F0MinMax,frame_length,...
            TimeStep,SHR_Threshold,Ceiling,med_smooth,CHECK_VOICING);
        [ii jj ss] = find(f0);
        f0tNoZ=[];
        for kk = 1:length(jj), f0tNoZ = [f0tNoZ f0t(ii(kk))];, end
        if length(f0tNoZ) > 2
            fx = nonzeros(f0);
            %%% some basic descriptive stats
            fmean = mean(fx);
            fstd  = std(fx);
            durUtt = (length(cWav)/rate)*1000;
            durVx  = length(fx)*TimeStep;
            durPct = durVx / durUtt;
            %%% write to data structure
            dataF0c(q).age           = ages(ik);
            dataF0c(q).subjName      = subjName;
            dataF0c(q).fname         = fname;
            dataF0c(q).durUtt        = durUtt;
            dataF0c(q).pctUttVx      = durPct;
            dataF0c(q).f0mean        = fmean;
            dataF0c(q).f0std         = fstd;
        end
        clc;
        disp(['working on C ' num2str(q) ' of ' num2str(length(tCHN))]);
    end
    if numel(tFAN) > 4
    for q = 1:length(tFAN)
        s1 = (tFAN(q,1) * rate);% - 80; % 80 samples is 5ms
        s2 = (tFAN(q,2) * rate);% + 80;
        s1 = int64(s1); s1 = double(s1);
        s2 = int64(s2); s2 = double(s2);
        fnWav = [fname(1:end-3) 'wav'];
        cWav = wavread(fnWav, [s1 s2]);
        F0MinMax = [120 400]; %might want to change this, mvd: 3/25/10
        [f0t, f0] = shrp(cWav,rate,F0MinMax,frame_length,...
            TimeStep,SHR_Threshold,Ceiling,med_smooth,CHECK_VOICING);
        [ii jj ss] = find(f0);
        f0tNoZ=[];
        for kk = 1:length(jj), f0tNoZ = [f0tNoZ f0t(ii(kk))];, end
        if length(f0tNoZ) > 2
            fx = nonzeros(f0);
            %%% some basic descriptive stats
            fmean = mean(fx);
            fstd  = std(fx);
            durUtt = (length(cWav)/rate)*1000;
            durVx  = length(fx)*TimeStep;
            durPct = durVx / durUtt;
            %%% write to data structure
            dataF0f(q).age           = ages(ik);
            dataF0f(q).subjName      = subjName;
            dataF0f(q).fname         = fname;
            dataF0f(q).durUtt        = durUtt;
            dataF0f(q).pctUttVx      = durPct;
            dataF0f(q).f0mean        = fmean;
            dataF0f(q).f0std         = fstd;
        end
        clc;
        disp(['working on F ' num2str(q) ' of ' num2str(length(tFAN))]);
    end
    end
    for q = 1:length(tMAN)
        s1 = (tMAN(q,1) * rate);% - 80; % 80 samples is 5ms
        s2 = (tMAN(q,2) * rate);% + 80;
        s1 = int64(s1); s1 = double(s1);
        s2 = int64(s2); s2 = double(s2);
        fnWav = [fname(1:end-3) 'wav'];
        cWav = wavread(fnWav, [s1 s2]);
        F0MinMax = [50 250]; %might want to change this
        [f0t, f0] = shrp(cWav,rate,F0MinMax,frame_length,...
            TimeStep,SHR_Threshold,Ceiling,med_smooth,CHECK_VOICING);
        [ii jj ss] = find(f0);
        f0tNoZ=[];
        for kk = 1:length(jj), f0tNoZ = [f0tNoZ f0t(ii(kk))];, end
        if length(f0tNoZ) > 2
            fx = nonzeros(f0);
            %%% some basic descriptive stats
            fmean = mean(fx);
            fstd  = std(fx);
            durUtt = (length(cWav)/rate)*1000;
            durVx  = length(fx)*TimeStep;
            durPct = durVx / durUtt;
            %%% write to data structure
            dataF0m(q).age           = ages(ik);
            dataF0m(q).subjName      = subjName;
            dataF0m(q).fname         = fname;
            dataF0m(q).durUtt        = durUtt;
            dataF0m(q).pctUttVx      = durPct;
            dataF0m(q).f0mean        = fmean;
            dataF0m(q).f0std         = fstd;
        end
        clc;
        disp(['working on M ' num2str(q) ' of ' num2str(length(tMAN))]);
    end

    cd('G:\LENA\DATA_General\f0_Oct2010_HI_AICM');
    save([subjName '_' fname(1:end-4) '_CHN'], 'dataF0c');
    save([subjName '_' fname(1:end-4) '_CHN2FAN'], 'dataF0c2f');
    save([subjName '_' fname(1:end-4) '_CHN2MAN'], 'dataF0c2m');
    save([subjName '_' fname(1:end-4) '_FAN'], 'dataF0f');
    save([subjName '_' fname(1:end-4) '_MAN'], 'dataF0m');
    %%% finish up and give some info
    % cd(startDir); % go back to starting directory
    disp(' ');
    disp('Done.');
    disp(['file: ' subjName '_' fname(1:end-4) ', here: ' pwd])
end
toc