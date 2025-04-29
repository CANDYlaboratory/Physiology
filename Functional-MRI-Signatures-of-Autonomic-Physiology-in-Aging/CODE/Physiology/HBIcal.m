function hbi = HBIcal(cardtrigger,Nfrs,TR,wds,time0)
% function hbi = HBIcal(cardtrigger,Nfrs,TR,wds,time0)
% calculate the inter-heart-beat interval (inverse of HR) across a sequence
% of windows centered at each TR 
% input -- cardtrigger: time stamps of cardiac peak events  
%       -- Nfrs: # of MR time frames 
%       -- TR: MR repetition time 
%       -- wds: window to integrate data (s)
%       -- time0: the starting time point of first TR 
% output -- hbi: inter-heart-beat interval  

hbi = [];  
for ifr = 1:Nfrs
    
    wds_time = time0 + (ifr-0.5)*TR; 
    card_idx = find(cardtrigger >= wds_time-wds/2 & cardtrigger < wds_time+wds/2); 
    hbi(ifr) = nanmean(diff(cardtrigger(card_idx)));
    
end

end