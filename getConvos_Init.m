

clear all;
c = clock; y = num2str(c(1)); m=num2str(c(2)); d=num2str(c(3)); h=num2str(c(4)); mn=num2str(c(5)); S=fix(c(6)); s=num2str(S);
fTime = [y m d h mn s];

prompt = 'for TD data enter 1, otherwise 0:  ';
pTD = input(prompt);

folderName = uigetdir;
cd([folderName '\'])
folderContents = dir;
for j = 1:length(folderContents)
    clc;
    disp([num2str(j) ' of ' num2str(length(folderContents))])
    k = strfind(folderContents(j).name, '.its');
    if ~isempty(k)
        str = fileread(folderContents(j).name);
        lines = regexp(str, '\r\n|\r|\n', 'split');
        
        totTurns = 0;
        AWC      = 0;
        femAWC   = 0;
        malAWC   = 0;
        chiUtt   = 0;
        
        fan2man = 0;
        fan2chn = 0;
        fan2cxn = 0;
        fan2oln = 0;
        
        man2fan = 0;
        man2chn = 0;
        man2cxn = 0;
        man2oln = 0;
        
        chn2fan = 0;
        chn2man = 0;
        chn2cxn = 0;
        chn2oln = 0;
        
        cxn2fan = 0;
        cxn2man = 0;
        cxn2chn = 0;
        cxn2oln = 0;
        
        oln2fan = 0;
        oln2man = 0;
        oln2chn = 0;
        oln2cxn = 0;
        
        for i = 1: (length(lines))-2
            seg1 = lines{i};
            seg2 = lines{i+2};
            
            % get some file details
            chKeyN = strfind(seg1, 'ChildKey');
            if ~isempty(chKeyN)
                lab = 'ChildKey';
                idx = strfind(seg1, lab);
                idxQ = strfind(seg1(idx:end), '"');
                varLab = seg1(idx+idxQ(1):idx+idxQ(2)-2);
                chKey = varLab;
            end
            
            sexN = strfind(seg1, 'Gender');
            if ~isempty(sexN)
                lab = 'Gender';
                idx = strfind(seg1, lab);
                idxQ = strfind(seg1(idx:end), '"');
                varLab = seg1(idx+idxQ(1):idx+idxQ(2)-2);
                if varLab == 'F', varLab=0;, else varLab=1;, end %convert to isBoy
                sex = varLab;
            end
            
            ageN = [];
            if strfind(seg1, 'algorithmAge') 
                ageN = strfind(seg1, 'algorithmAge');
                lab = 'algorithmAge';
            end
            if strfind(seg1, 'chronologicalAge')
                ageN = strfind(seg1, 'chronologicalAge');
                lab = 'chronologicalAge';
            end
            
            if ~isempty(ageN)
                idx = strfind(seg1, lab);
                idxQ = strfind(seg1(idx:end), '"');
                varLab = seg1(idx+idxQ(1)+1:idx+idxQ(2)-3);
                age = varLab;
            end
            
            dobN = strfind(seg1, 'DOB');
            if ~isempty(dobN)
                lab = 'DOB';
                idx = strfind(seg1, lab);
                idxQ = strfind(seg1(idx:end), '"');
                varLab = seg1(idx+idxQ(1):idx+idxQ(2)-2);
                dob = varLab;
            end
            
            fnameN = strfind(seg1, 'fileName');
            if ~isempty(fnameN)
                lab = 'fileName';
                idx = strfind(seg1, lab);
                idxQ = strfind(seg1(idx:end), '"');
                varLab = seg1(idx+idxQ(1):idx+idxQ(2)-2);
                fname = varLab;
            end
            
           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % get some utterance details
            convo = strfind(seg1, '<Conversation');
            if ~isempty(convo)             
                lab = 'turnTaking';
                idx = strfind(seg1, lab);
                idxQ = strfind(seg1(idx:end), '"');
                varLab = seg1(idx+idxQ(1):idx+idxQ(2)-2);
                totTurns = totTurns + str2num(varLab);
                
                lab = 'adultWordCnt';
                idx = strfind(seg1, lab);
                idxQ = strfind(seg1(idx:end), '"');
                varLab = seg1(idx+idxQ(1):idx+idxQ(2)-2);
                AWC = AWC + str2num(varLab);
                
                lab = 'femaleAdultWordCnt';
                idx = strfind(seg1, lab);
                idxQ = strfind(seg1(idx:end), '"');
                varLab = seg1(idx+idxQ(1):idx+idxQ(2)-2);
                femAWC = femAWC + str2num(varLab);
                
                lab = ' maleAdultWordCnt';
                idx = strfind(seg1, lab);
                idxQ = strfind(seg1(idx:end), '"');
                varLab = seg1(idx+idxQ(1):idx+idxQ(2)-2);
                malAWC = malAWC + str2num(varLab);
                
                lab = 'childUttCnt';
                idx = strfind(seg1, lab);
                idxQ = strfind(seg1(idx:end), '"');
                varLab = seg1(idx+idxQ(1):idx+idxQ(2)-2);
                chiUtt = chiUtt + str2num(varLab);
            end
            AVA = strfind(seg1, '<AVA');
            if ~isempty(AVA)
                lab = 'vocalizationCnt';
                idx = strfind(seg1, lab);
                idxQ = strfind(seg1(idx:end), '"');
                varLab = seg1(idx+idxQ(1):idx+idxQ(2)-2);
                chiUtt2 = str2num(varLab);
                
                lab = 'vocalizationLen';
                idx = strfind(seg1, lab);
                idxQ = strfind(seg1(idx:end), '"');
                varLab = seg1(idx+idxQ(1)+1:idx+idxQ(2)-3);
                chiVocLen = str2num(varLab); 
            end
                
            %%  get the conversational details
            
            if contains(seg1,'<Segment')
                FAN1 = strfind(seg1, 'FAN');
                FAN2 = strfind(seg2, 'FAN');
                MAN1 = strfind(seg1, 'MAN');
                MAN2 = strfind(seg2, 'MAN');
                CHN1 = strfind(seg1, 'CHN');
                CHN2 = strfind(seg2, 'CHN');
                CXN1 = strfind(seg1, 'CXN');
                CXN2 = strfind(seg2, 'CXN');
                OLN1 = strfind(seg1, 'OLN');
                OLN2 = strfind(seg2, 'OLN');
                
                if ~isempty(FAN1) && ~isempty(MAN2)  % FAN to X block
                    fan2man = fan2man + 1; end
                if ~isempty(FAN1) && ~isempty(CHN2)
                    fan2chn = fan2chn + 1; end
                if ~isempty(FAN1) && ~isempty(CXN2)
                    fan2cxn = fan2cxn + 1; end
                if ~isempty(FAN1) && ~isempty(OLN2)
                    fan2oln = fan2oln + 1; end
                
                if ~isempty(MAN1) && ~isempty(FAN2)  % MAN to X block
                    man2fan = man2fan + 1; end
                if ~isempty(MAN1) && ~isempty(CHN2)
                    man2chn = man2chn + 1; end
                if ~isempty(MAN1) && ~isempty(CXN2)
                    man2cxn = man2cxn + 1; end
                if ~isempty(MAN1) && ~isempty(OLN2)
                    man2oln = man2oln + 1; end
                
                if ~isempty(CHN1) && ~isempty(FAN2)  % CHN to X block
                    chn2fan = chn2fan + 1; end
                if ~isempty(CHN1) && ~isempty(MAN2)
                    chn2man = chn2man + 1; end
                if ~isempty(CHN1) && ~isempty(CXN2)
                    chn2cxn = chn2cxn + 1; end
                if ~isempty(CHN1) && ~isempty(OLN2)
                    chn2oln = chn2oln + 1; end
                
                if ~isempty(CXN1) && ~isempty(FAN2)  % CXN to X block
                    cxn2fan = cxn2fan + 1; end
                if ~isempty(CXN1) && ~isempty(MAN2)
                    cxn2man = cxn2man + 1; end
                if ~isempty(CXN1) && ~isempty(CHN2)
                    cxn2chn = cxn2chn + 1; end
                if ~isempty(CXN1) && ~isempty(OLN2)
                    cxn2oln = cxn2oln + 1; end
                
                if ~isempty(OLN1) && ~isempty(FAN2)  % OLN to X block
                    oln2fan = oln2fan + 1; end
                if ~isempty(OLN1) && ~isempty(MAN2)
                    oln2man = oln2man + 1; end
                if ~isempty(OLN1) && ~isempty(CHN2)
                    oln2chn = oln2chn + 1; end
                if ~isempty(OLN1) && ~isempty(CXN2)
                    oln2cxn = oln2cxn + 1; end
            end
        end
        fnameOut = ['0.dat_' fTime '.tsv'];
        fOut = fopen(fnameOut, 'a');
        % demographic and file output
        fprintf(fOut,'%s',    fnameOut);        fprintf(fOut,'\t');
        fprintf(fOut,'%s',    chKey);           fprintf(fOut,'\t'); % LENA key
        fprintf(fOut,'%5.0f', sex);             fprintf(fOut,'\t'); % isBoy
        fprintf(fOut,'%s',    age);             fprintf(fOut,'\t');
        fprintf(fOut,'%s',    dob);             fprintf(fOut,'\t');
        fprintf(fOut,'%s',    fname);           fprintf(fOut,'\t');
        fprintf(fOut,'%5.0f', pTD);             fprintf(fOut,'\t'); % is_TD
        
        % conversational level output
        fprintf(fOut,'%5.0f', totTurns);        fprintf(fOut,'\t');
        fprintf(fOut,'%5.0f', AWC);             fprintf(fOut,'\t'); % adult word count
        fprintf(fOut,'%5.0f', femAWC);          fprintf(fOut,'\t');
        fprintf(fOut,'%5.0f', malAWC);          fprintf(fOut,'\t');
        fprintf(fOut,'%5.0f', chiUtt);          fprintf(fOut,'\t');
        fprintf(fOut,'%5.0f', chiUtt2);         fprintf(fOut,'\t');
        fprintf(fOut,'%5.0f', chiVocLen);       fprintf(fOut,'\t'); % child vocal length, seconds
        % conversational outputs
        fprintf(fOut,'%5.0f', fan2man);         fprintf(fOut,'\t');
        fprintf(fOut,'%5.0f', fan2chn);         fprintf(fOut,'\t');
        fprintf(fOut,'%5.0f', fan2cxn);         fprintf(fOut,'\t');
        fprintf(fOut,'%5.0f', fan2oln);         fprintf(fOut,'\t');
        
        fprintf(fOut,'%5.0f', man2fan);         fprintf(fOut,'\t');
        fprintf(fOut,'%5.0f', man2chn);         fprintf(fOut,'\t');
        fprintf(fOut,'%5.0f', man2cxn);         fprintf(fOut,'\t');
        fprintf(fOut,'%5.0f', man2oln);         fprintf(fOut,'\t');
        
        fprintf(fOut,'%5.0f', chn2fan);         fprintf(fOut,'\t');
        fprintf(fOut,'%5.0f', chn2man);         fprintf(fOut,'\t');
        fprintf(fOut,'%5.0f', chn2cxn);         fprintf(fOut,'\t');
        fprintf(fOut,'%5.0f', chn2oln);         fprintf(fOut,'\t');
        
        fprintf(fOut,'%5.0f', cxn2fan);         fprintf(fOut,'\t');
        fprintf(fOut,'%5.0f', cxn2man);         fprintf(fOut,'\t');
        fprintf(fOut,'%5.0f', cxn2chn);         fprintf(fOut,'\t');
        fprintf(fOut,'%5.0f', cxn2oln);         fprintf(fOut,'\t');
        
        fprintf(fOut,'%5.0f', oln2fan);         fprintf(fOut,'\t');
        fprintf(fOut,'%5.0f', oln2man);         fprintf(fOut,'\t');
        fprintf(fOut,'%5.0f', oln2chn);         fprintf(fOut,'\t');
        fprintf(fOut,'%5.0f', oln2cxn);         fprintf(fOut,'\n');      
    end
end

key = ['fnameOut chKey isBoy age dob fname isTD totTurns AWC femAWC malAWC chiUtt chiUtt2 chiVocLen fan2man fan2chn fan2cxn fan2oln man2fan man2chn man2cxn man2oln chn2fan chn2man chn2cxn chn2oln cxn2fan cxn2man cxn2chn cxn2oln oln2fan oln2man oln2chn oln2cxn'];
fnKey = ['0.key_' fTime '.txt'];
fKey = fopen(fnKey, 'w');
fprintf(fKey, key);
fclose(fKey);

disp(['file ' fnameOut ' was created'])
disp(['key  ' fnKey ' was created'])

fclose('all');
clear all;
