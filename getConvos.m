%%% Read ITS files for selected tags
%%% outputs as tab-separated text file and a key file (just the headers)
%%% M. VanDam  labs.wsu.edu/vandam  January 2016
clear all;
clc
c = clock; y = num2str(c(1)); m=num2str(c(2)); d=num2str(c(3)); h=num2str(c(4)); mn=num2str(c(5)); S=fix(c(6)); s=num2str(S);
fTime = [y m d h mn s];

folderName = uigetdir;
cd([folderName '\'])
folderContents = dir;
for i = 1:length(folderContents)
    k = strfind(folderContents(i).name, '.its');
    if ~isempty(k)
        fid = fopen(folderContents(i).name);
        tline = fgetl(fid);
        totTurns    = 0; % turnTaking
        femIni      = 0; % femaleAdultInitiation
        malIni      = 0; % maleAdultInitiation
        chiResp     = 0; % childResponse
        chiIni      = 0; % childInitiation
        femResp     = 0; % femaleAdultResponse
        malResp     = 0; % maleAdultResponse
        AWC         = 0; % adultWordCnt
        femAWC      = 0; % femaleAdultWordCnt
        malAWC      = 0; % maleAdultWordCnt
        femUtt      = 0; % femaleAdultUttCnt
        malUtt      = 0; % maleAdultUttCnt
        chiUtt      = 0; % childUttCnt
        
        while ischar(tline)
            tline = fgetl(fid);
            if ~ischar(tline), break, end
            
            chKeyN = strfind(tline, 'ChildKey');
            if ~isempty(chKeyN)
                lab = 'ChildKey';
                idx = strfind(tline, lab);
                idxQ = strfind(tline(idx:end), '"');
                varLab = tline(idx+idxQ(1):idx+idxQ(2)-2);
                chKey = varLab;
            end
            
            sexN = strfind(tline, 'Gender');
            if ~isempty(sexN)
                lab = 'Gender';
                idx = strfind(tline, lab);
                idxQ = strfind(tline(idx:end), '"');
                varLab = tline(idx+idxQ(1):idx+idxQ(2)-2);
                sex = varLab;
            end
            
            ageN = strfind(tline, 'algorithmAge');
            if ~isempty(ageN)
                lab = 'algorithmAge';
                idx = strfind(tline, lab);
                idxQ = strfind(tline(idx:end), '"');
                varLab = tline(idx+idxQ(1)+1:idx+idxQ(2)-3);
                age = varLab;
            end
            
            fnameN = strfind(tline, 'fileName');
            if ~isempty(fnameN)
                lab = 'fileName';
                idx = strfind(tline, lab);
                idxQ = strfind(tline(idx:end), '"');
                varLab = tline(idx+idxQ(1):idx+idxQ(2)-2);
                fname = varLab;
            end
            
            convo = strfind(tline, '<Conversation');
            if ~isempty(convo)
                lab = 'turnTaking';
                idx = strfind(tline, lab);
                idxQ = strfind(tline(idx:end), '"');
                varLab = tline(idx+idxQ(1):idx+idxQ(2)-2);
                totTurns = totTurns + str2num(varLab);
                
                lab = 'femaleAdultInitiation';
                idx = strfind(tline, lab);
                idxQ = strfind(tline(idx:end), '"');
                varLab = tline(idx+idxQ(1):idx+idxQ(2)-2);
                femIni = femIni + str2num(varLab);
                
                lab = ' maleAdultInitiation';  %notice leading literal space
                idx = strfind(tline, lab);
                idxQ = strfind(tline(idx:end), '"');
                varLab = tline(idx+idxQ(1):idx+idxQ(2)-2);
                malIni = malIni + str2num(varLab);
                
                lab = 'childResponse';
                idx = strfind(tline, lab);
                idxQ = strfind(tline(idx:end), '"');
                varLab = tline(idx+idxQ(1):idx+idxQ(2)-2);
                chiResp = chiResp + str2num(varLab);
                
                lab = 'childInitiation';
                idx = strfind(tline, lab);
                idxQ = strfind(tline(idx:end), '"');
                varLab = tline(idx+idxQ(1):idx+idxQ(2)-2);
                chiIni = chiIni + str2num(varLab);
                
                lab = 'femaleAdultResponse';
                idx = strfind(tline, lab);
                idxQ = strfind(tline(idx:end), '"');
                varLab = tline(idx+idxQ(1):idx+idxQ(2)-2);
                femResp = femResp + str2num(varLab);
                
                lab = ' maleAdultResponse'; %notice leading literal space
                idx = strfind(tline, lab);
                idxQ = strfind(tline(idx:end), '"');
                varLab = tline(idx+idxQ(1):idx+idxQ(2)-2);
                malResp = malResp + str2num(varLab);
                
                lab = 'adultWordCnt';
                idx = strfind(tline, lab);
                idxQ = strfind(tline(idx:end), '"');
                varLab = tline(idx+idxQ(1):idx+idxQ(2)-2);
                AWC = AWC + str2num(varLab);
                
                lab = 'femaleAdultWordCnt';
                idx = strfind(tline, lab);
                idxQ = strfind(tline(idx:end), '"');
                varLab = tline(idx+idxQ(1):idx+idxQ(2)-2);
                femAWC = femAWC + str2num(varLab);
                
                lab = ' maleAdultWordCnt'; %notice leading literal space
                idx = strfind(tline, lab);
                idxQ = strfind(tline(idx:end), '"');
                varLab = tline(idx+idxQ(1):idx+idxQ(2)-2);
                malAWC = malAWC + str2num(varLab);
                
                lab = 'femaleAdultUttCnt';
                idx = strfind(tline, lab);
                idxQ = strfind(tline(idx:end), '"');
                varLab = tline(idx+idxQ(1):idx+idxQ(2)-2);
                femUtt= femUtt + str2num(varLab);
                
                lab = ' maleAdultUttCnt'; %notice leading literal space
                idx = strfind(tline, lab);
                idxQ = strfind(tline(idx:end), '"');
                varLab = tline(idx+idxQ(1):idx+idxQ(2)-2);
                malUtt = malUtt+ str2num(varLab);
                
                lab = 'childUttCnt';
                idx = strfind(tline, lab);
                idxQ = strfind(tline(idx:end), '"');
                varLab = tline(idx+idxQ(1):idx+idxQ(2)-2);
                chiUtt = chiUtt + str2num(varLab);               
            end
        end
        fclose(fid);
        
        fnameOut = ['dat_' fTime '.txt'];
        fOut = fopen(fnameOut, 'a');
        fprintf(fOut, '%s', fnameOut);          fprintf(fOut,'\t');
        fprintf(fOut, '%s', chKey);             fprintf(fOut,'\t');
        fprintf(fOut, '%s', sex);               fprintf(fOut,'\t');
        fprintf(fOut, '%s', age);               fprintf(fOut,'\t');
        fprintf(fOut, '%s', fname);             fprintf(fOut,'\t');
        fprintf(fOut,'%5.0f', totTurns);    	fprintf(fOut,'\t');
        fprintf(fOut,'%5.0f', femIni);          fprintf(fOut,'\t');
        fprintf(fOut,'%5.0f', malIni);          fprintf(fOut,'\t');
        fprintf(fOut,'%5.0f', chiResp);         fprintf(fOut,'\t');
        fprintf(fOut,'%5.0f', chiIni);          fprintf(fOut,'\t');
        fprintf(fOut,'%5.0f', femResp);         fprintf(fOut,'\t');
        fprintf(fOut,'%5.0f', malResp);         fprintf(fOut,'\t');
        fprintf(fOut,'%5.0f', AWC);             fprintf(fOut,'\t');
        fprintf(fOut,'%5.0f', femAWC);          fprintf(fOut,'\t');
        fprintf(fOut,'%5.0f', malAWC);          fprintf(fOut,'\t');
        fprintf(fOut,'%5.0f', femUtt);          fprintf(fOut,'\t');
        fprintf(fOut,'%5.0f', malUtt);          fprintf(fOut,'\t');
        fprintf(fOut,'%5.0f', chiUtt);          fprintf(fOut,'\n');
        
    end
end
fclose(fOut);

key = ['fnameOut chKey sex age fname totTurns femIni malIni chiResp chiIni femResp malResp AWC femAWC malAWC femUtt malUtt chiUtt'];
fnKey = ['key_' fTime '.txt'];
fKey = fopen(fnKey, 'w');
fprintf(fKey, key);
fclose(fKey);

disp(['file ' fnameOut ' was created'])
disp(['key  ' fnKey ' was created'])
fclose('all')
