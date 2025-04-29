function rv = RVcal(respwave,resptime,Nfrs,TR,wds,time0)
% function rv = RVcal(espwave,resptime,respfs,Nfrs,TR,wds,time0)  
% calculate respiratory variation across a sequence of windows centered at
% each TR 
% input -- respwave: raw resp data 
%       -- resptime: time stamps of respwave
%       -- Nfrs: # of MR time frames 
%       -- TR: MR repetition time 
%       -- wds: window to integrate data (s)
%       -- time0: the starting time point of first TR 
% output -- rv: respiratory variation 

rv = []; 
for ifr = 1:Nfrs
    wds_time = time0 + (ifr-0.5)*TR; 
    resp_idx = find(resptime >= wds_time-wds/2 & resptime < wds_time+wds/2); 
    rv(ifr) = nanstd(respwave(resp_idx));  
end





end