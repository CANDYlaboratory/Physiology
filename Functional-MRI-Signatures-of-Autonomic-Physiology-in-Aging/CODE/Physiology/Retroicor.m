function  [Sretroicor] = Retroicor(Nfrs, TR, PPG, RESP)
% function  [Sretroicor] = Retroicor(Nfrs, TR, PPG, RESP)
%
% compute the RETROICOR and RVHR regressors based on: 
% [1] "Glover, G. H., Li, T. Q., & Ress, D. (2000). Image‐based method for retrospective correction of physiological motion effects in fMRI: 
% RETROICOR. Magnetic Resonance in Medicine: An Official Journal of the International Society for Magnetic Resonance in Medicine, 44(1), 162-167."
% and 
% [2]"Chang, C., Cunningham, J. P., & Glover, G. H. (2009). Influence of heart rate on the BOLD signal: the cardiac response function. Neuroimage, 44(3), 857-869."  
% 
% input -- Nfrs # of frames in the MR image 
%       -- TR  
%       -- PPG: structure with field: 
%               * PPG.dt sampling rates of PPG or EKG; 
%               * PPG.rate vector of cardiac trigger time (in sampling unit, integer numbers)
%       -- RESP: structure with field: 
%               * RESP.dt sampling rates of respiratory belt; 
%               * RESP.waveform respiratory waveform
%       ** starting points of PPG and RESP recordings should be shifted to
%       match the onset of the fMRI scan  
% 
% output -- Sretroicor: RETROICOR regressors to the 2nd order harmonics  

% Jingyuan 01/19, modified from code from Catie Chang  

% ----- converting cardiac peaks and respiratory signals into same time units ---------

PPG_dt = PPG.dt;  
RESP_dt = RESP.dt;   
hr = PPG.rate;  % cardiac events timing in sampling unit
Cardtime = hr*PPG_dt; % cardiac peak in time units 
respwave = RESP.waveform; % respiratory waveform 
MRtime = (1:Nfrs)*TR-TR/2; % reference to the middle point of a TR   

% ------------------------- compute cardiac phase --------------------------  
for ifr = 1:Nfrs  
    % Find the last cardiac event before the current MR time
    prev_trigs = find(Cardtime < MRtime(ifr));  
    if isempty(prev_trigs)
        t1 = 0; 
    else
        t1 = Cardtime(prev_trigs(end));  
    end     
    % Find the first cardiac event after the current MR time
    next_trigs = find(Cardtime > MRtime(ifr));  
    if isempty(next_trigs)
        t2 = MRtime(end); 
    else
        t2 = Cardtime(next_trigs(1));  
    end      
    % Calculate the phase of the cardiac cycle
    phi_cardiac(ifr) = (MRtime(ifr) - t1)*2*pi/(t2-t1)-pi;     
end

% -----------------compute phase of the respiratory cycle ------------------

% Filter respiratory waveform to remove high frequency noise
respwave = respwave-min(respwave);
[Hb,bins] = hist(respwave,100);
f_cutoff = 1; % max allowable freq
wn = f_cutoff/((1/RESP_dt)/2); % normalize by Nyquist frequency
ntaps = 20; % define number of taps in the filter
b = fir1(ntaps,wn);
respfilt = filtfilt(b,1,respwave);
drdt = diff(respfilt);

% Loop through each frame to determine the respiratory phase
for ifr = 1:Nfrs  
    iphys = max(1,round(MRtime(ifr)/RESP_dt)); % closest index in resp waveform
    iphys = min(iphys,length(drdt));
    amp = respwave(iphys);
    dbins = abs(amp-bins); % distance to histogram bins
    [blah,thisBin] = min(dbins);  % closest respiratory histogram bin
    numer = sum(Hb(1:thisBin)); % sum histogram bins up to closest bin
    phi_resp(ifr) = pi*sign(drdt(iphys))*(numer/length(respfilt)); % compute phase
end  

phi_cardiac = phi_cardiac(:);  
phi_resp = phi_resp(:);  

% ------------------------- Construct RETROICOR Regressors -------------------------
% compute the retroicor regressors based on the cardiac and respiratory phase (4 regressors for each)
Sretroicor = [sin(phi_cardiac) cos(phi_cardiac) sin(phi_cardiac*2) cos(phi_cardiac*2) ... 
    sin(phi_resp) cos(phi_resp) sin(phi_resp*2) cos(phi_resp*2)];  


end