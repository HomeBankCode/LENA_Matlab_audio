% get some details from ITS files filtered by recording time
% M. VanDam 12/12/12  www.vandamMark.com
% some preliminary variables
clear all;
hrs = [6 8 10 12 14 99];  % duration of filter


%%
cd 'K:\scratch\ITS_files'
flist = ls;
for h = 3:length(flist(:,end))
    fname = flist(h,:);
    fid = fopen(fname);
    for i = 1:length(hrs)
        ctc=0; awc=0; cvc=0;
        hr = hrs(i);
        tline = fgetl(fid);
        while ischar(tline)
            if strfind(tline, '<Conversation')
                j = strfind(tline, 'startTime="PT');
                k = strfind(tline, 'S" endTime="');
                if j
                    t = tline(j+13:k-1);
                    t = str2num(t);
                    if t> 60*60*hrs
                        break  % break from the loop for all times greater than 6hrs
                    end
                    %% conversational turns
                    m = strfind(tline, 'turnTaking="');
                    mm = str2num(tline(m+12));
                    ctc = ctc + mm;
                    %% adult word count
                    n = strfind(tline, 'adultWordCnt="');
                    p = strfind(tline, '" femaleAdultWordCnt="');
                    aw = tline(n+14 : p-1);
                    awc = awc + str2num(aw);
                    %% child vocalization count
                    r = strfind(tline, 'childUttCnt="');
                    s = strfind(tline, '" childUttLen="');
                    cv = tline(r+13 : s-1);
                    cvc = cvc + str2num(cv);
                end
            end
            tline = fgetl(fid);
        end
        eval(['d(h-2).ctc' num2str(hr) '= ctc;']);
        eval(['d(h-2).awc' num2str(hr) '= awc;']);
        eval(['d(h-2).cvc' num2str(hr) '= cvc;']);
    end
    fclose(fid);
end
