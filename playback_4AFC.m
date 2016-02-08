function stimPlayback_n()
%%%% function plays audio stims in random order for
%%%% 4-alternative-forced-choice presentation.  These audio files were
%%%% generated with 'getBiteSizeSamples'.  Stim files names indicate 
%%%% c=child, f=mother, m=father in first char of file name.
%%%% Listeners have a simple interface to enter choice. Display some simple
%%%% stats when completed.
%%%% M. VanDam, 3/4/13,  www.vanDamMark.com

close all; clear all;
%%%%
SubjID = Now2SubjID;
dstart = pwd;

%get all the WAVs in some directory
dname = uigetdir('')
cd(dname);
dirFs = ls; %%% put this function in same dir as audio files
kwIndx=0;

dataDir = dname;
cd(dataDir);
if exist('v_data.mat') == 0  %%% if randomization file doesn't exist, make it
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
    v = struct('fname', [], 'stim', [], 'resp', [], 'match', [], 'judge', [], 'date', []);
    
    clc
    fprintf('\n\n\n\n\n\n\n\n\n\n');
    jName = input('Please enter your first name:  ', 's');
    if isempty(jName)
        jName = ['anon' int2str(rand*100)];
    end
else  %%% if randomization file does exist (user interrupted) then use it
    load v_data
    load jw
    jName = v(1).judge;
    disp(['Oh, you''d like to continue.  Great!  Welcome back ' jName])
end

load sName2
cd(dname);
%%%%%%%%%%%
clc
fprintf('\n\n\n\n\n\n\n\n\n\n');
disp(['Hello and welcome, ' jName])
input('press <enter> to begin...')

for jw = length(v):length(dirFs-3)
    clc
    J = wavread(sName2{jw});
    replay=0;
    while replay == 0
        disp('9 to quit, anytime.')
        disp(['your progress: ' num2str(((jw+1)/length(dirFs))*100) '% of total'])
        disp('<enter> to replay sound')
        disp('1-Child   2-Mom   3-Dad   4-not(Chn|Mom|Dad): ');
        disp('playing sound...')
        sound(J,16000)
                pause(.2);
                pause(length(J)/16000)
        clc
        disp('9 to quit, anytime.')
        disp(['your progress: ' num2str(((jw+1)/length(dirFs))*100) '% of total'])
        disp('<enter> to replay sound')
        resp = 99;
        resp = input('1-Child   2-Mom   3-Dad   4-not(Chn|Mom|Dad): ');
        if isempty(resp), clc, continue,
        else replay=1;, end
    end
    clear J
    if resp == 9, break, end
    stim = 0;
    if sName2{jw}(1) == 'c', stim = 1;
    elseif sName2{jw}(1) == 'f', stim = 2;
    elseif sName2{jw}(1) == 'm', stim = 3;
    else stim = 4; end
    
    c2c=0; c2m=0; c2d=0; c2x=0;
    if     stim == 1 & resp == 1, c2c = 1; %ch id OK
    elseif stim == 1 & resp == 2, c2m = 1; %ch id as mom
    elseif stim == 1 & resp == 3, c2d = 1; %ch id as dad
    elseif stim == 1 & resp == 4, c2x = 1; end %ch id as other
    
    m2c=0; m2m=0; m2d=0; m2x=0;
    if     stim == 2 & resp == 1, m2c = 1;
    elseif stim == 2 & resp == 2, m2m = 1;
    elseif stim == 2 & resp == 3, m2d = 1;
    elseif stim == 2 & resp == 4, m2x = 1; end
    
    d2c=0; d2m=0; d2d=0; d2x=0;
    if     stim == 3 & resp == 1, d2c = 1;
    elseif stim == 3 & resp == 2, d2m = 1;
    elseif stim == 3 & resp == 3, d2d = 1;
    elseif stim == 3 & resp == 4, d2x = 1; end
    
    x2c=0; x2m=0; x2d=0; x2x=0;
    if     stim == 4 & resp == 1, x2c = 1;
    elseif stim == 4 & resp == 2, x2m = 1;
    elseif stim == 4 & resp == 3, x2d = 1;
    elseif stim == 4 & resp == 4, x2x = 1; end
    
    if resp == stim, SRmatch = 1;
    else SRmatch = 0; end
    %%%% save the data
    v(jw).subjID  = SubjID;
    v(jw).fname   = sName2{jw};
    v(jw).stim    = stim;
    v(jw).resp    = resp;
    v(jw).c2c    = c2c;
    v(jw).c2m    = c2m;
    v(jw).c2d    = c2d;
    v(jw).c2x    = c2x;
    v(jw).m2c    = m2c;
    v(jw).m2m    = m2m;
    v(jw).m2d    = m2d;
    v(jw).m2x    = m2x;
    v(jw).d2c    = d2c;
    v(jw).d2m    = d2m;
    v(jw).d2d    = d2d;
    v(jw).d2x    = d2x;
    v(jw).x2c    = x2c;
    v(jw).x2m    = x2m;
    v(jw).x2d    = x2d;
    v(jw).x2x    = x2x;
    v(jw).match   = SRmatch;
    v(jw).judge   = jName;
    v(jw).date    = date;
end
cd(dataDir);
save jw jw
save v_data v

%% give some stats when all done
% if 0   %%% uncomment to supress output
    if length(v) == length(dirFs)
        cTab = [
            sum([v.c2c]) sum([v.c2m]) sum([v.c2d]) sum([v.c2x]);
            sum([v.m2c]) sum([v.m2m]) sum([v.m2d]) sum([v.m2x]);
            sum([v.d2c]) sum([v.d2m]) sum([v.d2d]) sum([v.d2x]);
            sum([v.x2c]) sum([v.x2m]) sum([v.x2d]) sum([v.x2x]);];
        rows = sum(cTab'); % sums of rows
        cols = sum(cTab); % sums of columns
        diag = trace(cTab); % sum of diagonal elements
        pctAgr = diag/(sum(rows));
        efc = (rows(1)*cols(1)) / sum(rows);
        efm = (rows(2)*cols(2)) / sum(rows);
        efd = (rows(3)*cols(3)) / sum(rows);
        efx = (rows(4)*cols(4)) / sum(rows);
        ef_all = sum([efc efm efd efx]);
        K = (diag - ef_all) / (sum(rows) - ef_all); % Cohen's kappa
        
        ct1 = [cTab(1,1) sum(cTab(1,2:4)); sum(cTab(2:4,1)) sum(sum(cTab(2:4,2:4)))];
        ct2 = [cTab(2,2) sum([sum(cTab(2,:)) - cTab(2,2)]); sum(cTab(:,2)) - cTab(2,2) sum([cTab(1,1) sum(sum(cTab(3:4,3:4)))])];
        ct3 = [cTab(3,3) sum([sum(cTab(3,:)) - cTab(3,3)]); sum(cTab(:,3)) - cTab(3,3) sum([cTab(4,4) sum(sum(cTab(1:2,1:2)))])];
        ct_all = {ct1 ct2 ct3};
        ct_names = {'child' 'mother' 'father'};
        for kk = 1:length(ct_all)
            ct = [ct_all{kk}];
            rows1 = sum(ct');
            cols1 = sum(ct);
            diag1 = trace(ct);
            pctAgr1 = diag1/(sum(rows1));
            ef1 = (rows1(1)*cols1(1)) / sum(rows1);
            ef2 = (rows1(2)*cols1(2)) / sum(rows1);
            ef_all1 = sum([ef1 ef2]);
            K1 = (diag1 - ef_all1) / (sum(rows1) - ef_all1);
            disp(['kappa for ' ct_names{kk} ' is ' num2str(K1)])
        end
        disp(['kappa overall     = ' num2str(K)])
        disp(['Percent agreement = ' num2str(pctAgr*100)])
        disp(['Number of trials  = ' num2str(length(v))])
    end
% end   %%%% uncomment to suppress output
disp(['Session number is:  ' SubjID]);
disp(' ');
disp('goodbye');
disp(' ');
cd(dstart);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Subfunctions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SubjID = Now2SubjID()
% Generates a nine-digit numeral (N.B.: STRING) based on current time.
SubjTime = now;
DayPow = 1; % 1 for 1-day high digit, 2 for 10-day high digit
SubjID = num2str( fix( 10^(9-DayPow) * ...
   ( SubjTime - (10^DayPow)*fix(SubjTime/(10^DayPow)) ) ));
% Pad with leading zeros if result is less than 9 digits
for i = 1 : 9-length(SubjID)
   SubjID = [ '0' , SubjID ];
end

% -------------------------------------------------------------------------
